import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

load_dotenv(Path(__file__).resolve().parents[2] / "secrets.env")

DATABASE_URL = os.environ["DATABASE_URL"]
ADMIN_DATABASE_URL =os.environ["ADMIN_DATABASE_URL"]

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)

admin_engine = create_engine(
    ADMIN_DATABASE_URL,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    expire_on_commit=False,
)

AdminSessionLocal = sessionmaker(
    bind=admin_engine,
    autoflush=False,
    expire_on_commit=False,
)