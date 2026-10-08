from sqlalchemy import text

from fraud_detection_database.database import Database
from fraud_detection_database.environment import Environment


def test_permissions() -> None:
    environment = Environment("./secrets.env")
    database = Database(
        database_url=environment.env_var("DATABASE_URL"),
        admin_database_url=environment.env_var("ADMIN_DATABASE_URL"),
    )
    with database.engine.connect() as connection:
        result = connection.execute(
            text("""
                SELECT
                    table_name,
                    privilege_type
                FROM information_schema.role_table_grants
                WHERE grantee = current_user
                ORDER BY table_name, privilege_type
            """)
        )

        for table_name, privilege_type in result:
            print(f"{table_name}: {privilege_type}")

