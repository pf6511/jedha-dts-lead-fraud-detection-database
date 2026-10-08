from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session


class Database:
    def __init__(
        self,
        database_url: str,
        admin_database_url: str,
    ):
        self.engine = create_engine(
            database_url,
            pool_pre_ping=True,
        )

        self.admin_engine = create_engine(
            admin_database_url,
            pool_pre_ping=True,
        )

        self.SessionLocal = sessionmaker(
            bind=self.engine,
            autoflush=False,
            expire_on_commit=False,
        )

        self.AdminSessionLocal = sessionmaker(
            bind=self.admin_engine,
            autoflush=False,
            expire_on_commit=False,
        )