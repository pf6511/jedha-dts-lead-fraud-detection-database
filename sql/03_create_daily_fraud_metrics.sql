
BEGIN;

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS analytics.daily_fraud_metrics (
    report_date DATE PRIMARY KEY,

    period_start TIMESTAMPTZ NOT NULL,
    period_end TIMESTAMPTZ NOT NULL,

    transaction_count BIGINT NOT NULL DEFAULT 0,
    evaluated_transaction_count BIGINT NOT NULL DEFAULT 0,
    predicted_fraud_count BIGINT NOT NULL DEFAULT 0,

    predicted_fraud_rate_percent NUMERIC(5, 2),
    predicted_fraud_amount NUMERIC(18, 2) NOT NULL DEFAULT 0,

    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    airflow_run_id TEXT,
	report_timezone TEXT NOT NULL DEFAULT 'Europe/Paris',

    CONSTRAINT chk_daily_metrics_period
        CHECK (period_end > period_start),

    CONSTRAINT chk_daily_metrics_counts
        CHECK (
            transaction_count >= 0
            AND evaluated_transaction_count >= 0
            AND evaluated_transaction_count <= transaction_count
            AND predicted_fraud_count >= 0
            AND predicted_fraud_count <= evaluated_transaction_count
        )
);

GRANT USAGE ON SCHEMA analytics
TO fraud_detection_admin;

GRANT SELECT, INSERT, UPDATE
ON analytics.daily_fraud_metrics
TO fraud_detection_admin;

GRANT SELECT ON analytics.daily_fraud_metrics
TO fraud_detection_bi;

COMMIT;
