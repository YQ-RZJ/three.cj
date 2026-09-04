#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ============================================================================
# check_so_deps.py — 递归检索 .so 的层层依赖，输出依赖链路到 Markdown 文件
#
# 背景：排查 OHOS HAP / 跨平台 SDK 的 so 加载问题时，常需看清某个 .so 的
# 完整 DT_NEEDED 依赖链（如 libSDL3.so 依赖哪些系统库、libsdl4cj.sdl.so
# 依赖 libSDL3.so 的哪个 SONAME 别名），以及是否有依赖在当前搜索目录中
# 缺失（会导致运行时 dlopen 失败 / module not found）。
#
# 用法：
#   python check_so_deps.py --root libSDL3.so libsdl4cj.sdl.so \
#       --search-dirs entry/libs/arm64-v8a libs-link \
#       --output so_deps.md
#
# 选项：
#   --root         起始 so 文件（可多个，空格分隔）
#   --search-dirs  依赖库搜索目录（可多个；必填，不再做隐式兜底，按序查找）
#   --readelf      llvm-readelf 可执行文件路径（默认自动探测）
#   --output       输出 md 路径（默认 so_deps.md）
#   --max-depth    最大递归深度（默认 32，防止意外深链）
# ============================================================================
import argparse
import os
import re
import shutil
import subprocess
import sys
from typing import List, Optional

# 常见系统库（在搜索目录中找不到时标记为 system，而非 missing）。
# OHOS 平台这些库由系统提供，无需随 HAP 打包。
SYSTEM_LIBS = {
    "libc.so", "libdl.so", "libm.so", "libpthread.so", "librt.so", "liblog.so",
    "libEGL.so", "libGLESv3.so", "libGLESv2.so", "libGLESv1_CM.so",
    "libhilog_ndk.z.so", "libhilog.so",
    "libace_ndk.z.so", "libace_napi.z.so", "libace_napi.z.so",
    "librawfile.z.so", "libpixelmap_ndk.z.so", "libnative_window.so",
    "libohsensor.so", "libz.so", "libc++_shared.so", "libunwind.so",
    "libvulkan.so", "libopenharmony_ndk.so",
}


def find_readelf(explicit: Optional[str]) -> str:
    """定位 llvm-readelf：优先显式路径，其次 PATH 中 readelf / llvm-readelf。"""
    if explicit and os.path.isfile(explicit):
        return explicit
    for name in ("llvm-readelf", "readelf", "llvm-readelf.exe", "readelf.exe"):
        p = shutil.which(name)
        if p:
            return p
    # DevEco SDK 常见安装位置兜底
    for base in (
        r"D:/APPs/DevEco Studio/sdk/default/openharmony/native/llvm/bin",
        r"C:/Program Files/Huawei/DevEco Studio/sdk/default/openharmony/native/llvm/bin",
    ):
        cand = os.path.join(base, "llvm-readelf.exe")
        if os.path.isfile(cand):
            return cand
    sys.exit("未找到 llvm-readelf/readelf，请用 --readelf 指定路径")


def elf_dynamic(readelf: str, so_path: str) -> dict:
    """解析 ELF 动态段：返回 {"soname": str|None, "needed": [str,...]}。"""
    out = subprocess.run([readelf, "-d", "-W", so_path],
                         capture_output=True, text=True, errors="replace",
                         timeout=60).stdout
    soname = None
    needed = []
    for line in out.splitlines():
        m = re.search(r"\(SONAME\).*\[([^\]]+)\]", line)
        if m:
            soname = m.group(1)
            continue
        m = re.search(r"\(NEEDED\).*\[([^\]]+)\]", line)
        if m:
            needed.append(m.group(1))
    return {"soname": soname, "needed": needed}


def resolve_lib(name: str, search_dirs: List[str]) -> Optional[str]:
    """在搜索目录中按 文件名 / SONAME 别名 解析依赖库。"""
    for d in search_dirs:
        # 直接文件名（最常见：libSDL3.so）
        p = os.path.join(d, name)
        if os.path.isfile(p):
            return p
        # SONAME 别名常见形式：libfoo.so.0 / libfoo.so.0.1.2（真实文件）
        base = name
        for extra in ("", ".0", ".1", ".2", ".3"):
            for f in os.listdir(d) if os.path.isdir(d) else []:
                if f == base + extra and os.path.isfile(os.path.join(d, f)):
                    return os.path.join(d, f)
    return None


class DepTree:
    """依赖树节点：一个 so 文件（按路径去重）。"""

    def __init__(self, path: str):
        self.path = path
        self.soname = None
        self.children: list["DepTree"] = []
        self.missing: list[str] = []
        self.system: list[str] = []


def build_tree(root_path: str, search_dirs: List[str], readelf: str,
               max_depth: int) -> "DepTree":
    visited: dict[str, DepTree] = {}  # 真实路径 -> 节点（复用，防深链重复展开）
    on_stack: set[str] = set()        # 当前递归栈（循环检测）

    def walk(so_path: str, depth: int) -> DepTree:
        real = os.path.realpath(so_path)
        if real in visited:
            return visited[real]
        node = DepTree(real)
        visited[real] = node
        info = elf_dynamic(readelf, real)
        node.soname = info["soname"]
        if depth >= max_depth:
            node.missing.append(f"(max-depth {max_depth} 达到，停止展开)")
            return node
        on_stack.add(real)
        for name in info["needed"]:
            resolved = resolve_lib(name, search_dirs)
            if resolved is None:
                if name in SYSTEM_LIBS:
                    node.system.append(name)
                else:
                    node.missing.append(name)
                continue
            rreal = os.path.realpath(resolved)
            if rreal in on_stack:
                # 循环依赖：A -> B -> A，只挂一个占位说明，不再递归
                loop_node = DepTree(rreal)
                loop_node.soname = "(循环引用)"
                node.children.append(loop_node)
                continue
            node.children.append(walk(resolved, depth + 1))
        on_stack.discard(real)
        return node

    return walk(root_path, 0)


def render_md(root: DepTree, root_arg: str, search_dirs: list[str],
              readelf: str) -> str:
    lines: list[str] = []
    lines.append("# .so 依赖链路分析\n")
    lines.append(f"> 生成工具：`check_so_deps.py`\n")
    lines.append(f"> 起始文件：`{root_arg}`")
    lines.append(f"> 搜索目录：`{', '.join(search_dirs)}`")
    lines.append(f"> readelf：`{readelf}`\n")
    lines.append("## 依赖树\n")
    lines.append("```")

    def walk(node: DepTree, indent: int, seen_cycle: set[str]):
        mark = ""
        if node.soname and node.soname != os.path.basename(node.path):
            mark = f"  (SONAME: {node.soname})"
        lines.append("  " * indent + "|-- " + os.path.basename(node.path) + mark)
        for m in node.missing:
            lines.append("  " * (indent + 1) + "|-- [缺失] " + m)
        for s in node.system:
            lines.append("  " * (indent + 1) + "|-- [系统] " + s)
        for c in node.children:
            if c.soname == "(循环引用)":
                lines.append("  " * (indent + 1) + "|-- [循环] " + os.path.basename(c.path))
                continue
            walk(c, indent + 1, seen_cycle)

    walk(root, 0, set())
    lines.append("```\n")
    lines.append("## 缺失依赖汇总\n")
    missing_all: dict[str, list[str]] = {}
    seen: set[int] = set()

    def collect(node: DepTree):
        if id(node) in seen:
            return
        seen.add(id(node))
        for m in node.missing:
            missing_all.setdefault(m, []).append(os.path.basename(node.path))
        for c in node.children:
            collect(c)

    collect(root)
    if missing_all:
        lines.append("| 缺失库 | 被谁依赖 |")
        lines.append("|---|---|")
        for name in sorted(missing_all):
            lines.append(f"| `{name}` | {', '.join(sorted(set(missing_all[name])))} |")
    else:
        lines.append("（无缺失：所有依赖均已在搜索目录中解析，或属于系统库）\n")
    lines.append("")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser(description="递归检索 .so 依赖链并输出 Markdown")
    ap.add_argument("--root", nargs="+", required=True, help="起始 so 文件（可多个）")
    ap.add_argument("--search-dirs", nargs="+", default=[],
                    help="依赖库搜索目录（可多个）")
    ap.add_argument("--readelf", default=None, help="llvm-readelf 路径")
    ap.add_argument("--output", default="so_deps.md", help="输出 md 路径")
    ap.add_argument("--max-depth", type=int, default=32)
    args = ap.parse_args()

    readelf = find_readelf(args.readelf)
    # 库检索路径必须通过命令行显式传入（--search-dirs，可多个），不做隐式兜底
    search_dirs = [os.path.abspath(d) for d in args.search_dirs if os.path.isdir(d)]
    if not search_dirs:
        sys.exit("未提供有效的 --search-dirs 目录，请显式传入依赖库搜索路径（可多个）")

    chunks: list[str] = []
    for root_arg in args.root:
        root_arg = os.path.abspath(root_arg)
        if not os.path.isfile(root_arg):
            print(f"[WARN] 起始文件不存在，跳过: {root_arg}")
            continue
        tree = build_tree(root_arg, search_dirs, readelf, args.max_depth)
        chunks.append(render_md(tree, root_arg, search_dirs, readelf))

    if not chunks:
        sys.exit("没有可分析的起始文件")
    out = "\n\n---\n\n".join(chunks) + "\n"
    with open(args.output, "w", encoding="utf-8") as f:
        f.write(out)
    print(f"[OK] 依赖链已输出: {os.path.abspath(args.output)}")


if __name__ == "__main__":
    main()
