#!/usr/bin/env python3
"""重建 three.cj-project-guide 的 SQLite 知识库（references/knowledge.sqlite3）。

用法:
  python scripts/build_kb.py --source <project-root>          # 默认 --source 为 skill 的上级上级目录
  python scripts/build_kb.py --source . --check               # 只报告与库内快照的差异，不写库
构建结果：全量 markdown 正文 (zlib 压缩) + 中英文路由索引，单文件、可分享。
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import re
import sqlite3
import sys
import zlib
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

sys.dont_write_bytecode = True
SCRIPT_ROOT = Path(__file__).resolve().parent
if (SCRIPT_ROOT / "kb_engine").is_dir():
    sys.path.insert(0, str(SCRIPT_ROOT))
from kb_engine.schema import AGGREGATE_STEMS, APPLICATION_ID, KIND_BY_DIR, ROUTING_ASSET, SCHEMA_VERSION  # noqa: E402
from kb_engine.tokenizer import tokenize  # noqa: E402

DEFAULT_SKILL_ROOT = Path(__file__).resolve().parent.parent
EXCLUDE_DIRS = {
    "target", ".git", ".github", ".skills", ".cache", ".vscode",
    "node_modules", "__pycache__", ".venv", "dist", "build", "out",
}
EXCLUDE_RELPREFIX = {"doc/api/en/"}  # 英文 API 文档为 zh-cn 的冗余副本，不建索引
KIND_BY_DIR_EN = {k: v for v, k in [("class", "Class"), ("interface", "Interface"),
                                    ("enum", "Enum"), ("struct", "Struct"),
                                    ("function", "Function"), ("macro", "Macro"),
                                    ("alias", "Type Alias"), ("constants", "Variables & constants")]}

_LINK = re.compile(r"\[([^\]]*)\]\([^)]*\)")


# ---------- md 文本分析 ----------

def extract_summary(body: str) -> str:
    buf: list[str] = []
    headings: list[str] = []
    in_code = False
    for raw in body.splitlines():
        s = raw.strip()
        if s.startswith("```"):
            in_code = not in_code
            continue
        if in_code:
            continue
        if s.startswith("#"):
            if buf:
                break
            headings.append(s.lstrip("#").strip())
            continue
        if not s:
            if buf:
                break
            continue
        if s.startswith(("|", ">", "-", "*", "<!--")):
            continue
        cleaned = _LINK.sub(r"\1", s)
        cleaned = cleaned.replace("`", "").strip("*").strip()
        if cleaned:
            buf.append(cleaned)
            if len(buf) >= 2:
                break
    if buf:
        return " ".join(" ".join(buf).split())[:300]
    return "；".join(h for h in headings[:3] if h)[:300]


# ---------- 文档分类 ----------

def classify_md(rel: str) -> dict | None:
    if any(rel.startswith(p) for p in EXCLUDE_RELPREFIX):
        return None
    parts = [p for p in rel.replace("\\", "/").split("/") if p]
    stem = Path(rel).stem
    if len(parts) >= 3 and parts[0] == "doc" and parts[1] == "api":
        pkg = parts[3] if len(parts) > 3 else parts[1]
        rest = parts[4:]
        if not rest:
            return {"domain": "api", "package": pkg, "kind": "readme",
                    "title": f"包 {pkg}", "id": f"pkg:{pkg}"}
        if len(rest) == 1:
            if stem in AGGREGATE_STEMS:
                kind = AGGREGATE_STEMS[stem]
                return {"domain": "api", "package": pkg, "kind": kind,
                        "title": f"{pkg} · {stem}", "id": f"{pkg}/{kind}"}
            if stem in KIND_BY_DIR_EN:
                kind = KIND_BY_DIR_EN[stem]
                return {"domain": "api", "package": pkg, "kind": kind + "-list",
                        "title": f"{pkg} · {stem}", "id": f"{pkg}/{kind}-list"}
            return {"domain": "api", "package": pkg, "kind": "readme",
                    "title": f"包 {pkg}", "id": f"pkg:{pkg}"}
        kind = KIND_BY_DIR.get(rest[0], KIND_BY_DIR_EN.get(rest[0], "page"))
        return {"domain": "api", "package": pkg, "kind": kind,
                "title": stem, "id": f"{pkg}/{kind}:{stem}"}
    if len(parts) >= 3 and parts[0] == "doc" and parts[1] == "references":
        sub = parts[2]
        return {"domain": "references", "package": f"references/{sub}", "kind": "page",
                "title": stem, "id": f"ref:{stem}"}
    top = parts[0] if parts else "root"
    prefix = "/".join(parts[:-1]) + ("/" if len(parts) > 1 else "")
    return {"domain": "guide", "package": top, "kind": "page",
            "title": stem, "id": f"{prefix}{stem}"}


# ---------- 数据库写入 ----------

def build_database(source_root: Path, out_path: Path, quiet: bool = False) -> dict:
    source_root = source_root.resolve()
    files = []
    total_chars = 0
    for md in sorted(source_root.rglob("*.md")):
        rel = md.relative_to(source_root).as_posix()
        if any(part in EXCLUDE_DIRS for part in Path(rel).parts):
            continue
        if any(rel.startswith(p) for p in EXCLUDE_RELPREFIX):
            continue
        files.append((rel, md))
    if not files:
        raise SystemExit(f"--source 下未发现 markdown 文件: {source_root}")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    tmp = out_path.with_suffix(".sqlite3.tmp")
    if tmp.exists():
        tmp.unlink()
    conn = sqlite3.connect(tmp)
    conn.execute("PRAGMA application_id=%d" % APPLICATION_ID)
    conn.executescript(
        """
        CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
        CREATE TABLE documents (
          rowid INTEGER PRIMARY KEY,
          doc_id TEXT UNIQUE NOT NULL,
          relpath TEXT NOT NULL,
          domain TEXT NOT NULL,
          package TEXT NOT NULL,
          kind TEXT NOT NULL,
          title TEXT NOT NULL,
          summary TEXT NOT NULL DEFAULT '',
          body_zlib BLOB NOT NULL,
          body_chars INTEGER NOT NULL
        );
        CREATE INDEX idx_documents_relpath ON documents(relpath);
        CREATE INDEX idx_documents_package ON documents(package);
        CREATE INDEX idx_documents_domain ON documents(domain);
        CREATE TABLE assets (name TEXT PRIMARY KEY, content BLOB NOT NULL);
        """
    )

    routing: dict[str, list] = {}
    cursor = conn.cursor()
    for rel, md in files:
        body = md.read_text(encoding="utf-8", errors="replace")
        meta = classify_md(rel)
        if meta is None:
            continue
        total_chars += len(body)
        sig_text = f"{meta['title']} {meta['package']} {extract_summary(body)}"
        sig_counts = Counter(tokenize(sig_text))
        body_counts = Counter(tokenize(body))
        sig_hits = {t: int(c) for t, c in sig_counts.items()}
        body_hits = {t: int(c) for t, c in body_counts.items()}
        all_tokens = set(sig_hits) | set(body_hits)
        cursor.execute(
            "INSERT INTO documents (doc_id, relpath, domain, package, kind, title, summary, body_zlib, body_chars) "
            "VALUES (?,?,?,?,?,?,?,?,?)",
            (meta["id"], rel, meta["domain"], meta["package"], meta["kind"],
             meta["title"], extract_summary(body),
             zlib.compress(body.encode("utf-8"), 9), len(body)),
        )
        rowid = cursor.lastrowid
        for tok in all_tokens:
            routing.setdefault(tok, []).append([rowid, sig_hits.get(tok, 0), body_hits.get(tok, 0)])
    for tok in routing:
        routing[tok].sort()
    conn.execute(
        "INSERT INTO assets (name, content) VALUES (?,?)",
        (ROUTING_ASSET, gzip.compress(json.dumps({"format": 1, "tokens": routing}, ensure_ascii=False).encode("utf-8"), 9)),
    )
    now = datetime.now(timezone.utc).isoformat(timespec="seconds")
    connection_mtime = max(md.stat().st_mtime for _, md in files)
    meta_rows = {
        "schema_version": SCHEMA_VERSION,
        "source_root": str(source_root),
        "built_at": now,
        "file_count": str(len(files)),
        "total_chars": str(total_chars),
        "newest_mtime": str(connection_mtime),
    }
    conn.executemany("INSERT INTO meta (key, value) VALUES (?,?)", list(meta_rows.items()))
    conn.commit()
    conn.close()
    tmp.replace(out_path)
    if not quiet:
        print(f"已重建 {out_path}")
        print(f"  来源: {source_root}  md 文件 {len(files)} 个, 正文 {total_chars} 字符, 索引词 {len(routing)} 个")
    return meta_rows


def check_drift(source_root: Path, out_path: Path) -> int:
    files = []
    for md in sorted(source_root.resolve().rglob("*.md")):
        rel = md.relative_to(source_root).as_posix()
        if any(part in EXCLUDE_DIRS for part in Path(rel).parts):
            continue
        if any(rel.startswith(p) for p in EXCLUDE_RELPREFIX):
            continue
        files.append(md)
    if not out_path.is_file():
        print(f"[不存在] 知识库 {out_path} 缺失，需要重建")
        return 1
    conn = sqlite3.connect(out_path.resolve().as_uri() + "?mode=ro&immutable=1", uri=True)
    meta = dict(conn.execute("SELECT key, value FROM meta"))
    conn.close()
    current = {"count": len(files), "newest_mtime": max(md.stat().st_mtime for md in files)}
    stale = (
        current["count"] != int(meta.get("file_count", "0"))
        or abs(float(current["newest_mtime"]) - float(meta.get("newest_mtime", "0"))) > 1
    )
    if stale:
        print(f"[过期] 当前 {current['count']} 个文件 vs 库内 {meta.get('file_count')} 个；"
              f"库构建于 {meta.get('built_at')}，请执行 build_kb.py 重建")
        return 2
    print(f"[最新] {current['count']} 个文件与库内快照一致（构建于 {meta.get('built_at')}）")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Rebuild the three.cj-project-guide knowledge base.")
    parser.add_argument("--source", type=Path, default=DEFAULT_SKILL_ROOT.parent.parent,
                        help="markdown 源目录（默认: skill 上级上级目录）")
    parser.add_argument("--out", type=Path, default=DEFAULT_SKILL_ROOT / "references" / "knowledge.sqlite3",
                        help="输出 sqlite 路径")
    parser.add_argument("--check", action="store_true", help="只报告与库内快照的差异，不重建")
    parser.add_argument("--quiet", action="store_true", help="构建时不输出统计")
    args = parser.parse_args()
    if args.check:
        return check_drift(args.source, args.out)
    build_database(args.source, args.out, quiet=args.quiet)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())