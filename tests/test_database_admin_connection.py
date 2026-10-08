from sqlalchemy import text

from fraud_detection_database.database import Database
from fraud_detection_database.environment import Environment


def test_permissions() -> None:
    environment = Environment("./secrets.env")
    database = Database(
        database_url=environment.env_var("DATABASE_URL"),
        admin_database_url=environment.env_var("ADMIN_DATABASE_URL"),
    )
    with database.admin_engine.connect() as connection:
        result = connection.execute(
            text("SELECT current_database(), current_user")
        )

        database, user = result.one()

        print(f"Database: {database}")
        print(f"User: {user}")
