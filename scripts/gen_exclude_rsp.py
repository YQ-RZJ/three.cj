#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_exclude_rsp.py — 生成跨平台链接符号控制文件：
  * three/libs/exclude.rsp     （Windows MinGW ld.lld response file）
  * three/libs/symbols_elf.map （Linux/OHOS ld.lld、GNU ld --version-script）

背景
----
cjpm 构建 three 时每个仓颉子包链接为独立动态库（Windows .dll / Linux、OHOS .so）。
第三方仓颉 FFI 包（bgfx4cj/sdl4cj/jolt4cj 等）以静态归档链接进各动态库：
- Windows：MinGW flavor ld.lld 下，第三方 mangled 符号（_CGP 包初始化、_CN 函数等）
  被 --export-all-symbols 自动导出，下游 dll 链接时同一符号既解析为上游导入 thunk
  又从本地静态归档得到定义，ld.lld 报 "symbol was replaced"。
- Linux/OHOS：ELF 链接不报错，但同一符号会被各 .so 重复导出，形成多份代码副本与
  包初始化多副本，运行时依赖 symbol interposition 收敛，遇 hidden visibility /
  -Bsymbolic 等情形存在状态分裂风险。
C++ 静态库（libbgfx.a/libJolt.a/libstdc++.a 等）的 _Z* 内部符号同理。

两个产物的语义同构
------------------
1. exclude.rsp（Windows）：
   - --exclude-symbols：第三方仓颉 mangled 符号（_C 开头且含包名）+ 全部 C++ _Z* 符号，
     禁止自动导出，消除 "symbol was replaced"；
   - -u <C API 符号>：仓颉 FFI 归档未定义引用（U）∩ C 库归档定义的非 _Z 符号，
     强制拓扑最早的 dll 全量拉入并导出 C API（bgfx_*/SDL_*/JPH_*/al*/ig*/lua_* 等），
     下游 dll 经 IAT 解析到同一定义，保证 bgfx g_ctx、OpenAL current context 等
     C 库全局状态跨 dll 单例共享。
   （MinGW flavor ld.lld 不支持 --exclude-libs/--version-script，只支持
     --exclude-symbols <逗号列表> 与 @response 文件。）
2. symbols_elf.map（Linux/OHOS）：
   - local: _Z* 与 _C*<第三方包名>* —— 不进入动态符号表（.so 内部仍可使用本地静态副本）；
   - 其余符号默认全局导出：three 自身符号（_C*three*）保证子包 .so 间互访，
     C API 保持全局导出，下游 .so 经动态绑定（UND）解析到同一定义，C 库全局状态单例。

何时需要重新运行
----------------
- 第三方依赖增减/升级（cjpm.toml dependencies 变化，或 cjpm update 拉取新版
  bgfx4cj/jolt4cj/sdl4cj/...）后；
- libs/ 下 C/C++ 静态库重新编译/升级后；
- Windows 链接重新出现 "symbol was replaced" / undefined symbol 时。
three 引擎自身源码变更不需要重新生成（three 自身符号不在排除/本地化列表）。

前提
----
先成功执行过一次 `cjpm build`（依赖包归档 target/release/<pkg>/*.a 已生成；
即使链接阶段失败，编译归档通常也已产出）。

用法
----
    python scripts/gen_exclude_rsp.py
    python scripts/gen_exclude_rsp.py --nm <path-to-nm.exe>
    python scripts/gen_exclude_rsp.py --target-dir target/release --dry-run
"""

import argparse
import os
import re
import shutil
import subprocess
import sys

# nm 输出行："0000000000000004 t _CGP..."（定义）或 "         U bgfx_alloc"（引用）
_DEF_RE = re.compile(r'^[0-9a-fA-F]{4,}\s+([A-Za-z])\s+(\S+)\s*$')
_UNDEF_RE = re.compile(r'^\s+U\s+(\S+)\s*$')

# 定义符号的 nm 类型：代码/数据/只读/弱符号/构造析构等
DEFINED_TYPES = set('TtDdBbRrWwVv')

# target/release 下这些目录不是第三方仓颉包
SKIP_DIRS = {'three', 'bin', '.build-logs'}


def run_nm(nm, archives):
    """对一批归档运行 nm，返回 (defined, undefined) 符号名集合。"""
    defined, undefined = set(), set()
    proc = subprocess.run([nm] + list(archives), capture_output=True, text=True,
                          errors='replace')
    for line in proc.stdout.splitlines():
        m = _UNDEF_RE.match(line)
        if m:
            undefined.add(m.group(1))
            continue
        m = _DEF_RE.match(line)
        if m:
            typ, name = m.group(1), m.group(2)
            if typ in DEFINED_TYPES:
                defined.add(name)
    return defined, undefined


def find_nm(explicit):
    if explicit:
        if not os.path.isfile(explicit):
            sys.exit('error: nm not found: %s' % explicit)
        return explicit
    found = shutil.which('nm')
    if found:
        return found
    # 常见 MinGW 安装位置兜底
    candidates = [
        r'D:\Venv\C_Cpp\mingw-w64\x86_64-13.2.0-release-posix-seh-ucrt-rt_v11-rev0'
        r'\mingw64\bin\nm.exe',
    ]
    for c in candidates:
        if os.path.isfile(c):
            return c
    sys.exit('error: nm not found in PATH; pass --nm <path-to-nm.exe>')


def collect_cangjie_archives(target_dir):
    """返回 [(包名, [归档路径...])]，扫描 target/release/<pkg>/*.a。"""
    pkgs = []
    for name in sorted(os.listdir(target_dir)):
        pkg_dir = os.path.join(target_dir, name)
        if not os.path.isdir(pkg_dir) or name in SKIP_DIRS:
            continue
        archives = sorted(
            os.path.join(pkg_dir, f)
            for f in os.listdir(pkg_dir)
            if f.endswith('.a') and os.path.isfile(os.path.join(pkg_dir, f))
        )
        if archives:
            pkgs.append((name, archives))
    return pkgs


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    root = os.path.dirname(script_dir)  # three/

    ap = argparse.ArgumentParser(description='生成 libs/exclude.rsp')
    ap.add_argument('--root', default=root, help='three 引擎根目录（默认脚本上级目录）')
    ap.add_argument('--target-dir', default=None,
                    help='cjpm 编译产物目录（默认 <root>/target/release）')
    ap.add_argument('--libs-dir', default=None, help='C/C++ 静态库目录（默认 <root>/libs）')
    ap.add_argument('--nm', default=None, help='nm 可执行文件路径（默认取 PATH）')
    ap.add_argument('--output', default=None, help='输出 rsp 路径（默认 <libs>/exclude.rsp）')
    ap.add_argument('--map-output', default=None,
                    help='输出 ELF version script 路径（默认 <libs>/symbols_elf.map）')
    ap.add_argument('--dry-run', action='store_true', help='只统计不写文件')
    args = ap.parse_args()

    root = os.path.abspath(args.root)
    target_dir = os.path.abspath(args.target_dir or os.path.join(root, 'target', 'release'))
    libs_dir = os.path.abspath(args.libs_dir or os.path.join(root, 'libs'))
    output = os.path.abspath(args.output or os.path.join(libs_dir, 'exclude.rsp'))
    map_output = os.path.abspath(
        args.map_output or os.path.join(libs_dir, 'symbols_elf.map'))
    nm = find_nm(args.nm)

    if not os.path.isdir(target_dir):
        sys.exit('error: target dir not found: %s\n请先执行一次 cjpm build。' % target_dir)
    if not os.path.isdir(libs_dir):
        sys.exit('error: libs dir not found: %s' % libs_dir)

    print('nm        :', nm)
    print('target    :', target_dir)
    print('libs      :', libs_dir)

    # ---- 1. 第三方仓颉归档：defined 仓颉符号（排除）+ U 引用（用于 -u）----
    pkgs = collect_cangjie_archives(target_dir)
    if not pkgs:
        sys.exit('error: %s 下未发现第三方包归档，请先 cjpm build。' % target_dir)

    cj_exclude, cj_undef = set(), set()
    for pkg, archives in pkgs:
        d, u = run_nm(nm, archives)
        # 仓颉 mangled 符号：_C 开头（_CGP/_CN/_CC/_CG/_CP/_CV...）且含本包名
        cj_exclude |= {n for n in d if n.startswith('_C') and pkg in n}
        cj_undef |= u
        print('  [cj] %-16s archives=%d defined=%d undef=%d'
              % (pkg, len(archives), len(d), len(u)))

    # ---- 2. C/C++ 库归档：_Z* 排除，非 _Z 的 C 符号定义用于 -u 交集 ----
    cpp_exclude, c_defined = set(), set()
    lib_archives = sorted(
        os.path.join(libs_dir, f)
        for f in os.listdir(libs_dir)
        if f.endswith('.a') and os.path.isfile(os.path.join(libs_dir, f))
    )
    # 一次 nm 调用扫描全部库归档
    d, _u = run_nm(nm, lib_archives)
    for n in d:
        if n.startswith('_Z'):
            cpp_exclude.add(n)
        else:
            c_defined.add(n)
    print('  [cc] libs/*.a: %d archives, _Z symbols=%d, C symbols=%d'
          % (len(lib_archives), len(cpp_exclude), len(c_defined)))

    # ---- 3. -u：仓颉侧引用 ∩ C 库定义（排除 _C/_Z 开头，仓颉符号由 dll 间导入满足）----
    force_u = {n for n in (cj_undef & c_defined)
               if not n.startswith('_C') and not n.startswith('_Z')}

    exclude = cj_exclude | cpp_exclude
    pkg_names = sorted(pkg for pkg, _ in pkgs)
    print('')
    print('--exclude-symbols: %d (cangjie=%d, cpp=%d)'
          % (len(exclude), len(cj_exclude), len(cpp_exclude)))
    print('-u force exports : %d' % len(force_u))
    print('version-script   : local _Z* + _C*<%s>*' % '|'.join(pkg_names))

    # ---- 4. 组装 symbols_elf.map（Linux/OHOS --version-script）----
    # 仅需第三方包名：仓颉 mangled 符号形如 _CN12bgfx4cj.bgfx_xxx / _CGP7bgfx4cjfiHv，
    # 通配 _C*<pkg>* 可精确命中且不误伤 three 自身符号（_C*three* 保持全局导出）。
    # 注意：ld.lld 的 version script 解析器不支持 /* */ 注释，map 内只写纯语法；
    # 本文件语义说明见脚本 docstring 与 cjpm.toml 中 Linux/OHOS 段注释。
    map_lines = [
        '{',
        '  local:',
        '    _Z*;',
    ]
    for pkg in pkg_names:
        map_lines.append('    _C*%s*;' % pkg)
    map_lines += ['};', '']
    map_content = '\n'.join(map_lines)

    if args.dry_run:
        print('\ndry-run: 未写出文件。')
        return

    # ---- 5. 写 response file（Windows）----
    tmp = output + '.tmp'
    with open(tmp, 'w', encoding='ascii', newline='\n') as f:
        f.write('--exclude-symbols ')
        f.write(','.join(sorted(exclude)))
        f.write('\n')
        for n in sorted(force_u):
            f.write('-u %s\n' % n)
    os.replace(tmp, output)
    size_kb = os.path.getsize(output) / 1024.0
    print('\nwrote %s (%.1f KB)' % (output, size_kb))

    # ---- 6. 写 version script（Linux/OHOS）----
    tmp_map = map_output + '.tmp'
    with open(tmp_map, 'w', encoding='ascii', newline='\n') as f:
        f.write(map_content)
    os.replace(tmp_map, map_output)
    print('wrote %s (%.1f KB)' % (map_output, os.path.getsize(map_output) / 1024.0))


if __name__ == '__main__':
    main()
