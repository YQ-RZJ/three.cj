# Helper Scripts

Utility scripts for the three.cj project (Python 3.9+, standard library only, no third-party dependencies).

## Scripts at a Glance

| Script | Purpose | When to use |
|--------|---------|-------------|
| [`gen_exclude_rsp.py`](./gen_exclude_rsp.py) | Generates cross-platform link symbol controls: `libs/exclude.rsp` (ld.lld response file) for Windows and `libs/symbols_elf.map` (`--version-script`) for Linux/OHOS | Refresh link symbol lists after adding/upgrading dependencies or rebuilding C libraries |
| [`check_so_deps.py`](./check_so_deps.py) | Recursively analyzes the `DT_NEEDED` dependency chain of `.so` files and outputs Markdown | Debugging `.so` load failures in OHOS HAP / Linux cross-platform SDKs |
| [`add_license_header.py`](./add_license_header.py) | Inserts (or creates) an `@LICENSE` copyright header into the leading `/**...*/` doc block of `src/**/*.cj` files; idempotent and safe to re-run | Initial LICENSE header rollout, or backfilling copyright comments for newly added source files |
| [`generate_structure.py`](./generate_structure.py) | Generates a file checklist or a tree-style directory listing as Markdown | Producing source directory structure documentation |

All scripts support `-h` / `--help` for the full parameter list.

---

## gen_exclude_rsp.py

### Background

On Windows (MinGW), cjpm links each Cangjie sub-package of three into a separate dll with
`--export-all-symbols`. After third-party Cangjie FFI packages (bgfx4cj / sdl4cj / jolt4cj, etc.)
are linked statically into each dll, their mangled symbols are auto-exported; when a downstream
dll links, the same symbol is both resolved as an import thunk from an upstream dll's import
library and defined by the local static archive, causing ld.lld to report `symbol was replaced`.
The same applies to `_Z*` internal symbols of C++ static libraries.

The MinGW flavor of ld.lld does not support `--exclude-libs` / `--version-script`; it only supports
`--exclude-symbols <symbol list>` and `@response files`. This script scans the actual archives and
produces two semantically equivalent platform control files in one run:

1. `libs/exclude.rsp` (Windows MinGW ld.lld), containing:
   - `--exclude-symbols`: third-party Cangjie mangled symbols (`_C`-prefixed, containing the package
     name) plus all C++ `_Z*` symbols — kept from being auto-exported, eliminating `symbol was replaced`;
   - `-u <C API symbols>`: undefined references from Cangjie FFI archives intersected with non-`_C`/`_Z`
     symbols defined in C library archives — forcing the topologically earliest dll to pull in and
     export the full C API (`bgfx_*` / `SDL_*` / `JPH_*` / `al*` / `ig*` / `lua_*`, etc.), so that
     downstream dlls always resolve through the IAT to a single definition, keeping C library global
     state (e.g. bgfx `g_ctx`, OpenAL current context) shared as one instance across dlls.
2. `libs/symbols_elf.map` (Linux / OHOS, `--version-script` for ld.lld and GNU ld):
   - `local: _Z*; _C*<third-party-package>*;` — third-party Cangjie symbols and C++ internal symbols
     are kept out of the dynamic symbol table; each `.so` uses its own copy from the static archives
     (ELF linking does not error like MinGW's `symbol was replaced`, but duplicated exports would
     create multiple code/package-init (`_CGP`) copies, relying on runtime interposition, which is
     fragile under hidden visibility / `-Bsymbolic`);
   - three's own symbols (`_C*three*`) and the C APIs are not in the local list and stay globally
     exported; downstream `.so` files bind (`UND`) to one definition, so C library global state stays
     a singleton as well.

> Note: ld.lld's version script parser does not accept `/* */` comments, so the map file contains
> pure syntax only. `--exclude-libs,ALL` is not usable: it also localizes the C APIs and breaks the
> singleton. macOS (ld64) uses a two-level namespace with different semantics; cjpm.toml keeps the
> default configuration for macOS for now.

### When to regenerate

- After adding/removing/upgrading third-party Cangjie dependencies (changes to cjpm.toml dependencies,
  or `cjpm update` pulling new bgfx4cj / jolt4cj / sdl4cj / ...);
- After rebuilding/upgrading the C/C++ static libraries under `libs/`;
- When Windows linking again reports `symbol was replaced` or `undefined symbol`.

> Changes to three's own source do **not** require regeneration: three's own symbols
> (`_CN5three...`) are never in the exclusion list.

### Prerequisites

Run `cjpm build` once first so that the dependency package archives
`target/release/<pkg>/*.a` are produced (the archives are usually emitted even if the link step
fails).

### Usage

```bash
# In the three/ directory: build to produce archives, generate the symbol files
# (rsp + map), then rebuild
cjpm build
python scripts/gen_exclude_rsp.py
cjpm build

# Statistics only, writes nothing (verify symbol counts)
python scripts/gen_exclude_rsp.py --dry-run
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--root` | Parent dir of the script (`three/`) | Engine root directory |
| `--target-dir` | `<root>/target/release` | cjpm build output directory (Cangjie package archives) |
| `--libs-dir` | `<root>/libs` | C/C++ static library directory |
| `--nm` | `nm` on PATH, falling back to a built-in MinGW path | Path to the `nm` executable |
| `--output` | `<libs>/exclude.rsp` | Output rsp path (Windows) |
| `--map-output` | `<libs>/symbols_elf.map` | Output version script path (Linux/OHOS) |
| `--dry-run` | off | Print statistics only, write no file |

> For aarch64-w64-mingw32 cross builds, pass `--target-dir` pointing at the ARM64 output directory
> and `--nm` pointing at the matching toolchain's nm to generate an ARM64-specific rsp.

---

## check_so_deps.py

### Background

When debugging `.so` loading issues in OHOS HAP / cross-platform SDKs, you often need to see the
full `DT_NEEDED` dependency chain of a `.so` (e.g. which system libraries `libSDL3.so` depends on,
or which SONAME alias of `libSDL3.so` `libsdl4cj.sdl.so` references), and whether any dependency is
missing from the packaged directories (which causes runtime `dlopen` failures / module not found).

The script recursively expands the dependency tree via `readelf -d`, automatically distinguishing:

- **[missing]**: the dependency cannot be found in any search directory (and is not a system library);
- **[system]**: part of the OHOS / Linux system library whitelist (`libc.so`, `libEGL.so`,
  `libhilog_ndk.z.so`, etc.), provided by the system and not needing to be packaged;
- **[cycle]**: an A → B → A circular dependency is detected; a placeholder node is attached and
  recursion stops;
- SONAME alias resolution is supported (real file names like `libfoo.so.0` / `libfoo.so.0.1.2`).

### Usage

```bash
python scripts/check_so_deps.py \
    --root entry/libs/arm64-v8a/libSDL3.so entry/libs/arm64-v8a/libsdl4cj.sdl.so \
    --search-dirs entry/libs/arm64-v8a libs-link \
    --output so_deps.md
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--root` | (required) | Starting `.so` file(s); multiple allowed (space-separated) |
| `--search-dirs` | (required) | Dependency library search directories; multiple allowed, searched in order |
| `--readelf` | `llvm-readelf`/`readelf` on PATH, falling back to DevEco SDK paths | readelf executable |
| `--output` | `so_deps.md` | Output Markdown path |
| `--max-depth` | `32` | Maximum recursion depth (guards against unexpectedly deep chains) |

The output Markdown has two parts: the dependency tree (with SONAME annotations and
missing/system/cycle markers) and a missing-dependency summary table (missing library → libraries
that depend on it).

---

## add_license_header.py

Automatically inserts the `@LICENSE` copyright notice (Apache 2.0 + Runtime Library Exception)
into the leading `/**...*/` doc-comment block of `src/**/*.cj` source files, ensuring the
`@LICENSE` info sits at the very front of the doc comment.

Behavior rules:

- If the file starts with a `/**...*/` comment block: the LICENSE info is inserted inside the
  block at the very front (right after the `/**` line, before tags such as `@file`);
- If the file has no leading comment block (e.g. starts directly with `package`): a new
  LICENSE-only comment block is prepended at the top of the file;
- **Idempotent**: files whose comment block already contains `@LICENSE` are skipped, so
  re-running is safe;
- Detects and preserves the original line-ending style (CRLF/LF) and BOM state; nothing beyond
  the inserted lines is modified.

### Usage

```bash
# Process the src/ directory (default root)
python scripts/add_license_header.py

# Explicit root directory
python scripts/add_license_header.py --root src

# Statistics only, no writes
python scripts/add_license_header.py --dry-run
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--root` | `src` | Root directory to scan (recursively processes all `.cj` files) |
| `--dry-run` | off | Print statistics and the changed-file list without writing |

---

## generate_structure.py

Generates a file checklist (checkbox style) or a tree-style directory listing of a given directory
as a Markdown file. Commonly used to produce source directory structure documentation.

### Usage

```bash
# File checklist of src/ (default output: File List.md)
python scripts/generate_structure.py --mode 1

# Tree-style listing of src/ (default output: Tree structure.md)
python scripts/generate_structure.py --mode tree

# Scan another directory with a custom output path
python scripts/generate_structure.py --mode 2 --root D:/other/src -o structure.md
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--mode` | (required) | `1`/`list`: file checklist (`- [ ]` entries); `2`/`tree`: tree listing (`├──`/`└──` connectors) |
| `--root` | `../src` next to the script (i.e. the engine `src/`) | Root directory to scan |
| `-o`, `--output` | Mode 1 → `File List.md`; mode 2 → `Tree structure.md` | Output Markdown path |
