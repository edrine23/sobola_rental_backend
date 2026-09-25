-- =========================================================================
-- V1: Schema bootstrap + shared helper function
-- =========================================================================
-- NOTE: no `SET search_path` here on purpose. Given the schema-targeting
-- issues already resolved in application.yml / the Flyway Maven plugin
-- config (flyway.schemas=sobola_rent), Flyway already routes each
-- migration into the right schema based on that config. Hardcoding it
-- again here would duplicate that and risk drifting out of sync if the
-- config ever changes. If a future migration lands in `public`
-- unexpectedly, check flyway.schemas / the Hibernate default_schema
-- setting first, rather than patching it back into a script.
-- =========================================================================

CREATE SCHEMA IF NOT EXISTS sobola_rent;

-- Keeps updated_at current on every UPDATE, for every table that has one.
CREATE OR REPLACE FUNCTION set_updated_at()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;