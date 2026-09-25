-- =========================================================================
-- V2: Reference / lookup tables
--   roles, permissions, auth_providers, property_management_plans, amenities
-- =========================================================================

-- ---------- ROLES (pure lookup — no user_id here; see user_roles in V3) --
CREATE TABLE IF NOT EXISTS roles (
                                     id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                     code              VARCHAR(50) NOT NULL,           -- e.g. GUEST, TENANT, LANDLORD, ADMIN_SUPPORT
                                     description       TEXT,
                                     hierarchy_level   INT NOT NULL DEFAULT 0,         -- higher = more authority; a role can only
    -- create/promote roles with a LOWER level
    -- than its own. Enforced in the service layer,
    -- not here.
                                     created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
                                     updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
                                     deleted_at        TIMESTAMPTZ
);
CREATE UNIQUE INDEX uq_roles_code ON roles(code) WHERE deleted_at IS NULL;
CREATE TRIGGER trg_roles_updated_at BEFORE UPDATE ON roles FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------- PERMISSIONS -----------
CREATE TABLE IF NOT EXISTS permissions (
                                           id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                           code          VARCHAR(100) NOT NULL,
                                           description   TEXT,
                                           created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
                                           updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
                                           deleted_at    TIMESTAMPTZ
);
CREATE UNIQUE INDEX uq_permissions_code ON permissions(code) WHERE deleted_at IS NULL;
CREATE TRIGGER trg_permissions_updated_at BEFORE UPDATE ON permissions FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------- AUTH_PROVIDERS -----------
CREATE TABLE IF NOT EXISTS auth_providers (
                                              id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                              code          VARCHAR(50) NOT NULL,               -- e.g. LOCAL, GOOGLE
                                              description   TEXT,
                                              enabled       BOOLEAN NOT NULL DEFAULT TRUE,
                                              created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
                                              updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
                                              deleted_at    TIMESTAMPTZ
);
CREATE UNIQUE INDEX uq_auth_providers_code ON auth_providers(code) WHERE deleted_at IS NULL;
CREATE TRIGGER trg_auth_providers_updated_at BEFORE UPDATE ON auth_providers FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------- PROPERTY_MANAGEMENT_PLANS (typo fixed: "propert" -> "property")
CREATE TABLE IF NOT EXISTS property_management_plans (
                                                         id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                                         name                            VARCHAR(150) NOT NULL,
                                                         number_of_properties            INT NOT NULL CHECK (number_of_properties >= 0),
                                                         number_of_blocks_per_property   INT NOT NULL CHECK (number_of_blocks_per_property >= 0),
                                                         max_number_of_units_per_block   INT NOT NULL CHECK (max_number_of_units_per_block >= 0),
                                                         can_generate_analytics          BOOLEAN NOT NULL DEFAULT FALSE,
                                                         cost                            NUMERIC(12,2) NOT NULL CHECK (cost >= 0),
                                                         duration_days                   INT NOT NULL CHECK (duration_days > 0),
                                                         created_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
                                                         updated_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
                                                         deleted_at                      TIMESTAMPTZ
);
CREATE UNIQUE INDEX uq_property_management_plans_name ON property_management_plans(name) WHERE deleted_at IS NULL;
CREATE TRIGGER trg_property_management_plans_updated_at BEFORE UPDATE ON property_management_plans FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------- AMENITIES (typo fixed: "ameniteis" -> "amenities") -----------
CREATE TABLE IF NOT EXISTS amenities (
                                         id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                         code          VARCHAR(50) NOT NULL,
                                         name          VARCHAR(100) NOT NULL,
                                         description   TEXT,
                                         created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
                                         updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
                                         deleted_at    TIMESTAMPTZ
);
CREATE UNIQUE INDEX uq_amenities_code ON amenities(code) WHERE deleted_at IS NULL;
CREATE TRIGGER trg_amenities_updated_at BEFORE UPDATE ON amenities FOR EACH ROW EXECUTE FUNCTION set_updated_at();