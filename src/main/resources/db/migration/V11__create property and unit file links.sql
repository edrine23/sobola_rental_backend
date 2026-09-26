-- =========================================================================
-- V10: Property / unit file associations (join tables)
--   Depends on: V4/V9 (files), V7 (properties, units)
-- =========================================================================
-- Replaces the generic entity_type/entity_id ownership dropped in V9.
-- Pure associations, same convention as user_roles / role_permission /
-- property_amenities: UUID surrogate PK + created_at, no updated_at or
-- deleted_at -- detaching a photo is a hard delete/re-insert, not
-- something that needs a soft-delete history at the row level.

CREATE TABLE IF NOT EXISTS property_files (
                                              id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                              property_id   UUID NOT NULL REFERENCES properties(id),
                                              file_id       UUID NOT NULL REFERENCES files(id),
                                              sort_order    INT NOT NULL DEFAULT 0,
                                              created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX uq_property_files ON property_files(property_id, file_id);
CREATE INDEX ix_property_files_file_id ON property_files(file_id);

CREATE TABLE IF NOT EXISTS unit_files (
                                          id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                          unit_id     UUID NOT NULL REFERENCES units(id),
                                          file_id     UUID NOT NULL REFERENCES files(id),
                                          sort_order  INT NOT NULL DEFAULT 0,
                                          created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX uq_unit_files ON unit_files(unit_id, file_id);
CREATE INDEX ix_unit_files_file_id ON unit_files(file_id);

-- Not modeled yet, flagging for later: occupancy documents (lease
-- agreement, move-in inspection, termination notice). A single current
-- lease could be `occupancy.lease_file_id UUID REFERENCES files(id)`;
-- multiple document types would want an `occupancy_files` table with a
-- `document_type` column instead. Revisit once occupancy documents are
-- actually being built.