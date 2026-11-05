-- ============================================================
-- Roles (least privilege)
--
--   fraud_detection_admin      : training (model_versions), analytics DAG
--   fraud_detection_app        : real-time processor
--   fraud_detection_bi         : Power BI, read-only on analytics
--   fraud_detection_monitoring : monitoring DAG, reads the operational
--                                tables, writes the monitoring schema
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
        'fraud_detection_bi',
        'fraud_detection_monitoring'
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
    TO fraud_detection_admin, fraud_detection_app, fraud_detection_bi,
       fraud_detection_monitoring;

GRANT USAGE ON SCHEMA public
    TO fraud_detection_admin, fraud_detection_app, fraud_detection_monitoring;

-- Privileges on tables and schemas are granted in the following
-- scripts (02 to 05), right after the objects are created.
