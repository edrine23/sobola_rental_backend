-- =========================================================================
-- V7: Properties / blocks / units
--   Depends on: V2 (amenities), V3 (users)
-- =========================================================================
CREATE TABLE IF NOT EXISTS properties (
                                          id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                          landlord_id        UUID NOT NULL REFERENCES users(id),   -- was incorrectly reusing id = users.id
                                          name               VARCHAR(150) NOT NULL,
                                          location           TEXT,
                                          number_of_blocks   INT NOT NULL DEFAULT 0 CHECK (number_of_blocks >= 0),
                                          created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
                                          updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
                                          deleted_at         TIMESTAMPTZ
);
CREATE INDEX ix_properties_landlord_id ON properties(landlord_id);
CREATE TRIGGER trg_properties_updated_at BEFORE UPDATE ON properties FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------- PROPERTY_AMENITIES (join table — replaces properties.amenities)
CREATE TABLE IF NOT EXISTS property_amenities (
                                                  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                                  property_id   UUID NOT NULL REFERENCES properties(id),
                                                  amenity_id    UUID NOT NULL REFERENCES amenities(id),
                                                  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX uq_property_amenities ON property_amenities(property_id, amenity_id);
CREATE INDEX ix_property_amenities_amenity_id ON property_amenities(amenity_id);

-- ---------- BLOCKS -----------
CREATE TABLE IF NOT EXISTS blocks (
                                      id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                      property_id       UUID NOT NULL REFERENCES properties(id),
                                      name              VARCHAR(100) NOT NULL,
                                      type              VARCHAR(50) NOT NULL DEFAULT 'apartment',
                                      number_of_units   INT NOT NULL DEFAULT 0 CHECK (number_of_units >= 0),
                                      created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
                                      updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
                                      deleted_at        TIMESTAMPTZ
);
CREATE INDEX ix_blocks_property_id ON blocks(property_id);
CREATE TRIGGER trg_blocks_updated_at BEFORE UPDATE ON blocks FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------- UNITS -----------
CREATE TABLE IF NOT EXISTS units (
                                     id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                     block_id               UUID NOT NULL REFERENCES blocks(id),
                                     type                   VARCHAR(50) NOT NULL DEFAULT 'self contained',
                                     name                   VARCHAR(100) NOT NULL,
                                     number_of_rooms        INT CHECK (number_of_rooms >= 0),
                                     number_of_bathrooms    INT CHECK (number_of_bathrooms >= 0),   -- typo fixed: "birthrooms" -> "bathrooms"
                                     rent_cost              NUMERIC(12,2) NOT NULL CHECK (rent_cost >= 0),
                                     security_cost          NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (security_cost >= 0),
                                     status                 VARCHAR(20) NOT NULL DEFAULT 'unoccupied'
                                         CHECK (status IN ('unoccupied', 'occupied', 'under_maintenance', 'reserved')),
    -- 'reserved' covers BOTH "occupancy requested, not
    -- yet paid" and "paid, not yet moved in" -- see
    -- the occupancy table's state machine (V8).
                                     created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
                                     updated_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
                                     deleted_at             TIMESTAMPTZ
);
CREATE INDEX ix_units_block_id ON units(block_id);
CREATE TRIGGER trg_units_updated_at BEFORE UPDATE ON units FOR EACH ROW EXECUTE FUNCTION set_updated_at();