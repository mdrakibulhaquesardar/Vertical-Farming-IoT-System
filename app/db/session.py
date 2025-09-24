from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
import os


class Base(DeclarativeBase):
    pass


def build_db_url() -> str:
    db_url = os.getenv("DB_URL")
    if db_url:
        return db_url
    # Fallback to compose defaults
    user = os.getenv("MYSQL_USER", "vfarm")
    password = os.getenv("MYSQL_PASSWORD", "vfarm_pass")
    host = os.getenv("MYSQL_HOST", "127.0.0.1")
    port = os.getenv("MYSQL_PORT", "3306")
    database = os.getenv("MYSQL_DATABASE", "vertical_farm")
    return f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}"


engine = create_engine(build_db_url(), pool_pre_ping=True, pool_recycle=3600)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
