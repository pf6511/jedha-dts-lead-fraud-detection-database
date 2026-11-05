import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import DateTime, Integer, String, Text, text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base

# Values of the status column
PENDING = "pending"
REPLAYED = "replayed"
DISCARDED = "discarded"


class FailedPayment(Base):
    """Valid payment whose processing failed after retries: replayable.

    One row per source payment: a failed replay updates the same row
    (attempts, last error). Holds the minimised payment only.
    """

    __tablename__ = "failed_payments"

    failure_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )

    source_trans_num: Mapped[str] = mapped_column(Text, nullable=False, unique=True)

    card_id: Mapped[str] = mapped_column(String(64), nullable=False)

    trans_date_trans_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)

    # Minimised payment (allow-listed columns), enough to replay it
    payload: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)

    failed_step: Mapped[str] = mapped_column(Text, nullable=False)
    error_type: Mapped[str] = mapped_column(Text, nullable=False)
    error_message: Mapped[str | None] = mapped_column(Text)

    attempts: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        server_default=text("1"),
    )

    status: Mapped[str] = mapped_column(
        Text,
        nullable=False,
        server_default=text(f"'{PENDING}'"),
    )

    first_failed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("NOW()"),
    )

    last_failed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("NOW()"),
    )

    resolved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
