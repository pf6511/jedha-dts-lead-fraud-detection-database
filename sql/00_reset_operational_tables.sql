-- ============================================================
-- Reset of the operational data, KEEPING public.model_versions.
--
-- Use it to migrate an existing database to the privacy-by-design
-- schema while keeping the history of model versions (mirror of
-- the MLflow registry, including deprecated versions).
--
-- For an installation from scratch, use 00_drop_all.sql instead.
--
-- DESTRUCTIVE for transactions, predictions, quarantine, failures
-- and analytics: their data is lost. Then run 01_create_roles.sql,
-- 02_create_tables.sql, 03_create_daily_fraud_metrics.sql and
-- 04_create_processing_tables.sql: model_versions, whose structure
-- is unchanged, is kept as is (CREATE TABLE IF NOT EXISTS).
-- ============================================================

BEGIN;

DROP SCHEMA IF EXISTS analytics CASCADE;

DROP TABLE IF EXISTS public.failed_payments CASCADE;
DROP TABLE IF EXISTS public.quarantined_payments CASCADE;
DROP TABLE IF EXISTS public.predictions CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;

-- Removed in the privacy refactoring: the full reference dataset,
-- with personal data, no longer lives in the operational database.
DROP TABLE IF EXISTS public.historical_transactions CASCADE;

COMMIT;
