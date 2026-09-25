-- =========================================================================
-- V3: Users & access control
--   users, user_roles, role_permission, credentials
--   Depends on: V2 (roles, permissions, auth_providers)
-- =========================================================================

-- Short, human-typeable lookup code (e.g. SBL-001000) used by landlords /
-- app code to find a user quickly -- without exposing the UUID PK.
CREATE SEQUENCE IF NOT EXISTS platform_number_seq START 1000;

-- ---------- USERS -----------
CREATE TABLE IF NOT EXISTS users (
                                     id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                     platform_number            VARCHAR(20) NOT NULL
                                                                                 DEFAULT ('SBL-' || lpad(nextval('platform_number_seq')::text, 6, '0')),
                                     first_name                 VARCHAR(100) NOT NULL,
                                     last_name                  VARCHAR(100) NOT NULL,
                                     date_of_birth               DATE,
                                     phone_number               VARCHAR(20) NOT NULL,
                                     email                      VARCHAR(255) NOT NULL,
                                     nationality                VARCHAR(100) NOT NULL DEFAULT 'ugandan',
                                     national_identity_number   VARCHAR(30),
                                     created_at                 TIMESTAMPTZ NOT NULL DEFAULT now(),
                                     updated_at                 TIMESTAMPTZ NOT NULL DEFAULT now(),
                                     deleted_at                 TIMESTAMPTZ
);
CREATE UNIQUE INDEX uq_users_platform_number ON users(platform_number) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX uq_users_email           ON users(email)           WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX uq_users_phone_number    ON users(phone_number)    WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX uq_users_nin             ON users(national_identity_number)
    WHERE deleted_at IS NULL AND national_identity_number IS NOT NULL;
CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------- USER_ROLES (join table — replaces the old roles.user_id) -----
-- Pure association: hard-deleted on revoke, no updated_at/deleted_at.
-- Every user gets the GUEST role here by default at registration
-- (app-layer); guest -> tenant is a promotion via this table, driven by
-- the occupancy state machine (see V8).
CREATE TABLE IF NOT EXISTS user_roles (
                                          id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                          user_id      UUID NOT NULL REFERENCES users(id),
                                          role_id      UUID NOT NULL REFERENCES roles(id),
                                          assigned_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX uq_user_roles_user_role ON user_roles(user_id, role_id);
CREATE INDEX ix_user_roles_role_id ON user_roles(role_id);

-- ---------- ROLE_PERMISSION (join table) -----------
CREATE TABLE IF NOT EXISTS role_permission (
                                               id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                               role_id         UUID NOT NULL REFERENCES roles(id),
                                               permission_id   UUID NOT NULL REFERENCES permissions(id),
                                               created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX uq_role_permission ON role_permission(role_id, permission_id);
CREATE INDEX ix_role_permission_permission_id ON role_permission(permission_id);

-- ---------- CREDENTIALS -----------
CREATE TABLE IF NOT EXISTS credentials (
                                           id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                           user_id                UUID NOT NULL REFERENCES users(id),
                                           auth_provider_id       UUID NOT NULL REFERENCES auth_providers(id),
                                           password_hash          VARCHAR(255),              -- nullable: OAuth-only providers won't have one
                                           status                 VARCHAR(20) NOT NULL DEFAULT 'active'
                                               CHECK (status IN ('active', 'locked', 'disabled')),
                                           must_change_password   BOOLEAN NOT NULL DEFAULT FALSE,
                                           created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
                                           updated_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
                                           deleted_at             TIMESTAMPTZ
);
CREATE UNIQUE INDEX uq_credentials_user_provider ON credentials(user_id, auth_provider_id) WHERE deleted_at IS NULL;
CREATE TRIGGER trg_credentials_updated_at BEFORE UPDATE ON credentials FOR EACH ROW EXECUTE FUNCTION set_updated_at();