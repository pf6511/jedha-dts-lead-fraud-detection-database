from sqlalchemy import text

from fraud_detection_database.database import AdminSessionLocal


with AdminSessionLocal() as session:
    result = session.execute(
        text("SELECT current_database(), current_user")
    )

    database, user = result.one()

    print(f"Database: {database}")
    print(f"User: {user}")