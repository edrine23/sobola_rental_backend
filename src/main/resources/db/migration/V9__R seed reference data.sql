-- =========================================================================
-- R: Seed reference data
--   Repeatable migration -- re-runs whenever this file's content changes.
--   Idempotent via ON CONFLICT ... DO NOTHING, so it's safe to re-apply.
--   Depends on: V2 (roles, permissions, auth_providers,
--   property_management_plans, amenities), V3 (role_permission)
-- =========================================================================

-- ---------- ROLES -----------
-- hierarchy_level left sparse (gaps of ~10-90) on purpose, so future admin
-- sub-tiers (ADMIN_SUPPORT, ADMIN_FINANCE, etc.) can slot in between
-- without renumbering everything. Note: hierarchy_level is primarily meant
-- to compare ADMIN-tier roles against each other for the "who can create
-- who" rule -- GUEST/TENANT/LANDLORD promotion happens via the occupancy
-- workflow and landlord_application, not a hierarchy check.
INSERT INTO roles (code, description, hierarchy_level) VALUES
                                                           ('GUEST',    'Default role assigned to every user at registration', 0),
                                                           ('TENANT',   'A guest with an active occupancy (paid/moved into a unit)', 10),
                                                           ('LANDLORD', 'Holder of an approved landlord application; manages properties', 20),
                                                           ('ADMIN',    'Sobola team administrator -- single tier placeholder; split into specific admin sub-roles here once those are defined', 100)
ON CONFLICT (code) WHERE deleted_at IS NULL DO NOTHING;

-- ---------- AUTH_PROVIDERS -----------
INSERT INTO auth_providers (code, description, enabled) VALUES
    ('LOCAL', 'Email/phone + password authentication', TRUE)
-- Add GOOGLE / other OAuth providers here if/when social login is built.
ON CONFLICT (code) WHERE deleted_at IS NULL DO NOTHING;

-- ---------- PERMISSIONS -----------
-- Minimal starter set, scoped to what's actually modeled so far. Add more
-- as maintenance/payments/chat/reviews get built out.
INSERT INTO permissions (code, description) VALUES
                                                ('LANDLORD_APPLICATION_REVIEW', 'Review a landlord application (approve/reject)'),
                                                ('PROPERTY_MANAGE',             'Create/update/delete properties, blocks, and units'),
                                                ('OCCUPANCY_MANAGE',            'Create and progress an occupancy (enrol tenants, confirm move-in/out)'),
                                                ('USER_ROLE_ASSIGN',            'Assign or revoke a role on a user account')
ON CONFLICT (code) WHERE deleted_at IS NULL DO NOTHING;

-- ---------- ROLE_PERMISSION -----------
-- Joined by code (not hardcoded UUIDs) so this stays correct regardless of
-- generated ids.
INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.code = 'ADMIN' AND p.code IN ('LANDLORD_APPLICATION_REVIEW', 'USER_ROLE_ASSIGN')
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.code = 'LANDLORD' AND p.code IN ('PROPERTY_MANAGE', 'OCCUPANCY_MANAGE')
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- ---------- AMENITIES -----------
-- General-purpose starter list, leaning toward what's commonly relevant to
-- the Ugandan rental market (borehole/backup power/solar water heating).
-- Easy to extend -- just add rows here.
INSERT INTO amenities (code, name, description) VALUES
                                                    ('PARKING',            'Parking',                'Dedicated parking space'),
                                                    ('WATER_SUPPLY',       'Piped Water Supply',      'Connected to piped/municipal water'),
                                                    ('BOREHOLE_WATER',     'Borehole Water',          'Borehole as a backup or primary water source'),
                                                    ('BACKUP_GENERATOR',   'Backup Generator',        'Generator backup during power outages'),
                                                    ('SOLAR_WATER_HEATER', 'Solar Water Heater',      'Solar-heated water'),
                                                    ('SECURITY_GUARD',     'Security Guard',          'On-site security personnel'),
                                                    ('PERIMETER_WALL',     'Perimeter Wall / Fence',  'Walled or fenced compound'),
                                                    ('WIFI',               'WiFi / Internet',         'Internet connectivity included or available'),
                                                    ('FURNISHED',          'Furnished',               'Unit comes furnished'),
                                                    ('BALCONY',            'Balcony',                 'Private balcony or veranda')
ON CONFLICT (code) WHERE deleted_at IS NULL DO NOTHING;

-- =========================================================================
-- PROPERTY_MANAGEMENT_PLANS -- PLACEHOLDER DATA, NOT REAL PRICING.
-- Seeded with one made-up plan purely so the NOT NULL FK on
-- landlord_application / subscription doesn't block local dev/testing.
-- Replace with actual plan tiers and UGX pricing before production.
-- =========================================================================
INSERT INTO property_management_plans
(name, number_of_properties, number_of_blocks_per_property, max_number_of_units_per_block, can_generate_analytics, cost, duration_days)
VALUES
    ('Starter', 1, 3, 10, FALSE, 100000.00, 30)
ON CONFLICT (name) WHERE deleted_at IS NULL DO NOTHING;