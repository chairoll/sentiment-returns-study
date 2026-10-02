"""Create the SQLite database from the SQL files in /sql."""
from __future__ import annotations

import sqlite3
from pathlib import Path

SQL_DIR = Path(__file__).resolve().parents[3] / "sql"
SCHEMA_AND_VIEWS = [
    "schema.sql",
    "01_daily_sentiment.sql",
    "02_returns.sql",
    "03_lead_lag.sql",
]


def init_db(db_path: str | Path) -> sqlite3.Connection:
    """Create tables and views. Safe to call repeatedly."""
    conn = sqlite3.connect(str(db_path))
    conn.execute("PRAGMA foreign_keys = ON")
    for name in SCHEMA_AND_VIEWS:
        conn.executescript((SQL_DIR / name).read_text())
    conn.commit()
    return conn
