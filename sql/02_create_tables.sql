-- ============================================================
-- Operational tables (schema public)
--
-- Privacy by design: no card number, no name, no address, no date
-- of birth, no coordinates. Transactions are minimised by the
-- processor (fraud_detection_features.privacy) BEFORE being stored.
-- ============================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- gen_random_uuid()

-- ============================================================
-- Model versions (mirror of the MLflow registry)
-- ============================================================

CREATE TABLE IF NOT EXISTS public.model_versions (
    model_version_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    model_name TEXT NOT NULL,
    model_version TEXT NOT NULL,

    run_id TEXT,
    model_uri TEXT,

    threshold DOUBLE PRECISION,
    feature_version TEXT,

    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_model_versions_name_version
        UNIQUE (model_name, model_version)
);

COMMENT ON COLUMN public.model_versions.feature_version IS
    'Feature set of the model (MLflow run parameter feature_set), '
    'e.g. card_history_v3_privacy';

-- ============================================================
-- Transactions consumed by the real-time system
-- ============================================================

CREATE TABLE IF NOT EXISTS public.transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identifier of the transaction in the source (payment API).
    -- Unique: a payment read twice is stored once (deduplication).
    source_trans_num TEXT NOT NULL,

    -- Transaction time (current_time of the payment API)
    trans_date_trans_time TIMESTAMP NOT NULL,

    -- Pseudonymised card: HMAC-SHA256 of the card number with a secret
    -- key. The card number itself is never stored (PCI-DSS).
    card_id CHAR(64) NOT NULL,

    -- Last four digits, for display only (alerts, investigation)
    pan_last4 CHAR(4) NOT NULL,

    merchant TEXT NOT NULL,
    category TEXT NOT NULL,
    amt NUMERIC(12, 2) NOT NULL,

    city_pop INTEGER,
    state TEXT,
    job TEXT,

    -- Label provided by the payment API (simulated confirmed fraud)
    is_fraud SMALLINT NOT NULL,

    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_transactions_source_trans_num
        UNIQUE (source_trans_num),

    CONSTRAINT chk_transactions_card_id
        CHECK (card_id ~ '^[0-9a-f]{64}$'),

    CONSTRAINT chk_transactions_pan_last4
        CHECK (pan_last4 ~ '^[0-9]{4}$'),

    CONSTRAINT chk_transactions_amt
        CHECK (amt > 0),

    CONSTRAINT chk_transactions_is_fraud
        CHECK (is_fraud IN (0, 1))
);

COMMENT ON TABLE public.transactions IS
    'Minimised transactions: no card number, no direct identifier, '
    'no quasi-identifier, no coordinates';
COMMENT ON COLUMN public.transactions.card_id IS
    'HMAC-SHA256 pseudonym of the card number (secret key outside the database)';
COMMENT ON COLUMN public.transactions.pan_last4 IS
    'Last four digits of the card number, display only';

-- ============================================================
-- Predictions
-- ============================================================

CREATE TABLE IF NOT EXISTS public.predictions (
    prediction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    transaction_id UUID NOT NULL,
    model_version_id UUID NOT NULL,

    prediction_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    fraud_probability DOUBLE PRECISION,
    fraud_prediction BOOLEAN,

    -- Confirmed label, used to monitor precision and recall in production
    ground_truth SMALLINT,

    -- Snapshot of the features sent to the model
    distance_km DOUBLE PRECISION,
    card_transaction_count INTEGER,
    card_fraud_count INTEGER,
    card_fraud_rate DOUBLE PRECISION,
    card_avg_amount NUMERIC(12, 2),

    CONSTRAINT uq_predictions_transaction_id
        UNIQUE (transaction_id),

    CONSTRAINT fk_predictions_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES public.transactions(transaction_id),

    CONSTRAINT fk_predictions_model_version
        FOREIGN KEY (model_version_id)
        REFERENCES public.model_versions(model_version_id),

    CONSTRAINT chk_predictions_probability
        CHECK (fraud_probability IS NULL OR fraud_probability BETWEEN 0 AND 1)
);

-- ============================================================
-- Indexes
-- ============================================================

-- Card history (processor): transactions of a card before a time
CREATE INDEX IF NOT EXISTS idx_transactions_card_id_time
    ON public.transactions(card_id, trans_date_trans_time);

-- Daily extraction (DAG) and retention purge
CREATE INDEX IF NOT EXISTS idx_transactions_received_at
    ON public.transactions(received_at);

CREATE INDEX IF NOT EXISTS idx_predictions_model_version_id
    ON public.predictions(model_version_id);

CREATE INDEX IF NOT EXISTS idx_predictions_prediction_timestamp
    ON public.predictions(prediction_timestamp);

-- ============================================================
-- Privileges
-- ============================================================

-- Real-time processor: reads history and model versions, inserts
-- transactions and predictions. No update, no delete.
GRANT SELECT ON public.model_versions TO fraud_detection_app;
GRANT SELECT, INSERT ON public.transactions TO fraud_detection_app;
GRANT SELECT, INSERT ON public.predictions TO fraud_detection_app;

-- Admin: registers model versions (training), reads transactions
-- and predictions (analytics DAG).
GRANT SELECT, INSERT ON public.model_versions TO fraud_detection_admin;
GRANT SELECT ON public.transactions TO fraud_detection_admin;
GRANT SELECT ON public.predictions TO fraud_detection_admin;

COMMIT;
