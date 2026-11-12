"""只读 SQLite 后端：校验数据库身份、加载记录与路由索引、读取压缩正文。"""

from __future__ import annotations

import atexit
import gzip
import json
import sqlite3
import zlib
from functools import lru_cache
from pathlib import Path

from .schema import APPLICATION_ID, ROUTING_ASSET, SCHEMA_VERSION


def decode_body(value: bytes, label: str) -> str:
    try:
        return zlib.decompress(value).decode("utf-8")
    except (zlib.error, UnicodeDecodeError) as exc:
        raise ValueError(f"corrupt compressed document {label}: {exc}") from exc


def decode_index(value: bytes) -> dict:
    try:
        return json.loads(gzip.decompress(value).decode("utf-8"))
    except (gzip.BadGzipFile, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ValueError(f"corrupt routing index in {ROUTING_ASSET}: {exc}") from exc


class SQLiteBackend:
    def __init__(self, skill_root: Path):
        self.skill_root = skill_root.resolve()
        self.database = self.skill_root / "references" / "knowledge.sqlite3"
        self._connection: sqlite3.Connection | None = None
        atexit.register(self.close)

    def connection(self) -> sqlite3.Connection:
        if self._connection is not None:
            return self._connection
        if not self.database.is_file():
            raise ValueError(f"knowledge database is missing: {self.database}")
        connection = sqlite3.connect(self.database.resolve().as_uri() + "?mode=ro&immutable=1", uri=True)
        connection.execute("PRAGMA query_only=ON")
        application_id = connection.execute("PRAGMA application_id").fetchone()[0]
        if application_id != APPLICATION_ID:
            connection.close()
            raise ValueError(f"not a three.cj-project-guide knowledge database: {self.database}")
        metadata = dict(connection.execute("SELECT key, value FROM meta"))
        if metadata.get("schema_version") != SCHEMA_VERSION:
            connection.close()
            raise ValueError(
                f"unsupported knowledge database schema {metadata.get('schema_version')!r}; "
                f"expected {SCHEMA_VERSION}"
            )
        self._connection = connection
        return connection

    def close(self) -> None:
        if self._connection is not None:
            self._connection.close()
            self._connection = None

    def meta(self) -> dict:
        return dict(self.connection().execute("SELECT key, value FROM meta ORDER BY key"))

    @lru_cache(maxsize=1)
    def load_records(self) -> list[dict]:
        rows = self.connection().execute(
            "SELECT rowid, doc_id, relpath, domain, package, kind, title, summary "
            "FROM documents ORDER BY rowid"
        ).fetchall()
        return [
            {
                "rowid": int(r[0]),
                "id": str(r[1]),
                "path": str(r[2]),
                "domain": str(r[3]),
                "package": str(r[4]),
                "kind": str(r[5]),
                "title": str(r[6]),
                "summary": str(r[7]),
            }
            for r in rows
        ]

    @lru_cache(maxsize=1)
    def load_routing_index(self) -> dict:
        row = self.connection().execute(
            "SELECT content FROM assets WHERE name=?", (ROUTING_ASSET,)
        ).fetchone()
        if row is None:
            raise ValueError(f"routing index asset is missing: {ROUTING_ASSET}")
        payload = decode_index(row[0])
        if payload.get("format") != 1 or not isinstance(payload.get("tokens"), dict):
            raise ValueError(f"invalid routing index schema in {ROUTING_ASSET}")
        return payload["tokens"]

    @lru_cache(maxsize=None)
    def load_page_content(self, rowid: int) -> str:
        row = self.connection().execute(
            "SELECT body_zlib FROM documents WHERE rowid=?", (rowid,)
        ).fetchone()
        if row is None:
            return ""
        return decode_body(row[0], f"rowid {rowid}")