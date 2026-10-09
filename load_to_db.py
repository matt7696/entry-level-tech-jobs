import json
import os
from pathlib import Path

import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
    host="localhost",
    port=5433,
    dbname=os.environ["POSTGRES_DB"],
    user=os.environ["POSTGRES_USER"],
    password=os.environ["POSTGRES_PASSWORD"],
)

CREATE_TABLE = """
CREATE TABLE IF NOT EXISTS postings (
    company     text   NOT NULL,
    job_id      bigint NOT NULL,
    title       text,
    location    text,
    url         text,
    updated_at  timestamptz,
    content     text,
    raw         jsonb,
    loaded_at   timestamptz DEFAULT now(),
    PRIMARY KEY (company, job_id)
);
"""

UPSERT = """
INSERT INTO postings (company, job_id, title, location, url, updated_at, content, raw)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
ON CONFLICT (company, job_id) DO UPDATE SET
    title = EXCLUDED.title,
    location = EXCLUDED.location,
    url = EXCLUDED.url,
    updated_at = EXCLUDED.updated_at,
    content = EXCLUDED.content,
    raw = EXCLUDED.raw,
    loaded_at = now();
"""

with conn:
    with conn.cursor() as cur:
        cur.execute(CREATE_TABLE)

        # sorted so newer snapshots are loaded last and win
        for path in sorted(Path("data/raw").glob("*.json")):
            company = path.stem.rsplit("_", 2)[0]
            with open(path, encoding="utf-8") as f:
                data = json.load(f)

            for job in data["jobs"]:
                cur.execute(
                    UPSERT,
                    (
                        company,
                        job["id"],
                        job.get("title"),
                        (job.get("location") or {}).get("name"),
                        job.get("absolute_url"),
                        job.get("updated_at"),
                        job.get("content"),
                        Json(job),
                    ),
                )
            print(f"{company}: loaded {len(data['jobs'])} jobs from {path.name}")

conn.close()