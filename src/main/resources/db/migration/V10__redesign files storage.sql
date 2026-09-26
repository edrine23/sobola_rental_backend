-- =========================================================================
-- V9: Redesign `files` — storage_key, drop polymorphic ownership
--   Depends on: V4 (files)
-- =========================================================================
-- Rationale: entity_type/entity_id gave no DB-level referential integrity
-- -- nothing stopped entity_type='property' from pointing at a user's id.
-- Ownership now belongs to the feature that owns it: a direct FK column
-- for a single specific-meaning file (already the pattern on
-- landlord_application), or a join table for many files per owner (see
-- V10: property_files, unit_files).
--
-- files is now purely storage METADATA ("what is this file, where does
-- it live") -- not "what business object owns it".

ALTER TABLE files ADD COLUMN storage_key VARCHAR(1024);

-- Backfill any existing rows (dev/test data) so the NOT NULL constraint
-- below doesn't fail. Real rows should already carry a real key once the
-- upload flow is updated to set it -- these are unambiguous placeholders,
-- not something that should ever reach production.
UPDATE files SET storage_key = 'LEGACY_UNSET_' || id::text WHERE storage_key IS NULL;

ALTER TABLE files ALTER COLUMN storage_key SET NOT NULL;

DROP INDEX IF EXISTS ix_files_entity;
ALTER TABLE files DROP COLUMN entity_type;
ALTER TABLE files DROP COLUMN entity_id;

CREATE UNIQUE INDEX uq_files_storage_key
    ON files(storage_provider, storage_key) WHERE deleted_at IS NULL;

-- Reminder: don't expose storage_key to API clients -- return a
-- signed/temporary URL generated server-side instead.