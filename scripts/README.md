# Helper Scripts

Utility scripts for the three.cj project (Python 3.9+, standard library only, no third-party dependencies).

## Scripts at a Glance

| Script | Purpose | When to use |
|--------|---------|-------------|
| [`gen_exclude_rsp.py`](./gen_exclude_rsp.py) | Generates cross-platform link symbol controls: `libs/exclude.rsp` (ld.lld response file) for Windows and `libs/symbols_elf.map` (`--version-script`) for Linux/OHOS | Refresh link symbol lists after adding/upgrading dependencies or rebuilding C libraries |
| [`check_so_deps.py`](./check_so_deps.py) | Recursively analyzes the `DT_NEEDED` dependency chain of `.so` files and outputs Markdown | Debugging `.so` load failures in OHOS HAP / Linux cross-platform SDKs |
| [`add_license_header.py`](./add_license_header.py) | Inserts (or creates) an `@LICENSE` copyright header into the leading `/**...*/` doc block of `src/**/*.cj` files; idempotent and safe to re-run | Initial LICENSE header rollout, or backfilling copyright comments for newly added source files |
| [`generate_structure.py`](./generate_structure.py) | Generates a file checklist or a tree-style directory listing as Markdown | Producing source directory structure documentation |
| [`tracy_receiver.py`](./tracy_receiver.py) | Headless Tracy protocol receiver: connects to the profiled process on its own, writes the raw/decompressed/structured artifacts to disk, and emits hotspot statistics (call count, duration, P50/P95/P99) | Capturing profiling data without the Tracy GUI, CI performance baselines, offline replay to reproduce issues |
| [`tracy_queue_table.py`](./tracy_queue_table.py) | The Tracy protocol QueueType table (payload sizes of 132 entries, string types, timestamp bases, …), transcribed from upstream `TracyQueue.hpp` | The single lookup source when writing or validating a protocol parser |
| [`tracy_hotspots.py`](./tracy_hotspots.py) | Formats `stats.json` into a frame summary plus a hotspot Top N table (count / total / mean / P50 / P95) | Getting a quick hotspot table right after a capture |
| [`tracy_selftime.py`](./tracy_selftime.py) | Rebuilds the zone nesting from the event stream and reports call count / total / **self** time (children deducted); falls back to source line numbers when the client's zone names are lost | Locating the engine's own cost (separating "this layer is slow" from "a child is slow"), comparing hotspots across captures |

All scripts support `-h` / `--help` for the full parameter list (`tracy_queue_table.py` is an imported constant-table module and provides no command-line entry point).

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

---

## tracy_receiver.py

### Background

The Tracy GUI requires manual interaction, so it cannot run in a CI pipeline. Once the profiled
process statically links `libtracyc.a` it *is* the Tracy server and listens on a TCP port; this
script plays the role of the Tracy GUI/Worker, **connects to the profiled process on its own**,
parses the protocol, writes the full data to disk, and directly produces readable hotspot
statistics.

Protocol facts are taken from the upstream sources (each item cross-checked):

- `tracy/public/common/TracyProtocol.hpp` / `TracyQueue.hpp`
- `tracy/public/client/TracyProfiler.cpp/.hpp`
- `tracy/server/TracyWorker.cpp`

Key protocol points:

| Stage | Description |
|---|---|
| Handshake | The receiver sends `"TracyPrf"` + `uint32(82)` first, then reads a 1-byte HandshakeStatus and a 1170-byte WelcomeMessage |
| Data blocks | `uint32 compressedSize` + compressed bytes; LZ4 is a *stateful* stream sharing a 64 KiB dictionary across blocks, so blocks cannot be decompressed independently |
| Timestamps | The client rewrites TSC deltas on the wire (32-bit events subtract `ProtocolOffset32Bit`, 16-bit events subtract `ProtocolOffset16Bit`); the final nanoseconds are `(ref - welcome.initBegin) * welcome.timerMul` |
| Text | `SingleStringData = uint16 sz(+256) + text`; `SingleStringData8 = uint8 sz + text`; the text events themselves carry no payload — `ZoneText`/`ZoneName`/`Message*` consume the "previous" pending single string |

### Usage

```bash
# Wait for the profiled process to appear and connect automatically
# (by default: UDP broadcast discovery first, then scan ports 8086-8105)
python scripts/tracy_receiver.py --out captures/run1

# Fixed port + capture duration limit + timeout while waiting for the process
python scripts/tracy_receiver.py --out captures/run1 --port 8086 --max-seconds 120 --scan-timeout 120

# Offline self-test: fakes a protocol stream to validate the parser, no process needed
python scripts/tracy_receiver.py --self-test

# Offline replay of an already captured raw stream (target dir must already hold metadata.json)
python scripts/tracy_receiver.py --replay captures/run1/raw_stream.bin --out captures/run1_replay
```

> Offline replay is the main tool for reproducing and diagnosing parser issues: replaying a
> captured `raw_stream.bin` repeatedly reproduces stably whatever only shows up under a
> particular finalization timing.

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--host` | `127.0.0.1` | Address of the profiled process |
| `--port` | auto-discovered | Fixed data port; by default UDP discovery first, then a scan of 8086-8105 |
| `--out` | `captures/run1` | Artifact directory |
| `--max-seconds` | `0` (unlimited) | Maximum capture duration |
| `--scan-timeout` | `60.0` | Longest time to wait for the profiled process to appear (seconds) |
| `--self-test` | off | Offline self-test with a faked protocol stream |
| `--replay` | none | Offline replay of the given `raw_stream.bin` |

### Artifacts

| File | Content |
|------|---------|
| `raw_stream.bin` | Raw wire stream, written block by block as `[uint32 size][compressed bytes]` |
| `decompressed_stream.bin` | The LZ4-stream-decompressed contiguous queue stream |
| `events.jsonl` | Structured events (zone / plot / frame / message) |
| `metadata.json` | Handshake, Welcome, protocol version, thread names, source locations and name caches |
| `stats.json` | Hotspot statistics: call count / total duration / mean / P50 / P95 / P99, plus frame-time statistics |

After the client exits, the receiver finalizes automatically, writes `stats.json` and terminates
on its own (exit code 0) — no manual interaction required.

> **Note** <br/>
> The bulky stream files (`raw_stream.bin` / `decompressed_stream.bin` / `events.jsonl`) are
> reproducible artifacts; long-term archiving only needs `stats.json` and `metadata.json`.

---

## tracy_queue_table.py

The Tracy protocol QueueType table, transcribed from upstream `tracy/public/common/TracyQueue.hpp`.
It is the single lookup source of the `tracy_receiver.py` parser.

- `PROTOCOL_VERSION = 82`; the index of `QUEUE_TYPE_ORDER` is the QueueType numeric value;
- `QUEUE_DATA_SIZE`: the wire payload size of each type (including the 1-byte QueueHeader);
- `STRING_TYPES` / `STRING_LEN_OFFSET` / `STRING_LEN_KIND` / `STRING_LEN_BIAS`: which types
  append a variable-length string after their fixed payload, the offset and kind of the length
  field, and the +256 bias of `SingleStringData`;
- `TIME_REF_KIND`: the timestamp restoration base of each type (`thread` / `serial` / `context` /
  `gpu` / absolute time).

When the upstream protocol changes (a Tracy version bump), this table must be updated in sync
and the parsing branches of `tracy_receiver.py` re-verified.

---

## tracy_hotspots.py

Formats the `stats.json` produced by `tracy_receiver.py` into a frame summary plus a
hotspot Top N table.

### Background

`stats.json` already aggregates per-zone call counts and duration percentiles (the
receiver computes them while finalizing), so this script only formats them — it is the
quick way to get a hotspot table right after a capture, without re-parsing the event
stream.

Division of labour with [`tracy_selftime.py`](./tracy_selftime.py): this script shows
**total** time (children included, with P50/P95 percentiles), while `tracy_selftime.py`
shows **self** time (children deducted, and it can recover zone names from source line
numbers when the client's zone names are lost). To find out what is actually slow, use
this script to locate the big blocks, then `tracy_selftime.py` to drill down.

### Usage

```bash
# Hotspot Top 25 (label "run")
python scripts/tracy_hotspots.py captures/t_base/stats.json run 25

# Default Top 25
python scripts/tracy_hotspots.py captures/t_base/stats.json
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `stats.json` | (required) | The hotspot statistics file produced by `tracy_receiver.py` |
| label | `run` | Capture name printed in the header (e.g. the project name) |
| `topN` | 25 | Number of rows in the hotspot table |

### Output

```
==== [base] frames=31851 mean=0.42ms p50=0.18ms p95=1.02ms p99=0.00ms ====
zone                              count    total(ms)    mean(us)     p50(us)     p95(us)
----------------------------------------------------------------------------------------
render                            31850    23326.827      732.40      493.31     2696.59
finishRender                      15924    8088.433      507.94      286.71     2417.07
beginRender                       15924     860.380       54.03       48.46       83.99
```

---

## tracy_selftime.py

Rebuilds the zone nesting from the event stream and reports each zone's call count,
total time and **self** time (total minus children).

### Background

The zone totals in `stats.json` **include all children**, so they cannot tell "this
layer is slow" from "a child is slow". For example `finishRender` owns a whole frame
while most of `drawLoop`'s total actually comes from `draw` — reading totals alone
misattributes a parent's cost to its child. This script rebuilds the nesting stack from
each zone event's (start time, duration, thread) and computes the self time.

The aggregation key is `name@line`: identically named zones in different places (e.g.
`ThreeRenderer.render` / `Renderer.render` / `EffectComposer.render`) stay separate.

In some captures the client's zone **name strings are lost** (shown as `0x...`
addresses): Tracy's static source locations are resolved by the server reading the
client's memory at the queried pointer, and a recycled string buffer can no longer be
read back. The event stream still carries the **source line number**, so the script
scans the engine source for `@Zone` declarations to build a "declaration line → zone
name" map and uses it as a fallback.

### Usage

```bash
# Hotspots + self time (Top 25)
python scripts/tracy_selftime.py captures/t_audio/events.jsonl 25

# With the source-line fallback (required when the client's zone names are lost)
python scripts/tracy_selftime.py captures/t_audio/events.jsonl 25 src
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `events.jsonl` | (required) | The structured event file produced by `tracy_receiver.py` |
| `topN` | 25 | Number of rows, ordered by total time |
| `src_root` | empty | Engine source root; when given, enables the line-number fallback for zone names |

### Output

```
zone@line                                 count    total(ms)    mean(us)     self(ms)    self(us)
----------------------------------------------------------------------------------------------------
execBgfxQueued@370                         3596   10352.552     2878.91    10352.552     2878.91
render@403                                 3585    9586.484     2674.05       22.779        6.35
finishRender@2237                          3584    3232.564      901.94     3232.564      901.94
beginRender@552                            3585     135.259       37.73      135.259       37.73
```

`self(us)` is the average self time after deducting the children — **use it to judge the
engine's own cost**.
