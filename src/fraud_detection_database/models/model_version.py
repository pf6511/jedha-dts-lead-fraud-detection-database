import uuid
from datetime import datetime

from sqlalchemy import DateTime, Double, Text, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class ModelVersion(Base):
    __tablename__ = "model_versions"

    model_version_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )

    model_name: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    model_version: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    run_id: Mapped[str | None] = mapped_column(
        Text,
    )

    model_uri: Mapped[str | None] = mapped_column(
        Text,
    )

    threshold: Mapped[float | None] = mapped_column(
        Double,
    )

    feature_version: Mapped[str | None] = mapped_column(
        Text,
    )

    registered_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("NOW()"),
        nullable=False,
    )