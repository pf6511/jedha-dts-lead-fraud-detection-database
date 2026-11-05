-- ============================================================
-- Processing control tables (quality control and error correction)
--
-- quarantined_payments  payments rejected by the input validation:
--                       the DATA is wrong. Not replayed automatically
--                       (replaying would give the same rejection);
--                       reviewed, then marked reviewed.
--
-- failed_payments       valid payments whose processing failed after
--                       retries (inference API, MLflow, database...):
--                       the PROCESSING failed. Replayable.
--
-- Privacy by design: both tables only hold minimised data (no card
-- number, no name, address, date of birth, gender or coordinates).
-- Validation errors are stored without the rejected input values.
--
-- Run after 02_create_tables.sql. Idempotent.
-- ============================================================

BEGIN;

-- ============================================================
-- Quarantine: invalid input data
-- ============================================================

CREATE TABLE IF NOT EXISTS public.quarantined_payments (
    quarantine_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- May be missing or invalid: that can be the reason of the rejection
    source_trans_num TEXT,

    -- Pseudonym, when the card number was usable
    card_id CHAR(64),

    -- Non-personal fields of the payment, as received
    payload JSONB NOT NULL,

    -- Validation errors: [{"field": ..., "error": ...}], no input values
    reasons JSONB NOT NULL,

    status TEXT NOT NULL DEFAULT 'open',

    quarantined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ,

    CONSTRAINT chk_quarantined_payments_card_id
        CHECK (card_id IS NULL OR card_id ~ '^[0-9a-f]{64}$'),

    CONSTRAINT chk_quarantined_payments_status
        CHECK (status IN ('open', 'reviewed'))
);

COMMENT ON TABLE public.quarantined_payments IS
    'Payments rejected by the input validation (invalid data); minimised data only';

-- ============================================================
-- Failed processing: valid data, technical failure, replayable
-- ============================================================

CREATE TABLE IF NOT EXISTS public.failed_payments (
    failure_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- One row per source payment: a failed replay updates the same row
    source_trans_num TEXT NOT NULL,

    card_id CHAR(64) NOT NULL,
    trans_date_trans_time TIMESTAMP NOT NULL,

    -- Minimised payment (allow-listed columns), enough to replay it
    payload JSONB NOT NULL,

    -- Where and why it failed (last attempt)
    failed_step TEXT NOT NULL,
    error_type TEXT NOT NULL,
    error_message TEXT,

    -- Processing attempts: first processing + replays
    attempts INTEGER NOT NULL DEFAULT 1,

    status TEXT NOT NULL DEFAULT 'pending',

    first_failed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_failed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,

    CONSTRAINT uq_failed_payments_source_trans_num
        UNIQUE (source_trans_num),

    CONSTRAINT chk_failed_payments_card_id
        CHECK (card_id ~ '^[0-9a-f]{64}$'),

    CONSTRAINT chk_failed_payments_attempts
        CHECK (attempts >= 1),

    CONSTRAINT chk_failed_payments_status
        CHECK (status IN ('pending', 'replayed', 'discarded')),

    -- A resolved failure has a resolution time, a pending one has none
    CONSTRAINT chk_failed_payments_resolution
        CHECK ((status = 'pending') = (resolved_at IS NULL))
);

COMMENT ON TABLE public.failed_payments IS
    'Valid payments whose processing failed after retries; replayable; minimised data only';

-- ============================================================
-- Indexes
-- ============================================================

-- Replay: pending failures, oldest first
CREATE INDEX IF NOT EXISTS idx_failed_payments_status_time
    ON public.failed_payments(status, first_failed_at);

-- Monitoring and retention purge
CREATE INDEX IF NOT EXISTS idx_quarantined_payments_time
    ON public.quarantined_payments(quarantined_at);

-- ============================================================
-- Privileges
-- ============================================================

-- Processor: quarantines and records failures; the replay updates the
-- status of a failure. Still no delete.
GRANT SELECT, INSERT ON public.quarantined_payments TO fraud_detection_app;
GRANT SELECT, INSERT, UPDATE ON public.failed_payments TO fraud_detection_app;

-- Admin: monitoring (DAG), review of the quarantine
GRANT SELECT, UPDATE ON public.quarantined_payments TO fraud_detection_admin;
GRANT SELECT ON public.failed_payments TO fraud_detection_admin;

COMMIT;
