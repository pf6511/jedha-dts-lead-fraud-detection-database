-- ============================================================
-- Full reset of the fraud detection database objects.
--
-- DESTRUCTIVE: drops every table of the project, with its data.
-- Run it only to rebuild the database from scratch, then run
-- 01_create_roles.sql, 02_create_tables.sql,
-- 03_create_daily_fraud_metrics.sql, 04_create_processing_tables.sql
-- and 05_create_monitoring.sql.
--
-- Roles are not dropped (they may own objects or be used by
-- running services); 01_create_roles.sql is idempotent.
-- ============================================================

BEGIN;

DROP SCHEMA IF EXISTS analytics CASCADE;
DROP SCHEMA IF EXISTS monitoring CASCADE;

DROP TABLE IF EXISTS public.failed_payments CASCADE;
DROP TABLE IF EXISTS public.quarantined_payments CASCADE;
DROP TABLE IF EXISTS public.predictions CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;
DROP TABLE IF EXISTS public.model_versions CASCADE;

-- Removed in the privacy refactoring: the full reference dataset,
-- with personal data, no longer lives in the operational database.
DROP TABLE IF EXISTS public.historical_transactions CASCADE;

COMMIT;
