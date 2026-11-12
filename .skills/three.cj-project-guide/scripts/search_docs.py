#!/usr/bin/env python3
"""查询 three.cj-project-guide 的 SQLite 知识库。

支持三种视图：
  matches  —— 关键词/符号批量摘要查询（默认）
  indexes  —— 浏览解析出的子树（包/域）下的全部非叶子页
  leaves   —— 批量读取解析出的页面正文
"""

from __future__ import annotations

import argparse
import math
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
FILE_ROOT = Path(__file__).resolve().parent
SCRIPT_ROOT = FILE_ROOT if (FILE_ROOT / "kb_engine").is_dir() else FILE_ROOT.parent
sys.path.insert(0, str(SCRIPT_ROOT))

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

from kb_engine import SQLiteBackend
from kb_engine.schema import DEFAULT_MAX_CHARS, DEFAULT_MAX_PAGES
from kb_engine.tokenizer import tokenize

SKILL_ROOT = SCRIPT_ROOT.parent


# ---------- 解析与目录 ----------

def resolve_nodes(spec, records, records_by_id, records_by_path, records_by_title, package_map):
    """把 --node 说明解析为记录列表（精确 -> 包/域子树）。"""
    spec = spec.strip().strip('"').strip("'").strip()
    if spec == "*":
        return list(records)
    key = spec if spec.startswith("pkg:") else None
    if key is not None:
        return package_map.get(key[4:], [])
    if spec in records_by_id:
        return [records_by_id[spec]]
    if spec in records_by_path:
        return [records_by_path[spec]]
    if spec in records_by_title:
        return [records_by_title[spec]]
    if spec in package_map:
        return package_map[spec]
    if spec.startswith("domain:"):
        domain = spec[7:]
        return [r for r in records if r["domain"] == domain]
    return []


def resolve_query_batch_tolerant(queries, catalog, args):
    """把多个查询并行解析；坏查询仅产生警告，不丢弃有效节点。"""
    records, by_id, by_path, by_title, package_map = catalog
    roots, warnings = [], []
    for q in queries:
        q = q.strip().strip('"').strip("'").strip()
        if not q:
            continue
        hits = resolve_nodes(q, records, by_id, by_path, by_title, package_map)
        if not hits:
            # 包名写错但近似存在时提示
            candidates = [
                p for p in package_map
                if p and (q in p or p in q or any(w in p for w in q.split()))
            ][:5]
            hint = f"，近似包: {', '.join(candidates)}" if candidates else ""
            warnings.append(f"未解析节点: {q!r}{hint}")
            continue
        roots.extend(hits)
    return roots, warnings


# ---------- 匹配检索 ----------

def compact_search(query, records, index, args):
    """基于路由索引打分，返回 (record, score) 排序列表。"""
    terms = list(set(t for t in tokenize(query) if t))
    if not terms:
        return []
    scores: dict[int, int] = {}
    for term in terms:
        entries = index.get(term)
        if not entries:
            continue
        for rowid, sig_hits, body_hits in entries:
            # 标题/摘要高权重；正文词频对数衰减，抑制长条目对排序的干扰
            scores[rowid] = scores.get(rowid, 0) + sig_hits * 8 + int(4 * math.log1p(body_hits))
    by_rowid = {r["rowid"]: r for r in records}
    for rowid, rec in by_rowid.items():
        if rowid not in scores:
            continue
        title_low = rec["title"].lower()
        title_tokens = set(tokenize(rec["title"]))
        for term in terms:
            if title_low == term:
                scores[rowid] += 60  # 精确符号名 优先
            elif term in title_tokens:
                scores[rowid] += 25  # 符号名包含查询词（如 Box3Helper 含 Box3）
    candidates = sorted(scores.items(), key=lambda kv: (-kv[1], kv[0]))
    result = []
    for rowid, score in candidates:
        rec = by_rowid.get(rowid)
        if rec is None:
            continue
        if args.domain and rec["domain"] not in args.domain:
            continue
        if args.package and not any(pkg in rec["package"] for pkg in args.package):
            continue
        if args.kind and rec["kind"] not in args.kind:
            continue
        result.append((rec, score))
        if len(result) >= args.max_results * 3:  # 过滤后再截断
            break
    return result[: args.max_results]


# ---------- 渲染 ----------

def render_matches(groups, args):
    lines = []
    seen = set()
    for query, hits in groups:
        if not hits:
            lines.append(f"## [无结果] {query}")
            lines.append("  无匹配。尝试缩短查询、改用符号全名，或加 --view indexes 浏览包。")
            continue
        lines.append(f"## {query}")
        for rec, score in hits:
            key = (rec["rowid"],)
            if key in seen:
                lines.append(f"  (同上) {rec['id']} [{rec['kind']}] {rec['title']}")
                continue
            seen.add(key)
            lines.append(f"  [{rec['kind']:13s}] {rec['id']}")
            lines.append(f"       {rec['title']}{' —— ' + short_summary(rec['summary']) if rec['summary'] else ''}")
            lines.append(f"       <{rec['path']}>  score={score}")
        lines.append("")
    return "\n".join(lines).rstrip()


def render_indexes(records, query, args):
    lines = [f"## {query} —— 子树（{len(records)} 页）"]
    if not records:
        lines.append("  (空)")
        return "\n".join(lines)
    rows = sorted(records, key=lambda r: (r["kind"], r["title"]))
    for rec in rows:
        if rec["kind"] == "readme":
            lines.append(f"  📄 [readme] {rec['id']}")
            continue
        lines.append(
            f"  - [{rec['kind']:13s}] {rec['title']}  ——  {short_summary(rec['summary'], 60)}"
        )
    return "\n".join(lines)


def render_leaves(records, args):
    lines = []
    total = 0
    for rec in records:
        body = backend().load_page_content(rec["rowid"])
        total += len(body)
        if args.estimate:
            lines.append(f"## {rec['id']}  ({len(body)} 字符)")
            continue
        lines.append(f"== {rec['id']}  [{rec['kind']}] ==")
        lines.append(f"== 源: {rec['path']}  (域={rec['domain']}, 包={rec['package']}) ==")
        lines.append("")
        lines.append(body.rstrip())
        lines.append("\n" + "-" * 60)
    if args.estimate:
        lines.append(f"\n预计 {total} 字符 / {len(records)} 页。")
    return "\n".join(lines)


def short_summary(text, limit=120):
    text = " ".join(text.split())
    return text if len(text) <= limit else text[: limit - 1] + "…"


_backend = None


def backend():
    global _backend
    if _backend is None:
        _backend = SQLiteBackend(SKILL_ROOT)
    return _backend


# ---------- CLI ----------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Search the three.cj knowledge base.")
    parser.add_argument("query", nargs="*", help="Words, symbol, or node path")
    parser.add_argument("--query", dest="batch_queries", action="append", default=[],
                        help="Independent compact query; repeat to batch lookups in one process")
    parser.add_argument("--domain", action="append", default=[],
                        help="Filter domain: api/references/guide/all; repeatable")
    parser.add_argument("--kind", action="append", default=[],
                        help="Filter kind: class/interface/enum/struct/function/macro/alias/constants/readme/page/...; repeatable")
    parser.add_argument("--package", action="append", default=[],
                        help="Filter package substring, e.g. three.core.math; repeatable")
    parser.add_argument("--max-results", type=int, default=5, help="Maximum results per query, 1-30 (default: 5)")
    parser.add_argument("--view", choices=("matches", "indexes", "leaves"), default="matches",
                        help="matches: compact search; indexes/leaves: pages in a resolved subtree")
    parser.add_argument("--node", action="append", default=[],
                        help="Exact id/path/title, package, or domain:xxx to resolve; repeat to combine")
    parser.add_argument("--depth", type=int, help="Ignored (three.cj knowledge base is two-level)")
    parser.add_argument("--estimate", action="store_true", help="With --view leaves, report sizes only")
    parser.add_argument("--max-pages", type=int, default=DEFAULT_MAX_PAGES, help="Expansion page limit")
    parser.add_argument("--max-chars", type=int, default=DEFAULT_MAX_CHARS, help="Expansion character limit")
    parser.add_argument("--force", action="store_true", help="Allow expansion beyond limits")
    return parser.parse_args()


def main() -> int:
    started = time.perf_counter()
    args = parse_args()
    if not 1 <= args.max_results <= 30:
        raise SystemExit("--max-results must be between 1 and 30")
    if args.depth is not None and args.depth < 0:
        raise SystemExit("--depth must be zero or greater")
    if args.max_pages < 1:
        raise SystemExit("--max-pages must be at least 1")
    if args.max_chars < 1:
        raise SystemExit("--max-chars must be at least 1")

    records = backend().load_records()
    by_id = {r["id"]: r for r in records}
    by_path = {r["path"]: r for r in records}
    by_title = {r["title"]: r for r in records if r["title"]}
    package_map: dict[str, list] = {}
    for r in records:
        package_map.setdefault(r["package"], []).append(r)
    catalog = (records, by_id, by_path, by_title, package_map)

    positional = " ".join(args.query).strip()
    queries = ([positional] if positional else []) + [q.strip() for q in args.batch_queries if q.strip()]

    try:
        if args.view == "matches":
            if args.node:
                raise ValueError("--node requires --view indexes or --view leaves")
            if not queries:
                raise ValueError("query must contain at least one word")
            index = backend().load_routing_index()
            groups = []
            for q in queries:
                hits = compact_search(q, records, index, args)
                if args.estimate:
                    print(f"{q}: {len(hits)} 命中候选")
                groups.append((q, hits))
            output = render_matches(groups, args)
            print(output + ("" if output.endswith("\n") else "\n"))
        else:
            roots, warnings = resolve_query_batch_tolerant(queries, catalog, args)
            for node in args.node:
                roots.extend(resolve_nodes(node, records, by_id, by_path, by_title, package_map))
            if not roots:
                raise SystemExit(
                    "未解析到任何节点。可用: 精确 id/路径/标题、包名（如 three.core.math）、"
                    "domain:api / domain:references / domain:guide，或 --query 锁定符号。"
                )
            for w in warnings:
                print(f"[warn] {w}")
            total_chars = sum(len(backend().load_page_content(r["rowid"])) for r in roots)
            if len(roots) > args.max_pages and not args.force:
                raise SystemExit(
                    f"展开 {len(roots)} 页超过 --max-pages {args.max_pages} 上限；"
                    f"缩小 --node（如具体包）或使用 --force。"
                )
            if total_chars > args.max_chars and not args.force:
                raise SystemExit(
                    f"展开约 {total_chars} 字符超过 --max-chars {args.max_chars} 上限；"
                    f"改查单个符号或使用 --force。"
                )
            if args.view == "indexes":
                print(render_indexes(roots, queries[0] if queries else "子树", args))
            else:
                print(render_leaves(roots, args))
    except ValueError as exc:
        raise SystemExit(str(exc)) from exc

    if args.depth == 0 and args.view != "matches":
        pass
    print(f"\n# 检索耗时 {(time.perf_counter() - started) * 1000:.0f} ms", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())