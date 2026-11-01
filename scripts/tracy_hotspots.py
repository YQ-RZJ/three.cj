# -*- coding: utf-8 -*-
"""格式化 tracy 采集结果 stats.json，打印帧统计与热点 Top N。

用法：
    python scripts/tracy_hotspots.py captures/run1/stats.json [标签] [TopN]
"""

import json
import sys


def main():
    if len(sys.argv) < 2:
        print("usage: tracy_hotspots.py <stats.json> [label] [topN]")
        return 1

    path = sys.argv[1]
    label = sys.argv[2] if len(sys.argv) > 2 else "run"
    top_n = int(sys.argv[3]) if len(sys.argv) > 3 else 25

    with open(path, encoding="utf-8") as f:
        stats = json.load(f)

    frame = stats.get("frame", {})
    print("")
    print("==== [%s] frames=%s mean=%.2fms p50=%.2fms p95=%.2fms p99=%.2fms ====" % (
        label,
        frame.get("count"),
        frame.get("mean_ms", 0),
        frame.get("p50_ms", 0),
        frame.get("p95_ms", 0),
        frame.get("p99_ms", 0),
    ))
    print("%-30s %8s %12s %11s %11s %11s" % (
        "zone", "count", "total(ms)", "mean(us)", "p50(us)", "p95(us)"))
    print("-" * 88)

    zones = sorted(stats.get("zones", []),
                   key=lambda z: z.get("total_ns", 0), reverse=True)[:top_n]
    for z in zones:
        print("%-30s %8d %12.3f %11.2f %11.2f %11.2f" % (
            z.get("name", "")[:30],
            z.get("count", 0),
            z.get("total_ns", 0) / 1e6,
            z.get("mean_ns", 0) / 1e3,
            z.get("p50_ns", 0) / 1e3,
            z.get("p95_ns", 0) / 1e3,
        ))

    errors = stats.get("errors", [])
    if errors:
        print("")
        print("errors: %d" % len(errors))
        for e in errors[:5]:
            print("  - %s" % e)
    return 0


if __name__ == "__main__":
    sys.exit(main())
