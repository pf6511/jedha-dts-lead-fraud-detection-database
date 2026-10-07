
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- Historical transactions
-- ============================================================

CREATE TABLE IF NOT EXISTS public.historical_transactions (
    trans_num              TEXT PRIMARY KEY,
    trans_date_trans_time  TIMESTAMP NOT NULL,
    cc_num                 TEXT NOT NULL,
    merchant               TEXT NOT NULL,
    category               TEXT NOT NULL,
    amt                    NUMERIC(12, 2) NOT NULL,
    first                   TEXT,
    last                    TEXT,
    gender                 TEXT,
    street                 TEXT,
    city                   TEXT,
    state                  TEXT,
    zip                    INTEGER,
    lat                    DOUBLE PRECISION,
    long                   DOUBLE PRECISION,
    city_pop                INTEGER,
    job                     TEXT,
    dob                     DATE,
    unix_time               BIGINT,
    merch_lat               DOUBLE PRECISION,
    merch_long              DOUBLE PRECISION,
    is_fraud                SMALLINT NOT NULL
);

-- ============================================================
-- Model versions
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


-- ============================================================
-- Transactions consumed by the real-time system
-- ============================================================

CREATE TABLE IF NOT EXISTS public.transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    source_trans_num TEXT NOT NULL,

    trans_date_trans_time TIMESTAMP NOT NULL,

    cc_num TEXT NOT NULL,
    merchant TEXT NOT NULL,
    category TEXT NOT NULL,
    amt NUMERIC(12, 2) NOT NULL,

    first TEXT,
    last TEXT,
    gender TEXT,

    street TEXT,
    city TEXT,
    state TEXT,
    zip INTEGER,

    lat DOUBLE PRECISION,
    long DOUBLE PRECISION,
    city_pop INTEGER,

    job TEXT,
    dob DATE,

    merch_lat DOUBLE PRECISION,
    merch_long DOUBLE PRECISION,

    is_fraud SMALLINT NOT NULL,

    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_transactions_source_trans_num
        FOREIGN KEY (source_trans_num)
        REFERENCES public.historical_transactions(trans_num)
);


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

    ground_truth SMALLINT,

    distance_km DOUBLE PRECISION,
    card_transaction_count INTEGER,
    card_fraud_count INTEGER,
    card_fraud_rate DOUBLE PRECISION,
    card_avg_amount NUMERIC(12, 2),

    CONSTRAINT fk_predictions_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES public.transactions(transaction_id),

    CONSTRAINT fk_predictions_model_version
        FOREIGN KEY (model_version_id)
        REFERENCES public.model_versions(model_version_id)
);


-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_transactions_cc_num
    ON public.transactions(cc_num);

CREATE INDEX IF NOT EXISTS idx_transactions_cc_num_timestamp
    ON public.transactions(cc_num, trans_date_trans_time);

CREATE INDEX IF NOT EXISTS idx_predictions_transaction_id
    ON public.predictions(transaction_id);

CREATE INDEX IF NOT EXISTS idx_predictions_model_version_id
    ON public.predictions(model_version_id);

CREATE INDEX IF NOT EXISTS idx_predictions_prediction_timestamp
    ON public.predictions(prediction_timestamp);

	

GRANT SELECT
ON public.historical_transactions
TO fraud_detection_app;

GRANT SELECT
ON public.model_versions
TO fraud_detection_app;

GRANT SELECT, INSERT
ON public.transactions
TO fraud_detection_app;

GRANT SELECT, INSERT
ON public.predictions
TO fraud_detection_app;