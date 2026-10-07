import uuid
from datetime import datetime

from sqlalchemy import DateTime, Double, ForeignKey, Integer, Numeric, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class Prediction(Base):
    __tablename__ = "predictions"

    prediction_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )

    transaction_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("transactions.transaction_id"),
        nullable=False,
    )

    model_version_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("model_versions.model_version_id"),
        nullable=False,
    )

    prediction_timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("NOW()"),
        nullable=False,
    )

    fraud_probability: Mapped[float | None] = mapped_column(
        Double,
    )

    fraud_prediction: Mapped[bool | None] = mapped_column()

    ground_truth: Mapped[int | None] = mapped_column(
        Integer,
    )

    distance_km: Mapped[float | None] = mapped_column(
        Double,
    )

    card_transaction_count: Mapped[int | None] = mapped_column(
        Integer,
    )

    card_fraud_count: Mapped[int | None] = mapped_column(
        Integer,
    )

    card_fraud_rate: Mapped[float | None] = mapped_column(
        Double,
    )

    card_avg_amount: Mapped[float | None] = mapped_column(
        Numeric(12, 2),
    )