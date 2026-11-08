#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_three.py — three.cj CI 统一构建脚本（GitHub Actions 用）

流程（对齐消费侧 README 的本地构建步骤）：
  1. 下载 cxx 侧（three.cj-cxx）已打包好的静态库压缩包，解出
     <os>/<arch>/release/static 下的 .a/.lib 平铺进 three.cj/libs/；
  2. 设置 cjpm.toml link-option 引用的环境变量：
       EXTEND_LIBS_PATH_<TAG>=<repo>/libs    EXTEND_LINK_OPTION_<TAG>=""
  3. 第一次 `cjpm build --target <triple>`（预期链接失败，忽略错误——
     但编译会产出依赖包归档 target/release/<pkg>/*.a）；
  4. 运行 scripts/gen_exclude_rsp.py 刷新 exclude.rsp / symbols_elf.map，
     解决导出符号冲突；
  5. 再次 `cjpm build --target <triple>`（最多重试 MAX_BUILD_RETRY 次）；
  6. 收集 target/release/three 全部产物打包为 dist/three-<os>-<arch>.zip。

用法（在已 source 仓颉 SDK envsetup.sh 的环境中）：
    python3 build_three.py --platform linux --arch x86_64 \
        --native-url https://.../native-libs-linux-x86_64-release-static.tar.gz
"""

import argparse
import glob
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
import zipfile

# Windows runner 上 stdout 默认 cp1252，打印中文会 UnicodeEncodeError
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))  # three.cj/

# 平台 -> (产物目录名, {arch: (cjpm triple, 环境变量 TAG)})
PLATFORMS = {
    "windows": ("windows", {
        "x86_64": ("x86_64-w64-mingw32", "WIN_X64"),
        "arm64-v8a": ("aarch64-w64-mingw32", "WIN_ARM64"),
    }),
    "linux": ("linux", {
        "x86_64": ("x86_64-unknown-linux-gnu", "LINUX_X64"),
        "arm64-v8a": ("aarch64-unknown-linux-gnu", "LINUX_ARM64"),
    }),
    "macos": ("macos", {
        "x86_64": ("x86_64-apple-darwin", "MACOS_X64"),
        "arm64-v8a": ("aarch64-apple-darwin", "MACOS_ARM64"),
    }),
    "ohos": ("ohos", {
        "x86_64": ("x86_64-linux-ohos", "OHOS_X64"),
        "arm64-v8a": ("aarch64-linux-ohos", "OHOS_ARM64"),
    }),
    "ios": ("ios", {
        "arm64-v8a": ("arm64-apple-ios11", "IOS_ARM64"),
        "simulator-arm64": ("arm64-apple-ios11-simulator", "IOS_SIM_ARM64"),
        "simulator-x86_64": ("x86_64-apple-ios11-simulator", "IOS_SIM_X64"),
    }),
    "android": ("android", {
        "arm64-v8a": ("aarch64-linux-android", "ANDROID_ARM64"),
        # x86_64 不支持：SDK 无 linux_android_x86_64_cjnative 模块
    }),
}

LIB_EXTS = (".a", ".lib")
MAX_BUILD_RETRY = 2  # 第 3 步后的正式编译允许的最大重试次数


def log(msg):
    print("[build-three] %s" % msg, flush=True)


def download(url, dest):
    log("下载 native libs: %s" % url)
    req = urllib.request.Request(url, headers={"User-Agent": "three.cj-ci"})
    with urllib.request.urlopen(req) as resp, open(dest, "wb") as f:
        shutil.copyfileobj(resp, f)


def extract(archive, dest):
    if archive.endswith(".zip"):
        with zipfile.ZipFile(archive) as z:
            z.extractall(dest)
    else:  # .tar.gz / .tgz
        with tarfile.open(archive, "r:*") as t:
            t.extractall(dest)


def install_native_libs(url, os_dir, arch, libs_dir, dynamic_sdl3=False):
    """下载 cxx 产物包，把 release/static 的静态库平铺进 libs/。

    dynamic_sdl3（ohos 特例）：SDL3 链接动态库版本——跳过 libSDL3.a
    （防止 -lSDL3 命中静态版），并复制包内的 libSDL3.so 进 libs/。
    """
    if not url:
        sys.exit("error: --native-url 未提供（workflow 输入 native-libs-url-* 为空）")
    os.makedirs(libs_dir, exist_ok=True)
    for f in os.listdir(libs_dir):
        if f.lower().endswith(LIB_EXTS) or f == "libSDL3.so":
            os.remove(os.path.join(libs_dir, f))

    tmp = tempfile.mkdtemp(prefix="native-libs-")
    try:
        archive = os.path.join(tmp, "native-libs" + (".zip" if url.endswith(".zip") else ".tar.gz"))
        download(url, archive)
        extract(archive, tmp)
        # 约定包内路径 <os>/<arch>/release/static；兜底全局搜 release/static
        candidates = [os.path.join(tmp, os_dir, arch, "release", "static")]
        static_dir = next((c for c in candidates if os.path.isdir(c)), None)
        if static_dir is None:
            hits = []
            for root, _d, files in os.walk(tmp):
                if os.path.basename(root) == "static" and any(f.endswith(".a") for f in files):
                    hits.append(root)
            if not hits:
                sys.exit("error: 包内未找到 release/static 静态库目录")
            static_dir = hits[0]
        n = 0
        for root, _d, files in os.walk(static_dir):
            for fn in files:
                if fn == "libSDL3.so" and dynamic_sdl3:
                    shutil.copy2(os.path.join(root, fn), os.path.join(libs_dir, fn))
                    log("已复制动态库 %s -> %s（ohos SDL3 走动态链接）" % (fn, libs_dir))
                    continue
                if fn == "libSDL3.a" and dynamic_sdl3:
                    continue  # ohos 不用静态 SDL3
                if fn.lower().endswith(LIB_EXTS):
                    shutil.copy2(os.path.join(root, fn), os.path.join(libs_dir, fn))
                    n += 1
        log("已安装 %d 个静态库 -> %s" % (n, libs_dir))
        if n == 0:
            sys.exit("error: 静态库包解压后为空: %s" % url)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def write_placeholder_link_files(libs_dir):
    """首次编译前写占位的 symbols_elf.map / exclude.rsp。

    交叉编译时第一次 cjpm build 在最早一批链接就会因 version-script
    缺失而中断，依赖包归档（target/release/<pkg>/*.a）编不完整，
    gen_exclude_rsp 只能扫到极少数包（map 残缺）。占位文件让首次
    链接跑得更远，把归档都产出后由 gen_exclude_rsp 覆盖为真实内容。
    """
    os.makedirs(libs_dir, exist_ok=True)
    map_path = os.path.join(libs_dir, "symbols_elf.map")
    rsp_path = os.path.join(libs_dir, "exclude.rsp")
    if not os.path.exists(map_path):
        with open(map_path, "w", encoding="ascii", newline="\n") as f:
            f.write("{\n  local:\n    _Z*;\n};\n")
    if not os.path.exists(rsp_path):
        with open(rsp_path, "w", encoding="ascii", newline="\n") as f:
            f.write("")


def find_nm():
    """优先用仓颉 SDK 自带 llvm-nm，其次 PATH 上的 nm。"""
    cj_home = os.environ.get("CANGJIE_HOME", "")
    nm_name = "llvm-nm.exe" if os.name == "nt" else "llvm-nm"
    if cj_home:
        cand = os.path.join(cj_home, "third_party", "llvm", "bin", nm_name)
        if os.path.isfile(cand):
            return cand
    found = shutil.which("llvm-nm") or shutil.which("nm")
    if found:
        return found
    sys.exit("error: 找不到 nm/llvm-nm（请确认仓颉 SDK envsetup 已生效）")


def find_llvm_ar():
    """合并静态归档用 llvm-ar（仓颉 SDK 自带，全平台行为一致）。"""
    cj_home = os.environ.get("CANGJIE_HOME", "")
    name = "llvm-ar.exe" if os.name == "nt" else "llvm-ar"
    if cj_home:
        cand = os.path.join(cj_home, "third_party", "llvm", "bin", name)
        if os.path.isfile(cand):
            return cand
    found = shutil.which("llvm-ar") or shutil.which("ar")
    if found:
        return found
    sys.exit("error: 找不到 llvm-ar/ar（合并 three-deps.a 需要）")


# 方案二 v3: 工具链 C++ 运行时静态库。cjpm.toml 各 target link-option 里的
# -l:libc++.a / libunwind.a（windows）、libstdc++.a / libgcc_eh.a（linux）、
# libc++_static.a / libc++abi.a / libunwind.a（ohos/android）既不属于
# native 下载包也不是系统库，须在工具链中定位后并入 three-deps.a，
# 否则下游静态链接报 undefined symbol。
# macos/ios 的 -lc++ 是系统动态库，无需并入。
TOOLCHAIN_LIB_NAMES = {
    ("windows", "x86_64"): ["libc++.a", "libunwind.a"],
    ("windows", "arm64-v8a"): ["libc++.a", "libunwind.a"],
    ("linux", "x86_64"): ["libstdc++.a", "libgcc_eh.a"],
    ("linux", "arm64-v8a"): ["libstdc++.a", "libgcc_eh.a"],
    ("ohos", "arm64-v8a"): ["libc++_static.a", "libc++abi.a", "libunwind.a"],
    ("ohos", "x86_64"): ["libc++_static.a", "libc++abi.a", "libunwind.a"],
    ("android", "arm64-v8a"): ["libc++_static.a", "libc++abi.a"],
}


def toolchain_lib_dirs(platform, triple, env):
    """返回当前平台的工具链库候选目录（支持 glob 通配段）。"""
    dirs = []
    sdk = env.get("CANGJIE_HOME", "")
    if platform == "windows":
        if sdk:
            dirs.append(os.path.join(sdk, "third_party", "mingw", "lib"))
    elif platform == "linux":
        # linux job 在与目标同架构的原生 runner 上运行，gcc 即目标工具链；
        # -print-file-name 找到时返回完整路径，找不到时原样返回库名
        for cc in ("gcc", "cc"):
            if not shutil.which(cc):
                continue
            for lib in ("libstdc++.a", "libgcc_eh.a"):
                out = subprocess.run([cc, "-print-file-name=" + lib],
                                     capture_output=True, text=True).stdout.strip()
                if out.endswith(lib) and os.path.isfile(out):
                    d = os.path.dirname(out)
                    if d not in dirs:
                        dirs.append(d)
            break
        if sdk:
            dirs.append(os.path.join(sdk, "third_party", "llvm", "lib", triple))
    elif platform == "ohos":
        native = env.get("DEVECO_OH_NATIVE_HOME", "")
        if native:
            dirs.append(os.path.join(native, "llvm", "lib", triple))
            dirs.append(os.path.join(native, "sysroot", "usr", "lib", triple))
    elif platform == "android":
        ndk = env.get("ANDROID_NDK_HOME", "")
        if ndk:
            # NDK 布局随版本变化：libc++_static.a 在
            # toolchains/llvm/prebuilt/<tag>/sysroot/usr/lib/<triple>/
            # （新版亦可能位于 lib/clang/<ver>/lib/<triple>/）
            dirs.append(os.path.join(ndk, "toolchains", "llvm", "prebuilt", "*",
                                     "sysroot", "usr", "lib", triple))
            dirs.append(os.path.join(ndk, "toolchains", "llvm", "prebuilt", "*",
                                     "lib", "clang", "*", "lib", triple))
            dirs.append(os.path.join(ndk, "sysroot", "usr", "lib", triple))
    return [d for d in dirs if d and d != sdk]


def find_toolchain_libs(platform, arch, triple, env, libs_dir):
    """定位本平台的工具链静态库。

    返回 (found, missing)：
      found   = [(库名, 绝对路径)]
      missing = [库名]（附 WARN 日志，随 MANIFEST 下发，不阻断构建）
    已存在于 libs/（下载包）里的库不重复查找。
    """
    names = TOOLCHAIN_LIB_NAMES.get((platform, arch), [])
    if not names:
        return [], []
    have = set(os.listdir(libs_dir)) if os.path.isdir(libs_dir) else set()
    dirs = toolchain_lib_dirs(platform, triple, env)
    found, missing = [], []
    for name in names:
        if name in have:
            log("工具链库 %s 已含于下载包，跳过" % name)
            continue
        hit = None
        for d in dirs:
            pattern = os.path.join(d, name)
            cands = glob.glob(pattern) if "*" in pattern else [pattern]
            for c in cands:
                if os.path.isfile(c):
                    hit = c
                    break
            if hit:
                break
        if hit:
            found.append((name, hit))
        else:
            missing.append(name)
    for name in missing:
        log("WARN: 工具链库 %s 未在候选目录找到（%s），未并入 three-deps.a"
            % (name, "; ".join(dirs) or "SDK 环境变量未配置"))
    return found, missing


def set_output_type(original_text, ptype):
    """按产物类型切换 cjpm.toml 主包 output-type。

    主包（[package]）是全 toml 唯一的 output-type = "dynamic"；
    依赖包均为 static 不受影响。返回切换后的文本。
    """
    if ptype == "static":
        text = original_text.replace('output-type = "dynamic"',
                                     'output-type = "static"')
        if text == original_text:
            log("WARN: cjpm.toml 未找到 output-type = \"dynamic\"（可能已是 static）")
        return text
    return original_text


def merge_static_products(env, toolchain_found=None, toolchain_missing=None):
    """方案二 v2：three-deps.a 仅合并下载压缩包解出的依赖 .a（libs/*.a）。

    - 仓颉模块归档（target/release/<pkg>/*.a，如 libthree.core.math.a、
      libbgfx4cj.bgfx.a）**不并入**——它们随各自模块目录（与 .cjo 同目录）
      分发，供 bin-dependencies 白名单校验与 cjpm 自动链接；
    - v3: 追加合并工具链 C++ 运行时静态库（toolchain_found，
      见 TOOLCHAIN_LIB_NAMES）——如 windows 的 libc++.a/libunwind.a；
    - 统一用 llvm-ar MRI 脚本（ADDLIB 逐个加入，同名成员全保留，
      规避 ar rcs 追加覆盖；Mac/iOS 也不用 libtool 以免重名随机取舍）；
    - 校验：合并后成员数 == 各输入成员数之和。
    返回 (three-deps.a 路径, MANIFEST 文本)。
    """
    libs_dir = os.path.join(ROOT, "libs")
    merge_inputs = []   # (路径, 成员数)
    if os.path.isdir(libs_dir):
        for fn in sorted(os.listdir(libs_dir)):
            if fn.endswith(".a"):
                merge_inputs.append(os.path.join(libs_dir, fn))
    if not merge_inputs:
        sys.exit("error: 静态合并无输入（libs/ 下没有 .a——native 依赖包未安装？）")
    for p in merge_inputs:
        if os.path.getsize(p) == 0:
            sys.exit("error: 合并输入存在空归档: %s（上游某组可能静默失败）" % p)
    # v3: 追加工具链 C++ 运行时静态库（已在 libs/ 中的会被
    # find_toolchain_libs 跳过，不会重复合并）
    for _name, path in (toolchain_found or []):
        if os.path.getsize(path) == 0:
            sys.exit("error: 工具链库为空归档: %s" % path)
        merge_inputs.append(path)
        log("追加工具链库: %s" % path)

    ar = find_llvm_ar()
    # 工作目录放系统临时区——不能放 dist/ 下（upload-artifact 会把
    # dist/* 整体上传，合并中间物不应进产物包）
    work_dir = tempfile.mkdtemp(prefix="three-static-merge-")
    os.makedirs(work_dir, exist_ok=True)
    out_a = os.path.join(work_dir, "three-deps.a")

    # 统计各输入成员数（合并后核对总数）
    member_total = 0
    mri_lines = ["CREATE " + out_a.replace(os.sep, "/")]
    for p in merge_inputs:
        proc = subprocess.run([ar, "t", p], capture_output=True, text=True)
        n = len([l for l in proc.stdout.splitlines() if l.strip()])
        member_total += n
        mri_lines.append("ADDLIB " + p.replace(os.sep, "/"))
    mri_lines += ["SAVE", "END"]
    mri_text = "\n".join(mri_lines) + "\n"
    # llvm-ar 的 -M 不接受脚本文件参数（报 cannot mix -M and other
    # options），脚本必须经 stdin 传入
    proc = subprocess.run([ar, "-M"], env=env, cwd=ROOT, input=mri_text,
                          capture_output=True, text=True)
    if proc.returncode != 0:
        sys.stdout.write(proc.stdout or "")
        sys.stderr.write(proc.stderr or "")
        sys.exit("error: llvm-ar -M 合并失败（exit %d）" % proc.returncode)

    proc = subprocess.run([ar, "t", out_a], capture_output=True, text=True)
    merged_members = len([l for l in proc.stdout.splitlines() if l.strip()])
    if merged_members != member_total:
        sys.exit("error: 合并后成员数 %d != 输入成员数之和 %d（成员覆盖丢失）"
                 % (merged_members, member_total))

    manifest = ["# three-deps.a 合并清单（native 依赖 + 工具链 C++ 运行时，不含仓颉模块归档）",
                "merged_members: %d" % merged_members,
                "input_archives: %d" % len(merge_inputs),
                "", "# 输入归档（成员数）:"]
    for p in merge_inputs:
        proc = subprocess.run([ar, "t", p], capture_output=True, text=True)
        n = len([l for l in proc.stdout.splitlines() if l.strip()])
        # 工具链库可能在其它盘符（如 C:\cangjie-sdk），Windows 下
        # relpath 跨盘会抛 ValueError，此时记录绝对路径
        try:
            display = os.path.relpath(p, ROOT)
        except ValueError:
            display = p
        manifest.append("  %s (%d)" % (display, n))
    if toolchain_found:
        manifest += ["", "# 工具链补充库（来源）:"]
        for name, path in toolchain_found:
            manifest.append("  %s <- %s" % (name, path))
    if toolchain_missing:
        manifest += ["", "# 工具链库缺失（未并入，下游静态链接可能 undefined）:"]
        for name in toolchain_missing:
            manifest.append("  MISSING: %s" % name)
    manifest_path = os.path.join(work_dir, "MANIFEST.txt")
    with open(manifest_path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(manifest) + "\n")
    log("three-deps.a 合并完成: %d 输入 / %d 成员" % (len(merge_inputs), merged_members))
    return out_a, manifest_path


def is_macro_artifact(fn):
    """宏插件产物识别：lib-macro_*.dll/dylib/so 与 *macros*.cjo。"""
    if fn.startswith("lib-macro_"):
        return True
    return fn.endswith(".cjo") and ".macros." in fn


def collect_static_modules(triple):
    """收集静态产物：target/release 下所有含 *.cjo 的模块目录。

    返回 {模块名: {zip内路径: 磁盘绝对路径}}。目录名即 zip 内的模块
    文件夹名（与 bin-dependencies 的 <root包名>/<cjo> 白名单布局一致）。

    - 本机构建（无 target/<triple>/）：target/release 即目标平台产物，
      全量收集；
    - 交叉编译：target/<triple>/release/<模块>/ 为目标平台产物，全量
      收集；宿主目录 target/release/<模块>/ 中仅收集**宏相关产物**
      （lib-macro_*.dll 与 *macros*.cjo，宏在下游编译期由宿主编译器
      加载），合入对应模块目录。
    """
    rel_host = os.path.join(ROOT, "target", "release")
    rel_target = os.path.join(ROOT, "target", triple, "release")
    is_cross = os.path.isdir(rel_target) and os.path.abspath(rel_target) != os.path.abspath(rel_host)

    modules = {}   # 模块名 -> {zip内路径: 绝对路径}

    def scan(base_dir, macro_only, priority):
        """扫描 base_dir 下含 *.cjo 的模块目录。

        priority：写入优先级（数值大者覆盖同名 zip 内路径）——
        目标平台产物 > 宿主宏产物。
        """
        if not os.path.isdir(base_dir):
            return
        for entry in sorted(os.listdir(base_dir)):
            mod_dir = os.path.join(base_dir, entry)
            if not os.path.isdir(mod_dir):
                continue
            if not any(f.endswith(".cjo") for f in os.listdir(mod_dir)):
                continue  # 只收含 *.cjo 的目录（排除 bin/ 等）
            for root, _dirs, files in os.walk(mod_dir):
                for fn in files:
                    if macro_only and not is_macro_artifact(fn):
                        continue
                    full = os.path.join(root, fn)
                    rel = os.path.relpath(full, mod_dir).replace(os.sep, "/")
                    arc = "%s/%s" % (entry, rel)
                    cur = modules.setdefault(entry, {}).get(arc)
                    if cur is None or priority >= cur[0]:
                        modules[entry][arc] = (priority, full)
                    else:
                        modules[entry][arc] = cur

    # 1. 宿主目录：仅宏相关产物（交叉编译时必需；本机构建时也包含，
    #    但会被下一步的目标平台产物覆盖同名路径）
    scan(rel_host, macro_only=is_cross, priority=0)
    # 2. 目标平台目录：全量收集，优先级最高
    if is_cross:
        scan(rel_target, macro_only=False, priority=1)

    # 展开成 {arc: abs_path}（去掉优先级标记）
    return {mod: {arc: v[1] for arc, v in files.items()}
            for mod, files in modules.items()}


def run(cmd, env, ignore=False):
    log("$ " + " ".join(cmd))
    proc = subprocess.run(cmd, env=env, cwd=ROOT)
    if proc.returncode != 0 and not ignore:
        sys.exit("error: 命令失败(exit %d): %s" % (proc.returncode, cmd[0]))
    return proc.returncode


def main():
    ap = argparse.ArgumentParser(description="three.cj CI 构建编排")
    ap.add_argument("--platform", required=True, choices=sorted(PLATFORMS))
    ap.add_argument("--arch", required=True,
                    choices=["x86_64", "arm64-v8a",
                             "simulator-arm64", "simulator-x86_64"])
    ap.add_argument("--native-url", required=True,
                    help="cxx 侧静态库包下载地址（native-libs-<os>-<arch>-release-static）")
    ap.add_argument("--host-url", default=None,
                    help="可选：宏包按宿主平台编译链接，交叉编译时需宿主平台的静态库包"
                         "（native-libs-<host-os>-<host-arch>-release-static）")
    ap.add_argument("--host-tag", default=None,
                    help="可选：与 --host-url 配套的环境变量 TAG（如 MACOS_ARM64/LINUX_X64/WIN_X64）")
    ap.add_argument("--sdl3-url", default=None,
                    help="ohos 特例：SDL3 动态库来源的下载链接——native-libs "
                         "release shared 库包（tar.gz/zip，从中提取 libSDL3.so）；"
                         "也兼容直接的 .so 文件链接")
    ap.add_argument("--product-type", default="",
                    choices=["", "dynamic", "static", "both"],
                    help="产物类型：dynamic=动态库（现状）；static=静态库"
                         "（主包 output-type 切 static，依赖 .a 合并为 "
                         "three-deps.a）；留空或 both=两种都编译")
    args = ap.parse_args()

    os_dir, arch_map = PLATFORMS[args.platform]
    if args.arch not in arch_map:
        sys.exit("error: 平台 %s 不支持架构 %s" % (args.platform, args.arch))
    triple, tag = arch_map[args.arch]
    libs_dir = os.path.join(ROOT, "libs")
    env = dict(os.environ)
    env["EXTEND_LIBS_PATH_" + tag] = libs_dir
    env["EXTEND_LINK_OPTION_" + tag] = ""
    log("EXTEND_LIBS_PATH_%s=%s" % (tag, libs_dir))

    # 1. 安装 cxx 静态库（ohos：SDL3 走动态库版本）
    # ios 变体→cxx 包内目录名映射（cxx 侧 dist 命名）：
    #   arm64-v8a（真机）      -> ios/arm64
    #   simulator-arm64        -> ios/arm64-sim
    #   simulator-x86_64       -> ios/x86_64-sim
    cxx_arch = {"arm64-v8a": "arm64",
                "simulator-arm64": "arm64-sim",
                "simulator-x86_64": "x86_64-sim"}.get(args.arch, args.arch) \
        if args.platform == "ios" else args.arch
    install_native_libs(args.native_url, os_dir, cxx_arch, libs_dir,
                        dynamic_sdl3=(args.platform == "ohos"))

    # 1a. ohos：从 --sdl3-url（native-libs release shared 库包）提取
    #     libSDL3.so 到 libs/（供 -lSDL3 动态链接与最终产物打包）
    if args.platform == "ohos":
        dest = os.path.join(libs_dir, "libSDL3.so")
        if args.sdl3_url:
            if args.sdl3_url.endswith((".tar.gz", ".tgz", ".zip")):
                tmp = tempfile.mkdtemp(prefix="sdl3-so-")
                try:
                    archive = os.path.join(tmp, "shared" + os.path.splitext(args.sdl3_url)[1])
                    download(args.sdl3_url, archive)
                    extract(archive, tmp)
                    hits = [os.path.join(r, f) for r, _d, fs in os.walk(tmp)
                            for f in fs if f == "libSDL3.so"]
                    if not hits:
                        sys.exit("error: shared 库包内未找到 libSDL3.so: %s" % args.sdl3_url)
                    shutil.copy2(hits[0], dest)
                finally:
                    shutil.rmtree(tmp, ignore_errors=True)
            else:  # 直接的 .so 文件链接
                download(args.sdl3_url, dest)
            log("已提取 SDL3 动态库 -> %s" % dest)
        if not os.path.isfile(dest):
            log("WARN: 未提供 --sdl3-url 且静态库包内无 libSDL3.so，"
                "产物包将缺少 SDL3 动态库")
        elif open(dest, "rb").read(4) != b"\x7fELF":
            sys.exit("error: libs/libSDL3.so 不是 ELF 文件（下载源可能返回了 "
                     "HTML/压缩包，检查 --sdl3-url 指向的内容）")

    # 1b. 宏包（compile-macros-for-target 默认仅本地平台）在宿主平台编译链接，
    #     交叉编译时需单独安装宿主平台静态库到 libs-host/ 并设置对应变量；
    #     host tag 与目标 tag 相同（native 构建）时无需单独安装
    host_installed = False
    if args.host_url or args.host_tag:
        if args.host_tag == tag:
            log("host tag 与目标 tag 相同（%s），跳过宿主库单独安装" % tag)
        else:
            if not args.host_url:
                sys.exit("error: --host-tag 需与 --host-url 同时提供")
            host_libs_dir = os.path.join(ROOT, "libs-host")
            env["EXTEND_LIBS_PATH_" + args.host_tag] = host_libs_dir
            env["EXTEND_LINK_OPTION_" + args.host_tag] = ""
            log("EXTEND_LIBS_PATH_%s=%s（宏包宿主链接）" % (args.host_tag, host_libs_dir))
            # 宿主平台：取宏包所需的 darwin/linux/windows 静态库；
            # 宏包只链接不运行，平台产物目录名按 host 推断（ios 宿主=macos）
            host_os = {"ios": "macos"}.get(args.platform, os_dir)
            install_native_libs(args.host_url, host_os,
                                {"ios": "arm64-v8a"}.get(args.arch, args.arch),
                                host_libs_dir)
            host_installed = True

    # 2. 刷新依赖，确保本地依赖归档与 cjpm.toml 一致
    log("cjpm update ...")
    run(["cjpm", "update"], env, ignore=False)

    # 2b. 首次编译前写占位 version-script/rsp：交叉编译时首次链接若因
    #     map 缺失立刻中断，依赖包归档编不完整，gen_exclude_rsp 只能
    #     扫到极少数包（ohos 实测 map 仅 0.0KB、只含 fastjson）
    write_placeholder_link_files(libs_dir)
    if host_installed:
        write_placeholder_link_files(os.path.join(ROOT, "libs-host"))

    # 3-6. 按产物类型循环编译与收集（留空=全量，两种都编译）
    ptype_input = args.product_type or "both"
    types = ["dynamic", "static"] if ptype_input == "both" \
        else [ptype_input]
    toml_path = os.path.join(ROOT, "cjpm.toml")
    with open(toml_path, encoding="utf-8") as f:
        toml_original = f.read()

    # 交叉编译时产物分两处：宿主目录 target/release/three（宏包等本地平台
    # 产物）与目标目录 target/<triple>/release/three（目标平台产物）。
    prod_dirs_all = [os.path.join(ROOT, "target", triple, "release", "three"),
                     os.path.join(ROOT, "target", "release", "three")]
    dist_dir = os.path.join(ROOT, "dist")
    os.makedirs(dist_dir, exist_ok=True)
    build_cmd = ["cjpm", "build", "--target", triple]
    first_overall = True

    for ptype in types:
        # 3a. 切换 cjpm.toml 主包 output-type（dynamic=原文；static 替换唯一
        #     的 output-type = "dynamic"）
        with open(toml_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(set_output_type(toml_original, ptype))
        log("=== 产物类型 %s：output-type 已切换 ===" % ptype)

        if ptype == "static":
            # 静态构建前清空 target：避免动态构建残留的 .so/.dll 混入
            # three/ 产物目录（两类型产物不共存于同一 target）
            target_dir = os.path.join(ROOT, "target")
            if os.path.isdir(target_dir):
                shutil.rmtree(target_dir)
            log("已清空 target/（静态构建从零开始）")

        # 3b. 第一次编译：产出依赖包归档，链接失败属预期，忽略；
        #     仅整体第一次编译带 -V（回显 cjc 命令行，便于诊断工具链问题）
        log("第一次编译（允许失败，仅产出依赖归档%s）..."
            % ("，-V 回显命令行" if first_overall else ""))
        run(build_cmd + (["-V"] if first_overall else []), env, ignore=True)

        # 4. 刷新 exclude.rsp / symbols_elf.map（目标平台 libs/）
        run([sys.executable, os.path.join(HERE, "..", "..", "scripts", "gen_exclude_rsp.py"),
             "--nm", find_nm()], env, ignore=True)

        # 4b. 宿主库目录单独生成一份（宏包链接时 --version-script 指向 libs-host/）
        if host_installed:
            run([sys.executable, os.path.join(HERE, "..", "..", "scripts", "gen_exclude_rsp.py"),
                 "--nm", find_nm(),
                 "--libs-dir", os.path.join(ROOT, "libs-host"),
                 "--output", os.path.join(ROOT, "libs-host", "exclude.rsp"),
                 "--map-output", os.path.join(ROOT, "libs-host", "symbols_elf.map")],
                env, ignore=True)

        # 4c. 仅 Windows：清理首轮失败残留的产物后再正式编译——残留的
        #     .o/.dll 会让 lld 报 "_CGP... was replaced"（符号被旧产物
        #     替换）。其它平台无此问题，clean 会拖慢全量重编，跳过。
        if args.platform == "windows":
            run(["cjpm", "clean"], env, ignore=False)

        # 5. 正式编译（重试直到成功）
        for attempt in range(1, MAX_BUILD_RETRY + 2):
            log("第 %d 次正式编译（%s）..." % (attempt, ptype))
            if run(build_cmd, env, ignore=True) == 0:
                break
            if attempt > MAX_BUILD_RETRY:
                sys.exit("error: cjpm build（%s）重试 %d 次后仍失败"
                         % (ptype, MAX_BUILD_RETRY))
            log("编译失败，重试...")

        # 6. 收集产物打包
        dist_dir = os.path.join(ROOT, "dist")
        os.makedirs(dist_dir, exist_ok=True)
        if ptype == "dynamic":
            out_zip = os.path.join(dist_dir, "three-%s-%s-shared.zip" % (os_dir, args.arch))
            # 动态包：目标平台 three 产物目录（宿主/目标双目录去重）
            prod_dirs = [d for d in prod_dirs_all if os.path.isdir(d)]
            if not prod_dirs:
                sys.exit("error: 未找到任何产物目录（target/release/three 或 target/%s/release/three）"
                         % triple)
            if len(prod_dirs) == 1:
                log("产物目录: %s" % prod_dirs[0])
            else:
                log("产物目录（目标平台优先）: %s" % ", ".join(prod_dirs))
        else:
            out_zip = os.path.join(dist_dir, "three-%s-%s-static.zip" % (os_dir, args.arch))

        if os.path.isfile(out_zip):
            os.remove(out_zip)
        n = 0
        seen = set()
        with zipfile.ZipFile(out_zip, "w", zipfile.ZIP_DEFLATED) as z:
            if ptype == "dynamic":
                for prod_dir in prod_dirs:  # prod_dirs[0] 为目标平台，优先写入
                    base = os.path.join(prod_dir, "")  # 归一化，便于截取相对路径
                    for root, _d, files in os.walk(prod_dir):
                        for fn in files:
                            full = os.path.join(root, fn)
                            rel = os.path.relpath(full, base)
                            if rel in seen:
                                continue
                            seen.add(rel)
                            z.write(full, rel)
                            n += 1
            else:
                # 静态包：按模块目录组织（<模块>/{*.cjo,lib<包名>.a,宏库}），
                # 布局对齐 bin-dependencies 的 <root包名>/<cjo> 白名单要求；
                # three-deps.a 仅含 native 依赖，供下游 link-option 一行引入
                modules = collect_static_modules(triple)
                if not modules:
                    sys.exit("error: 静态收集未发现任何含 *.cjo 的模块目录"
                             "（target/release 与 target/%s/release）" % triple)
                for mod in sorted(modules):
                    files = modules[mod]
                    for arc in sorted(files):
                        z.write(files[arc], arc)
                        n += 1
                    log("模块 %s: %d 个文件" % (mod, len(files)))
                # v3: 定位工具链 C++ 运行时静态库（libc++/libunwind/
                # libstdc++/libgcc_eh/libc++_static/libc++abi），并入合并
                tc_found, tc_missing = find_toolchain_libs(
                    args.platform, args.arch, triple, env, libs_dir)
                out_a, manifest_path = merge_static_products(
                    env, toolchain_found=tc_found, toolchain_missing=tc_missing)
                z.write(out_a, "three-deps.a")
                z.write(manifest_path, "MANIFEST.txt")
                n += 2
            # ohos 特例：SDL3 链接动态库版本，产物包需附带 libSDL3.so
            if args.platform == "ohos":
                sdl3_so = os.path.join(libs_dir, "libSDL3.so")
                if os.path.isfile(sdl3_so) and "libSDL3.so" not in seen:
                    z.write(sdl3_so, "libSDL3.so")
                    n += 1
                else:
                    log("WARN: %s 不存在，产物包未附带 libSDL3.so" % sdl3_so)
        log("DONE[%s]: %s (%d 个文件)" % (ptype, out_zip, n))
        first_overall = False

    # 还原 cjpm.toml 原文（避免本地/后续步骤残留切换状态）
    with open(toml_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(toml_original)


if __name__ == "__main__":
    main()
