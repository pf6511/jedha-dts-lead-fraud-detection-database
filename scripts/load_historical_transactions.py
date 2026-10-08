from pathlib import Path

import pandas as pd
from sqlalchemy import insert


from fraud_detection_database.database import Database
from fraud_detection_database.environment import Environment

from fraud_detection_database.models import HistoricalTransaction

from typing import Any, cast

def create_database_engine():
    environment = Environment("./secrets.env")
    return Database(
        database_url=environment.env_var("DATABASE_URL"),
        admin_database_url=environment.env_var("ADMIN_DATABASE_URL"),
    )

def prepare_historical_transactions(dtf: pd.DataFrame) -> pd.DataFrame:
    dtf = dtf.copy()

    dtf["trans_date_trans_time"] = pd.to_datetime(
        dtf["trans_date_trans_time"]
    )

    dtf["dob"] = pd.to_datetime(
        dtf["dob"]
    ).dt.date

    dtf["cc_num"] = dtf["cc_num"].astype(str)

    return dtf

def load_historical_transactions(
    csv_path: Path,
) -> None:
    """Load historical transactions from CSV into PostgreSQL."""

    # 1. Read CSV
    dtf = pd.read_csv(csv_path)

    print(f"Loaded {len(dtf)} rows from {csv_path}")

    # 2. Prepare data types
    dtf = prepare_historical_transactions(dtf)

    # 3. Convert DataFrame to records
    records = cast(
        list[dict[str, Any]],
        dtf.to_dict("records"),
    )

    # 4. Bulk insert commit or rollback if exception
    with create_database_engine().AdminSessionLocal() as session:
        with session.begin():
            session.execute(
                insert(HistoricalTransaction),
                records,
            )

    print(f"Inserted {len(records)} historical transactions")


if __name__ == "__main__":
    csv_path = Path("data/fraudTest.csv")

    load_historical_transactions(csv_path)