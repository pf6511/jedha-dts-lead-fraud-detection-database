from datetime import date, datetime

from sqlalchemy import BigInteger, Date, DateTime, Double, Integer, Numeric, SmallInteger, Text
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class HistoricalTransaction(Base):
    __tablename__ = "historical_transactions"

    trans_num: Mapped[str] = mapped_column(
        Text,
        primary_key=True,
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

    unix_time: Mapped[int | None] = mapped_column(BigInteger)

    merch_lat: Mapped[float | None] = mapped_column(Double)
    merch_long: Mapped[float | None] = mapped_column(Double)

    is_fraud: Mapped[int] = mapped_column(
        SmallInteger,
        nullable=False,
    )