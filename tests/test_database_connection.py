from sqlalchemy import text

from fraud_detection_database.database import Database
from fraud_detection_database.environment import Environment


def test_connection() -> None:
    environment = Environment("./secrets.env")
    database = Database(
        database_url=environment.env_var("DATABASE_URL"),
        admin_database_url=environment.env_var("ADMIN_DATABASE_URL"),
    )
    with database.engine.connect() as connection:
        result = connection.execute(
            text("SELECT current_database(), current_user")
        )

        database_name, user = result.one()

        print(f"Database: {database_name}")
        print(f"User: {user}")
