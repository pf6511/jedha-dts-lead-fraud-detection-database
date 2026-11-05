import uuid
from datetime import datetime

from sqlalchemy import DateTime, Integer, Text, text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class FailedPayment(Base):
    """Valid payment whose processing failed; replayable (pending -> replayed)."""

    __tablename__ = "failed_payments"

    failure_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )

    source_trans_num: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    payload: Mapped[dict] = mapped_column(JSONB, nullable=False)

    failed_step: Mapped[str] = mapped_column(Text, nullable=False)
    error: Mapped[str] = mapped_column(Text, nullable=False)
    attempts: Mapped[int] = mapped_column(Integer, nullable=False, server_default=text("1"))

    status: Mapped[str] = mapped_column(Text, nullable=False, server_default=text("'pending'"))

    failed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("NOW()"),
    )
    replayed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
