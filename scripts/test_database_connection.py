from sqlalchemy import text

from fraud_detection_database.database import engine


def test_connection() -> None:
    with engine.connect() as connection:
        result = connection.execute(
            text("SELECT current_database(), current_user")
        )

        database, user = result.one()

        print(f"Database: {database}")
        print(f"User: {user}")


if __name__ == "__main__":
    test_connection()