-- ============================================================
-- Roles (least privilege)
--
--   fraud_detection_admin : training (model_versions), analytics DAG
--   fraud_detection_app   : real-time processor
--   fraud_detection_bi    : Power BI, read-only on analytics
--
-- No password in this file: the repository is public. Roles are
-- created without password, then a password is set once, outside
-- the repository, by an administrator:
--
--   psql:    \password fraud_detection_app
--   pgAdmin: ALTER ROLE fraud_detection_app PASSWORD '...';
--            (typed in the query tool, never saved to a file)
--
-- Idempotent: can be run several times.
-- ============================================================

DO $$
DECLARE
    role_name TEXT;
BEGIN
    FOREACH role_name IN ARRAY ARRAY[
        'fraud_detection_admin',
        'fraud_detection_app',
        'fraud_detection_bi'
    ]
    LOOP
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = role_name) THEN
            EXECUTE format('CREATE ROLE %I LOGIN', role_name);
        END IF;
    END LOOP;
END
$$;

-- Nobody but the owner creates objects in the public schema.
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

GRANT CONNECT ON DATABASE fraud_detection
    TO fraud_detection_admin, fraud_detection_app, fraud_detection_bi;

GRANT USAGE ON SCHEMA public
    TO fraud_detection_admin, fraud_detection_app;

-- Privileges on tables and on the analytics schema are granted in
-- 02_create_tables.sql and 03_create_daily_fraud_metrics.sql, right
-- after the objects are created.
