# -*- coding: utf-8 -*-
"""生成 test/three/src 目录下的文件目录清单或树状层级，并写入 .md 文件。

用法：
    python generate_structure.py --mode 1 [--root 目录] [-o 输出.md]
    python generate_structure.py --mode 2 [--root 目录] [-o 输出.md]
    python generate_structure.py --mode tree [--root 目录] [-o 输出.md]
    python generate_structure.py --mode list [--root 目录] [-o 输出.md]

--mode 支持数字(1/2)或名称(list/tree)，--root 默认指向本脚本同级的 src 目录。
默认输出：模式1 -> File List.md，模式2 -> Tree structure.md（可用 -o 覆盖）。
"""

import argparse
import os
import sys


def normalize_root(root: str) -> str:
    """将路径规范为绝对路径，并去掉结尾的路径分隔符。"""
    return os.path.normpath(os.path.abspath(root))


def to_posix(path: str) -> str:
    """将路径分隔符统一为 /。"""
    return path.replace(os.sep, "/")


def list_entries(root: str):
    """遍历 root 下所有条目（目录 + 文件），返回相对路径列表（排序后）。"""
    entries = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        filenames.sort()
        for name in dirnames:
            entries.append(to_posix(os.path.relpath(os.path.join(dirpath, name), root)))
        for name in filenames:
            entries.append(to_posix(os.path.relpath(os.path.join(dirpath, name), root)))
    entries.sort()
    return entries


def mode_checklist(root: str) -> str:
    """模式1：生成清单。"""
    lines = [""]
    for rel in list_entries(root):
        lines.append(f"- [ ] {rel}")
    return "\n".join(lines)


def mode_tree(root: str) -> str:
    """模式2：生成树状层级（带 ├── / └── / │ 连接线）。"""
    lines = [to_posix(os.path.basename(root.rstrip(os.sep))) + "/"]

    def walk(dirpath, prefix):
        items = sorted(os.listdir(dirpath), key=lambda n: (not os.path.isdir(os.path.join(dirpath, n)), n.lower()))
        for i, name in enumerate(items):
            path = os.path.join(dirpath, name)
            is_last = i == len(items) - 1
            connector = "└── " if is_last else "├── "
            suffix = "/" if os.path.isdir(path) else ""
            lines.append(prefix + connector + name + suffix)
            if os.path.isdir(path):
                child_prefix = prefix + ("    " if is_last else "│   ")
                walk(path, child_prefix)

    walk(root, "")
    return "\n".join(lines)


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description="生成 src 目录下的文件目录清单或树状层级",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "示例：\n"
            "  python generate_structure.py --mode 1\n"
            "  python generate_structure.py --mode 2\n"
            "  python generate_structure.py --mode tree --root D:/other/src\n"
        ),
    )
    parser.add_argument(
        "--mode",
        required=True,
        help="模式：1/list（清单）或 2/tree（树状层级）",
    )
    parser.add_argument(
        "--root",
        default=None,
        help="要扫描的根目录（默认：本脚本同级的 src 目录）",
    )
    parser.add_argument(
        "-o",
        "--output",
        default=None,
        help="输出 .md 文件路径（默认：模式1 -> File List.md，模式2 -> Tree structure.md）",
    )
    args = parser.parse_args(argv)

    # 归一化模式
    mode = args.mode.strip().lower()
    mode_map = {"1": "list", "list": "list", "2": "tree", "tree": "tree"}
    if mode not in mode_map:
        parser.error(f"无效的 --mode: {args.mode}（可选 1/list 或 2/tree）")
    args.mode = mode_map[mode]

    # 默认根目录：脚本同级的 src
    if args.root is None:
        args.root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "src")
    args.root = normalize_root(args.root)

    if not os.path.isdir(args.root):
        parser.error(f"目录不存在: {args.root}")

    # 默认输出文件
    if args.output is None:
        args.output = "File List.md" if args.mode == "list" else "Tree structure.md"
    args.output = normalize_root(args.output)

    return args


def main(argv=None):
    args = parse_args(argv if argv is not None else sys.argv[1:])
    output = mode_checklist(args.root) if args.mode == "list" else mode_tree(args.root)
    with open(args.output, "w", encoding="utf-8") as f:
        f.write(output + "\n")
    print(f"已生成: {args.output}")


if __name__ == "__main__":
    main()
