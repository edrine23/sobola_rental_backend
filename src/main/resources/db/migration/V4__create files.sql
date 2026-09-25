-- =========================================================================
-- V4: Files (generic storage, polymorphic ownership)
-- =========================================================================
CREATE TABLE IF NOT EXISTS files (
                                     id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                     storage_provider   VARCHAR(50) NOT NULL,
                                     content_type       VARCHAR(100) NOT NULL,
                                     original_name      VARCHAR(255) NOT NULL,
                                     size_bytes         BIGINT NOT NULL CHECK (size_bytes >= 0),
                                     entity_type        VARCHAR(50),                   -- e.g. 'landlord_application', 'property'
                                     entity_id          UUID,                           -- id of the owning row; app-enforced, no FK (polymorphic)
                                     created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
                                     updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
                                     deleted_at         TIMESTAMPTZ
);
CREATE INDEX ix_files_entity ON files(entity_type, entity_id);
CREATE TRIGGER trg_files_updated_at BEFORE UPDATE ON files FOR EACH ROW EXECUTE FUNCTION set_updated_at();