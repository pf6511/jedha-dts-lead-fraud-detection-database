-- ============================================================
-- Quality control and error correction tables
--
-- quarantined_payments  payments rejected by the input validation:
--                       the data is wrong, they are not replayed.
--
-- failed_payments       valid payments whose processing failed
--                       (inference API, database...): they can be
--                       replayed (status pending -> replayed).
--
-- Both tables hold no personal data: no card number, no name,
-- address, date of birth, gender or coordinates.
--
-- Run after 02_create_tables.sql. Idempotent.
-- ============================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.quarantined_payments (
    quarantine_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    source_trans_num TEXT,              -- may be missing in a wrong payment
    payload JSONB NOT NULL,             -- non-personal fields, as received
    reason TEXT NOT NULL,               -- validation errors, without the values

    quarantined_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.failed_payments (
    failure_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    source_trans_num TEXT NOT NULL UNIQUE,
    payload JSONB NOT NULL,             -- minimised payment, used to replay it

    failed_step TEXT NOT NULL,          -- step of the last failure
    error TEXT NOT NULL,                -- last error
    attempts INTEGER NOT NULL DEFAULT 1,

    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'replayed')),

    failed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    replayed_at TIMESTAMPTZ
);

-- Processor: writes both tables; the replay updates failed_payments
GRANT SELECT, INSERT ON public.quarantined_payments TO fraud_detection_app;
GRANT SELECT, INSERT, UPDATE ON public.failed_payments TO fraud_detection_app;

-- Admin: monitoring (next chantier)
GRANT SELECT ON public.quarantined_payments TO fraud_detection_admin;
GRANT SELECT ON public.failed_payments TO fraud_detection_admin;

COMMIT;
