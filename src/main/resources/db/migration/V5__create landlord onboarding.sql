-- =========================================================================
-- V5: Landlord onboarding
--   Depends on: V2 (property_management_plans), V3 (users), V4 (files)
-- =========================================================================
CREATE TABLE IF NOT EXISTS landlord_application (
                                                    id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                                    user_id                         UUID NOT NULL REFERENCES users(id),
                                                    property_management_plan_id    UUID NOT NULL REFERENCES property_management_plans(id),
                                                    line_of_work                    VARCHAR(150) NOT NULL,
                                                    home_address                    TEXT NOT NULL,
                                                    front_id_file_id                UUID REFERENCES files(id),
                                                    back_id_file_id                 UUID REFERENCES files(id),
                                                    face_image_file_id              UUID REFERENCES files(id),
                                                    status                           VARCHAR(20) NOT NULL DEFAULT 'pending'
                                                        CHECK (status IN ('pending', 'approved', 'rejected')),
                                                    reviewed_by                      UUID REFERENCES users(id),   -- Sobola admin who reviewed it
                                                    reviewed_at                      TIMESTAMPTZ,
                                                    rejection_reason                 TEXT,
                                                    created_at                       TIMESTAMPTZ NOT NULL DEFAULT now(),
                                                    updated_at                       TIMESTAMPTZ NOT NULL DEFAULT now(),
                                                    deleted_at                       TIMESTAMPTZ
);
CREATE INDEX ix_landlord_application_user_id ON landlord_application(user_id);
-- Only one application can be "in flight" per user at a time
CREATE UNIQUE INDEX uq_landlord_application_pending
    ON landlord_application(user_id) WHERE status = 'pending' AND deleted_at IS NULL;
CREATE TRIGGER trg_landlord_application_updated_at BEFORE UPDATE ON landlord_application FOR EACH ROW EXECUTE FUNCTION set_updated_at();