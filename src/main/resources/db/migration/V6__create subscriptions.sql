-- =========================================================================
-- V6: Subscriptions
--   Depends on: V2 (property_management_plans), V3 (users)
-- =========================================================================
CREATE TABLE IF NOT EXISTS subscription (
                                            id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                            user_id                         UUID NOT NULL REFERENCES users(id),
                                            property_management_plan_id    UUID NOT NULL REFERENCES property_management_plans(id),
                                            status                           VARCHAR(20) NOT NULL DEFAULT 'pending'
                                                CHECK (status IN ('pending', 'active', 'expired', 'cancelled')),
                                            starts_at                        TIMESTAMPTZ,
                                            ends_at                          TIMESTAMPTZ,
                                            created_at                       TIMESTAMPTZ NOT NULL DEFAULT now(),
                                            updated_at                       TIMESTAMPTZ NOT NULL DEFAULT now(),
                                            deleted_at                       TIMESTAMPTZ
);
CREATE INDEX ix_subscription_user_id ON subscription(user_id);
CREATE INDEX ix_subscription_plan_id ON subscription(property_management_plan_id);
-- Only one active subscription per user at a time
CREATE UNIQUE INDEX uq_subscription_active_user
    ON subscription(user_id) WHERE status = 'active' AND deleted_at IS NULL;
CREATE TRIGGER trg_subscription_updated_at BEFORE UPDATE ON subscription FOR EACH ROW EXECUTE FUNCTION set_updated_at();