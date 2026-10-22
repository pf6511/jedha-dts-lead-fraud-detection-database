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
	
    IF NOT EXISTS (
        SELECT FROM pg_roles
        WHERE rolname = 'fraud_detection_bi '
    ) THEN
        CREATE ROLE fraud_detection_bi
            LOGIN
            PASSWORD 'password#999';
    END IF;
	
END
$$;

GRANT CONNECT
ON DATABASE fraud_detection
TO fraud_detection_app;

GRANT USAGE
ON SCHEMA public
TO fraud_detection_app;

GRANT CONNECT ON DATABASE fraud_detection
TO fraud_detection_bi;

GRANT USAGE ON SCHEMA analytics
TO fraud_detection_bi;