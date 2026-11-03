import uuid
from datetime import datetime

from sqlalchemy import DateTime, Integer, Numeric, SmallInteger, String, Text, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class Transaction(Base):
    """Minimised transaction consumed by the real-time system.

    No card number, no direct identifier (name, address), no
    quasi-identifier (date of birth, city, zip, gender), no coordinates:
    the processor minimises the payment (fraud_detection_features.privacy)
    before building this object.
    """

    __tablename__ = "transactions"

    transaction_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )

    # Identifier of the transaction in the payment API (unique: deduplication)
    source_trans_num: Mapped[str] = mapped_column(
        Text,
        nullable=False,
        unique=True,
    )

    trans_date_trans_time: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
    )

    # HMAC-SHA256 pseudonym of the card number
    card_id: Mapped[str] = mapped_column(
        String(64),
        nullable=False,
    )

    # Last four digits of the card number, display only
    pan_last4: Mapped[str] = mapped_column(
        String(4),
        nullable=False,
    )

    merchant: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    category: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    amt: Mapped[float] = mapped_column(
        Numeric(12, 2),
        nullable=False,
    )

    city_pop: Mapped[int | None] = mapped_column(Integer)
    state: Mapped[str | None] = mapped_column(Text)
    job: Mapped[str | None] = mapped_column(Text)

    # Label provided by the payment API (simulated confirmed fraud)
    is_fraud: Mapped[int] = mapped_column(
        SmallInteger,
        nullable=False,
    )

    received_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("NOW()"),
    )
