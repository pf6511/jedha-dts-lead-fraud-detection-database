DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles
        WHERE rolname = 'fraud_detection_app'
    ) THEN
        CREATE ROLE fraud_detection_app
            LOGIN
            PASSWORD 'change_me';
    END IF;
END
$$;

GRANT CONNECT
ON DATABASE fraud_detection
TO fraud_detection_app;

GRANT USAGE
ON SCHEMA public
TO fraud_detection_app;