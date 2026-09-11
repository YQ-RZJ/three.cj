#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@file[zh-cn] add_license_header.py 文件级 LICENSE 头注释自动追加脚本
@brief[zh-cn] 对 src/**/*.cj 源文件的文件首 /**...*/ 文档注释块追加 @LICENSE 信息

功能说明：
- 遍历指定目录（默认 src/）下所有 *.cj 文件；
- 若文件首部存在 `/** ... */` 文档注释块：
  - 若块内已含 `@LICENSE`，跳过（幂等，可重复执行）；
  - 否则将 LICENSE 信息块插入该注释块内部的最前面（@file 之前），保持注释块完整；
- 若文件首部没有 `/**` 注释块（例如以 `package` 开头）：
  - 在文件最顶部新建一个只含 LICENSE 信息的 `/** ... */` 注释块；
- 自动跳过 UTF-8 BOM（部分历史文件带 BOM，处理后保持其余内容原样）；
- 除插入的注释行外，不修改文件的任何其它内容（含行尾风格 CRLF/LF、编码）。

用法：
    python scripts/add_license_header.py              # 处理 src/ 目录
    python scripts/add_license_header.py --root src   # 同上（显式指定）
    python scripts/add_license_header.py --dry-run    # 只统计不写入

@file[en] add_license_header.py Auto-append LICENSE header comment script
@brief[en] Prepend @LICENSE info into the leading /**...*/ doc block of src/**/*.cj files

Usage:
    python scripts/add_license_header.py
    python scripts/add_license_header.py --dry-run
"""

import argparse
import os
import re
import sys

# LICENSE 信息块：插入注释块内部最前面（不含块本身的 /** 与 */ 包装）
LICENSE_BODY = """ * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *"""

# 新建注释块时的包装（文件原本没有 /** 块时使用）
LICENSE_BLOCK = "/**\n" + LICENSE_BODY + "\n */\n"

# 文件首 /** 块（允许前导空白/BOM 之后立刻出现）
BLOCK_START_RE = re.compile(r"^(\ufeff)?[ \t]*/\*\*")


def detect_eol(text: str) -> str:
    """检测文件主行尾风格（CRLF 优先），保证插入行与原文件一致。"""
    return "\r\n" if "\r\n" in text else "\n"


def normalize_license(eol: str) -> str:
    """按目标行尾风格生成 LICENSE 正文。"""
    return eol.join(LICENSE_BODY.split("\n"))


def process_file(path: str, dry_run: bool) -> str:
    """
    处理单个文件。
    返回动作：'skipped'（已含 @LICENSE）、'inserted'（插入到既有块）、
    'prepended'（新建注释块）、'empty'（空文件）。
    """
    with open(path, "rb") as f:
        raw = f.read()

    has_bom = raw.startswith(b"\xef\xbb\xbf")
    text = raw[len(b"\xef\xbb\xbf") if has_bom else 0:].decode("utf-8")
    if not text.strip():
        return "empty"

    eol = detect_eol(text)
    license_body = normalize_license(eol)

    # 情况 1：文件首部存在 /** 文档注释块
    m = BLOCK_START_RE.match(text)
    if m:
        close_idx = text.find("*/", m.end())
        if close_idx != -1:
            block = text[m.end():close_idx]
            if "@LICENSE" in block:
                return "skipped"
            # 插入点：/** 所在行的行尾之后（保持 "/**" 独占一行的格式），
            # LICENSE 正文作为块内最前面的行插入，其后不留空行（与 @file 紧凑衔接）
            line_end = text.find(eol, m.end())
            insert_at = (line_end + len(eol)) if line_end != -1 else m.end()
            new_text = text[:insert_at] + license_body + eol + text[insert_at:]
            if not dry_run:
                write_back(path, new_text, has_bom)
            return "inserted"

    # 情况 2：文件首部无 /** 块 → 在文件最顶部新建
    if "@LICENSE" in text[:2000]:
        return "skipped"
    license_block = eol.join(LICENSE_BLOCK.split("\n"))
    new_text = license_block + text
    if not dry_run:
        write_back(path, new_text, has_bom)
    return "prepended"


def write_back(path: str, text: str, has_bom: bool) -> None:
    """按原 BOM 状态写回文件。"""
    data = text.encode("utf-8")
    if has_bom:
        data = b"\xef\xbb\xbf" + data
    with open(path, "wb") as f:
        f.write(data)


def main() -> int:
    parser = argparse.ArgumentParser(description="为 src/**/*.cj 追加 LICENSE 文件头注释")
    parser.add_argument("--root", default="src", help="扫描根目录（默认 src）")
    parser.add_argument("--dry-run", action="store_true", help="只统计不写入")
    args = parser.parse_args()

    if not os.path.isdir(args.root):
        print(f"错误：目录不存在 {args.root}")
        return 1

    stats = {"skipped": 0, "inserted": 0, "prepended": 0, "empty": 0}
    total = 0
    for root, _dirs, files in os.walk(args.root):
        for fn in sorted(files):
            if not fn.endswith(".cj"):
                continue
            total += 1
            path = os.path.join(root, fn)
            action = process_file(path, args.dry_run)
            stats[action] += 1
            if action in ("inserted", "prepended"):
                print(f"[{action:>9}] {path}")

    print(f"\n总计 {total} 个 .cj 文件："
          f"插入 {stats['inserted']}，新建块 {stats['prepended']}，"
          f"已含跳过 {stats['skipped']}，空文件 {stats['empty']}"
          + ("（dry-run，未写入）" if args.dry_run else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
