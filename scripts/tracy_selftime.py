# -*- coding: utf-8 -*-
"""按 zone 还原嵌套关系，输出调用次数 / 总耗时 / 自耗时（扣除子区间）。

用法：
    python scripts/tracy_selftime.py captures/run1/events.jsonl [TopN] [引擎源码根目录]

背景：
    stats.json 里的 zone 总耗时包含所有子区间，无法区分"这一层自己慢"与
    "子层慢"。本脚本按每条 zone 事件的 (起始时刻, 时长, 线程) 还原嵌套
    栈，得到每个 zone 的自耗时——定位引擎自身开销时以自耗时为准。

    部分采集里客户端上报的 zone 名字符串会失效（显示成 0x 地址）。事件流中
    源位置行号仍然完好，故脚本扫描引擎源码里的 @Zone 声明建立
    "声明行号 -> zone 名"映射，用它给失效的名字兜底。
"""

import collections
import json
import os
import re
import sys

ZONE_ATTR = re.compile(r"@Zone\[([^\]]*)\]")
FUNC_LINE = re.compile(r"\bfunc\b")
LINK_LAST = re.compile(r"three\.[A-Za-z0-9_.]*?\.([A-Za-z0-9_]+)\s*$")


def scan_zone_names(src_root):
    """扫描源码里的 @Zone 声明，返回 {声明行号: zone 显示名} 与 {声明行号: 链路}。"""
    by_line = {}
    for dirpath, _dirs, files in os.walk(src_root):
        for fn in files:
            if not fn.endswith(".cj"):
                continue
            path = os.path.join(dirpath, fn)
            with open(path, encoding="utf-8", errors="replace") as f:
                lines = f.read().splitlines()
            for i, line in enumerate(lines):
                m = ZONE_ATTR.search(line)
                if not m:
                    continue
                attr = m.group(1)
                link = attr.split(",")[0].strip()
                name = ""
                nm = re.search(r"name\s*=\s*([A-Za-z0-9_]+)", attr)
                if nm:
                    name = nm.group(1)
                else:
                    lm = LINK_LAST.search(link)
                    name = lm.group(1) if lm else link
                # 函数声明行 = @Zone 之后第一个含 func 的行
                for j in range(i + 1, min(i + 4, len(lines))):
                    if FUNC_LINE.search(lines[j]):
                        by_line.setdefault(j + 1, name)
                        break
    return by_line


def looks_like_name(text):
    """名字是否为可读标识符（非 0x 地址形式）。"""
    if not text or text.startswith("0x"):
        return False
    return all(ch.isalnum() or ch in "_." for ch in text)


def load_events(path):
    """读取 events.jsonl 中的 zone 事件，返回 (start, end, dur, fn, line, thread)。"""
    events = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            if '"k":"zone"' not in line:
                continue
            try:
                e = json.loads(line)
            except ValueError:
                continue
            if e.get("k") != "zone":
                continue
            dur = e.get("d", 0.0)
            start = e.get("t", 0.0)
            name = e.get("fn") or e.get("n") or "?"
            ln = e.get("ln", 0)
            events.append((start, start + dur, dur, name, ln, e.get("th", 0)))
    return events


def analyze(events):
    """按线程还原嵌套，返回 (count, total, self_ns)。

    聚合键用 "名字@行号"：同名不同处的 zone（如三个 render）不会混在一起。
    """
    events.sort(key=lambda x: (x[5], x[0], x[1]))

    count = collections.Counter()
    total = collections.Counter()
    self_ns = collections.Counter()

    stack = []       # (start, end, key, child_sum)
    cur_thread = None

    def close(entry):
        s, e, key, child = entry
        self_ns[key] += (e - s) - child

    for (start, end, dur, name, ln, thread) in events:
        key = "%s@%s" % (name, ln)
        if thread != cur_thread:
            while stack:
                close(stack.pop())
            cur_thread = thread
        while stack and stack[-1][1] <= start:
            entry = stack.pop()
            close(entry)
            if stack:
                ps, pe, pf, pc = stack[-1]
                stack[-1] = (ps, pe, pf, pc + (entry[1] - entry[0]))
        count[key] += 1
        total[key] += dur
        stack.append((start, end, key, 0.0))

    while stack:
        entry = stack.pop()
        close(entry)
        if stack:
            ps, pe, pf, pc = stack[-1]
            stack[-1] = (ps, pe, pf, pc + (entry[1] - entry[0]))

    return count, total, self_ns


def main():
    if len(sys.argv) < 2:
        print("usage: tracy_selftime.py <events.jsonl> [topN] [src_root]")
        return 1
    path = sys.argv[1]
    top_n = int(sys.argv[2]) if len(sys.argv) > 2 else 25
    src_root = sys.argv[3] if len(sys.argv) > 3 else None

    line_map = scan_zone_names(src_root) if src_root else {}

    events = load_events(path)
    # 名字失效的 zone 用行号映射兜底
    fixed = 0
    renamed = []
    for ev in events:
        if not looks_like_name(ev[3]) and ev[4] in line_map:
            ev = (ev[0], ev[1], ev[2], line_map[ev[4]], ev[4], ev[5])
            fixed += 1
        renamed.append(ev)
    events = renamed
    if fixed:
        print("[info] 用源码行号修复了 %d 个 zone 名" % fixed)

    count, total, self_ns = analyze(events)

    print("%-38s %8s %12s %11s %12s %11s" % (
        "zone@line", "count", "total(ms)", "mean(us)", "self(ms)", "self(us)"))
    print("-" * 100)
    ranked = sorted(total.items(), key=lambda kv: -kv[1])[:top_n]
    for key, tot in ranked:
        cnt = count[key]
        print("%-38s %8d %12.3f %11.2f %12.3f %11.2f" % (
            key[:38], cnt, tot / 1e6, tot / cnt / 1e3,
            self_ns[key] / 1e6, self_ns[key] / cnt / 1e3))
    return 0


if __name__ == "__main__":
    sys.exit(main())
