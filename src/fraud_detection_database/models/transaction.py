from datetime import date, datetime
import uuid

from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Date, DateTime, Double, Integer, Numeric, SmallInteger, Text
from sqlalchemy.orm import Mapped, mapped_column

from sqlalchemy import ForeignKey

from sqlalchemy import text

from .base import Base


class Transaction(Base):
    __tablename__ = "transactions"

    transaction_id: Mapped[uuid.UUID] = mapped_column(
    UUID(as_uuid=True),
    primary_key=True,
    server_default=text("gen_random_uuid()"),
)

    source_trans_num: Mapped[str] = mapped_column(
        Text,
        ForeignKey("historical_transactions.trans_num"),
        nullable=False,
    )

    trans_date_trans_time: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
    )

    cc_num: Mapped[str] = mapped_column(
        Text,
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

    first: Mapped[str | None] = mapped_column(Text)
    last: Mapped[str | None] = mapped_column(Text)
    gender: Mapped[str | None] = mapped_column(Text)

    street: Mapped[str | None] = mapped_column(Text)
    city: Mapped[str | None] = mapped_column(Text)
    state: Mapped[str | None] = mapped_column(Text)

    zip: Mapped[int | None] = mapped_column(Integer)

    lat: Mapped[float | None] = mapped_column(Double)
    long: Mapped[float | None] = mapped_column(Double)

    city_pop: Mapped[int | None] = mapped_column(Integer)

    job: Mapped[str | None] = mapped_column(Text)
    dob: Mapped[date | None] = mapped_column(Date)

    merch_lat: Mapped[float | None] = mapped_column(Double)
    merch_long: Mapped[float | None] = mapped_column(Double)

    is_fraud: Mapped[int] = mapped_column(
        SmallInteger,
        nullable=False,
    )

    received_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
    )