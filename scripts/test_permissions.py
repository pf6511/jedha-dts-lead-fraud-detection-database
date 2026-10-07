from sqlalchemy import text

from fraud_detection_database.database import SessionLocal


def test_permissions() -> None:
    with SessionLocal() as session:
        result = session.execute(
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


if __name__ == "__main__":
    test_permissions()