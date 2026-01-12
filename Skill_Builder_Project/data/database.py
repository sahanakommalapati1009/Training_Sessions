import sqlite3
from pathlib import Path

DB_PATH = Path("skill_builder.db")


def get_conn():
    return sqlite3.connect(DB_PATH)


def init_db():
    conn = get_conn()
    cur = conn.cursor()

    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS progress_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            topic TEXT NOT NULL,
            score INTEGER NOT NULL,
            total INTEGER NOT NULL,
            percent REAL NOT NULL
        )
        """
    )

    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS saved_notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            topic TEXT NOT NULL,
            subtopics_json TEXT NOT NULL,
            notes_json TEXT NOT NULL
        )
        """
    )


    conn.commit()
    conn.close()

def save_progress(item: dict):
    conn = get_conn()
    cur = conn.cursor()

    cur.execute(
        """
        INSERT INTO progress_log (timestamp, topic, score, total, percent)
        VALUES (?, ?, ?, ?, ?)
        """,
        (
            item["timestamp"],
            item["topic"],
            int(item["score"]),
            int(item["total"]),
            float(item["percent"]),
        ),
    )

    conn.commit()
    conn.close()


def load_progress() -> list:
    conn = get_conn()
    cur = conn.cursor()

    cur.execute(
        """
        SELECT timestamp, topic, score, total, percent
        FROM progress_log
        ORDER BY id DESC
        """
    )

    rows = cur.fetchall()
    conn.close()

    items = []
    for (timestamp, topic, score, total, percent) in rows:
        items.append(
            {
                "timestamp": timestamp,
                "topic": topic,
                "score": score,
                "total": total,
                "percent": percent,
            }
        )

    return items

def save_notes(item: dict):
    conn = get_conn()
    cur = conn.cursor()

    cur.execute(
        """
        INSERT INTO saved_notes (timestamp, topic, subtopics_json, notes_json)
        VALUES (?, ?, ?, ?)
        """,
        (
            item["timestamp"],
            item["topic"],
            item["subtopics_json"],
            item["notes_json"],
        ),
    )

    conn.commit()
    conn.close()

def load_saved_notes() -> list:
    conn = get_conn()
    cur = conn.cursor()

    cur.execute(
        """
        SELECT id, timestamp, topic, subtopics_json, notes_json
        FROM saved_notes
        ORDER BY id DESC
        """
    )

    rows = cur.fetchall()
    conn.close()

    items = []
    for (id, timestamp, topic, subtopics_json, notes_json) in rows:
        items.append(
            {
                "id": id,
                "timestamp": timestamp,
                "topic": topic,
                "subtopics_json": subtopics_json,
                "notes_json": notes_json,
            }
        )

    return items
