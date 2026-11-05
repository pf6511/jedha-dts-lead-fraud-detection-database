-- ============================================================
-- Monitoring schema: results of the pipeline checks
--
-- The monitoring DAG runs checks every hour (freshness, quarantine
-- rate, pending failures, model metrics over 7 days) and stores one
-- row per check and per run: history of the pipeline health, and
-- audit trail showing that the checks ran.
--
-- Role fraud_detection_monitoring (created in 01_create_roles.sql):
-- reads the operational tables, writes only the monitoring schema.
--
-- No personal data: only measures and thresholds.
--
-- Run after 04_create_processing_tables.sql. Idempotent.
-- ============================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS monitoring;

CREATE TABLE IF NOT EXISTS monitoring.check_results (
    check_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- e.g. freshness, quarantine_rate, pending_failures, recall_7d
    check_name TEXT NOT NULL,

    value DOUBLE PRECISION,             -- measured value
    threshold DOUBLE PRECISION,         -- threshold applied

    status TEXT NOT NULL
        CHECK (status IN ('ok', 'alert')),

    details TEXT                        -- e.g. "3 payments pending"
);

-- History of one check over time
CREATE INDEX IF NOT EXISTS idx_check_results_name_time
    ON monitoring.check_results(check_name, checked_at);

-- ============================================================
-- Privileges
-- ============================================================

-- Monitoring DAG: reads what it measures...
GRANT SELECT ON public.transactions TO fraud_detection_monitoring;
GRANT SELECT ON public.predictions TO fraud_detection_monitoring;
GRANT SELECT ON public.model_versions TO fraud_detection_monitoring;
GRANT SELECT ON public.quarantined_payments TO fraud_detection_monitoring;
GRANT SELECT ON public.failed_payments TO fraud_detection_monitoring;

-- ...and writes only its results
GRANT USAGE ON SCHEMA monitoring TO fraud_detection_monitoring;
GRANT SELECT, INSERT ON monitoring.check_results TO fraud_detection_monitoring;

-- Power BI: read-only on the check results (possible quality page)
GRANT USAGE ON SCHEMA monitoring TO fraud_detection_bi;
GRANT SELECT ON monitoring.check_results TO fraud_detection_bi;

COMMIT;
