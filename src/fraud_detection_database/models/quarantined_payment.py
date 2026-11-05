import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import DateTime, String, Text, text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class QuarantinedPayment(Base):
    """Payment rejected by the input validation: the data is wrong.

    Not replayed automatically (it would be rejected again); reviewed
    then marked "reviewed". Holds non-personal fields only, and the
    validation errors without the rejected input values.
    """

    __tablename__ = "quarantined_payments"

    quarantine_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )

    source_trans_num: Mapped[str | None] = mapped_column(Text)

    card_id: Mapped[str | None] = mapped_column(String(64))

    payload: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)

    # [{"field": ..., "error": ...}]
    reasons: Mapped[list[dict[str, str]]] = mapped_column(JSONB, nullable=False)

    status: Mapped[str] = mapped_column(
        Text,
        nullable=False,
        server_default=text("'open'"),
    )

    quarantined_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("NOW()"),
    )

    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
