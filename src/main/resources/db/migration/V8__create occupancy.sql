-- =========================================================================
-- V8: Occupancy (tenancy/lease record)
--   Depends on: V3 (users), V7 (units)
-- =========================================================================
-- State machine: requested -> booked -> active -> ended
--   requested : landlord enrols a guest -> tentative agreement, no payment
--               yet. units.status should move to 'reserved' here.
--   booked    : payment succeeded (see payments table, not yet modeled),
--               but tenant hasn't physically moved in. units.status STAYS
--               'reserved' -- this is the "paid but not in yet" gap.
--               Guest -> TENANT role promotion happens here (proposed).
--   active    : move-in confirmed (separate action from payment).
--               units.status -> 'occupied' here, not at `booked`.
--   ended     : tenancy over (moved out / lease ended). units.status ->
--               'unoccupied'.
--   cancelled / expired : off-ramps from `requested` or `booked` (tenant
--               backs out, payment window lapses, etc.)
-- Keeping units.status in sync with occupancy.status is app-layer logic,
-- not enforced here -- the workflow is still being worked out.
CREATE TABLE IF NOT EXISTS occupancy (
                                         id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                         unit_id                UUID NOT NULL REFERENCES units(id),
                                         tenant_id              UUID NOT NULL REFERENCES users(id),
                                         initiated_by           UUID REFERENCES users(id),   -- the landlord/admin who created this enrollment
                                         status                 VARCHAR(20) NOT NULL DEFAULT 'requested'
                                             CHECK (status IN ('requested', 'booked', 'active', 'ended', 'cancelled', 'expired')),
    -- Agreed terms, SNAPSHOTTED from units.rent_cost / units.security_cost at
    -- creation time -- deliberately NOT a live lookup. A later change to the
    -- unit's listed price must not retroactively change what an existing
    -- tenant owes; they're bound to what was agreed when they signed on.
                                         rent_cost       NUMERIC(12,2) NOT NULL CHECK (rent_cost >= 0),
                                         security_cost   NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (security_cost >= 0),
                                         upfront_months         INT NOT NULL DEFAULT 1 CHECK (upfront_months > 0),
    -- planned_move_in_date drives proration math (app-layer, not stored as a
    -- formula here); moved_in_at below is the separate CONFIRMATION event.
                                         planned_move_in_date   DATE,
    -- Actual amount charged for the move-in period (possibly prorated for a
    -- mid-month start) + upfront_months. Stored as computed, not derived on
    -- read, so the record stays accurate even if the proration formula
    -- changes later.
                                         first_period_amount    NUMERIC(12,2) CHECK (first_period_amount >= 0),
                                         requested_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
                                         paid_at        TIMESTAMPTZ,
                                         moved_in_at    TIMESTAMPTZ,
                                         ended_at       TIMESTAMPTZ,
                                         created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
                                         updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
                                         deleted_at     TIMESTAMPTZ
);
CREATE INDEX ix_occupancy_unit_id ON occupancy(unit_id);
CREATE INDEX ix_occupancy_tenant_id ON occupancy(tenant_id);
-- Only one non-terminal occupancy per unit at a time (no double-booking)
CREATE UNIQUE INDEX uq_occupancy_unit_active
    ON occupancy(unit_id) WHERE status IN ('requested', 'booked', 'active') AND deleted_at IS NULL;
CREATE TRIGGER trg_occupancy_updated_at BEFORE UPDATE ON occupancy FOR EACH ROW EXECUTE FUNCTION set_updated_at();