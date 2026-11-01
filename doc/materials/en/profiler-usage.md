# three.profiler Usage Guide and Constraints

The `three.cj` engine ships a built-in profiling module at `src/profiler` (packages `three.profiler` and its macro package `three.profiler.macros`), built on [Tracy](https://github.com/wolfpld/tracy) (tracy4cj bindings). It collects function timing zones, frame marks, plot curves, messages, memory events, GPU timing domains, lock contention, and call-stack sampling. A sample project lives at `test/general/test_profile`.

> **Note** <br/>
> - Profiling data is sent via the Tracy protocol; start the Tracy GUI (built from the tracy4cj repository) before running the program to view it. Without a GUI the program runs as usual and data is silently discarded.
> - Before running the sample project, download the required library files into the `three/libs` directory first.

---

## Table of Contents

- [I. Two-Layer Design](#i-two-layer-design)
- [II. The THREE_PROFILER Environment Variable](#ii-the-three_profiler-environment-variable)
- [III. Runtime Facade API (Unconditionally Instrumented)](#iii-runtime-facade-api-unconditionally-instrumented)
- [IV. Auto-Instrumentation Macros (Compile-Time Prunable)](#iv-auto-instrumentation-macros-compile-time-prunable)
- [V. Usage Constraints](#v-usage-constraints)
- [VI. Sample Project test_profile](#vi-sample-project-test_profile)
- [VII. Headless Capture and Performance Baseline](#vii-headless-capture-and-performance-baseline)

---

## I. Two-Layer Design

| Layer | Package | Gating | Use case |
|---|---|---|---|
| Runtime facade | `three.profiler` | No env gating; calling is instrumenting | Manual, fine-grained profiling points |
| Auto-instrumentation macros | `three.profiler.macros` | Reads `THREE_PROFILER` at compile time; zero intrusion on miss | Declarative instrumentation with a global switch |

Macro expansions reference facade types (`ProfZone` / `ProfFrame` / `ProfPlot`, ...), so **any file that uses the macros must import both packages**:

```cangjie
import three.profiler.*         // facade (classes carry the Prof prefix, no clash with macro names)
import three.profiler.macros.*  // macro package
```

---

## II. The THREE_PROFILER Environment Variable

Macros read the environment variable `THREE_PROFILER` **at compile time (during macro expansion)** and match it against the **link path** declared in the attribute (e.g. `three.test.aaa.bbb`) using **segment-level prefix matching** (segments split on `.`; `three.b` is NOT a prefix of `three.bbb`):

```
THREE_PROFILER=off                      # zero intrusion everywhere (default; unset behaves as off)
THREE_PROFILER=all                      # instrument everything (on / full are equivalent)
THREE_PROFILER=three                    # instrument links starting with "three"
THREE_PROFILER=three.test               # links with prefix "three.test"
THREE_PROFILER=three.render,three.test  # comma-separated list; any hit instruments
```

- On a miss the macro **returns the input tokens untouched** (zero intrusion), as if the macro did not exist; the binary matches a non-instrumented build.
- When the attribute omits the link, the default link is `three`.

> **Note** <br/>
> The variable takes effect at **build time**, not runtime: after changing `THREE_PROFILER` you must rebuild to change the instrumentation level. The switch **only affects macros**; direct facade API calls are always active.

---

## III. Runtime Facade API (Unconditionally Instrumented)

Package `three.profiler`: direct API calls express explicit profiling intent and are always active regardless of environment variables.

### ProfZone — timing zones

Three usages:

```cangjie
// 1. Manual RAII (attach text/value/color/rename before closing)
let z = ProfZone("myZone", file, line, funcName)
z.text("vertexCount=1024")
z.value(1024)
z.close()

// 2. try-with-resources (implements Resource; close is called automatically on exit)
try (z = ProfZone("myZone", file, line, funcName)) {
    // code inside the zone
}

// 3. Macro (recommended; compile-time prunable, see section IV)
```

The color parameter is `0xAABBGGRR`; `0` means Tracy's default palette.

Source locations use the **static path** (equivalent to Tracy's official `TRACY_ZONE_SCOPED` macro): for each `(name, file, line)` key the Cangjie side allocates a long-lived `TracySourceLocationData` struct plus its C strings exactly once and caches them permanently; every zone begin then only emits a pointer, so repeatedly entering the same zone costs no extra allocation.

### Other facade APIs at a glance

| Class | Purpose | Entry points |
|---|---|---|
| `ProfFrame` | Frame marks: `mark()` once per main-loop iteration; secondary streams pair same-name `start(name)`/`finish(name)` | `mark` / `start` / `finish` / `image` |
| `ProfPlot` | Time-series value curves (same-name points form one curve) | `point` / `pointF32` / `pointI64` / `config` |
| `ProfMessage` | Text in the Tracy message panel (`severity` maps to level and color) | `logTrace`…`logFatal` / `appInfo` |
| `ProfMemory` | Manual alloc/free annotations (wrap custom pools) | `alloc` / `free` / `discard` |
| `Gpu` | GPU context registration and timestamp reporting | `newContext` / `zoneBegin` / `zoneEnd` / `time` |
| `Lock` | Lock contention tracking (announce lockable context + before/after events) | `announce` / `beforeLock` / `afterLock` / `afterUnlock` |
| `ProfFiber` | Fiber/coroutine switch marks (`enter`/`leave` strictly paired) | `enter` / `leave` |
| `Sampling` | Call-stack sampling start/stop | `start` / `stop` |
| `ProfilerState` | Connection status, clock, thread name | `isConnected` / `now` / `threadName` |

Three `Resource`-implementing scope classes are also available for try-with-resources (they are the macro expansion targets): `ProfGpuZone` (GPU command span), `ProfLockZone` (scope-lock semantics: enter = held, unlock reported on exit), and `FiberScope` (fiber scope).

---

## IV. Auto-Instrumentation Macros (Compile-Time Prunable)

Package `three.profiler.macros`. Every macro declares attribute parameters, so **calls must carry the `[link]` attribute**. Two call forms:

1. **Function-level** (`@Zone` only): annotates a function declaration; the body is rewritten into a `try{}finally{}` wrapper so exceptions/`return` still end the timing correctly;
2. **Span/expression-level** (all macros): `@X[link]( code )` wraps arbitrary code, usable in statement or expression position.

| Macro | Expansion | Notes |
|---|---|---|
| `@Zone` | Wraps in a Zone; display name is the last link segment | Optional `color=0xAABBGGRR` |
| `@FrameMark` | `code; Frame.mark(name)` | Main-frame mark |
| `@FrameStart` / `@FrameEnd` | Inserts named-frame-stream start/finish before/after the code | Pair by name |
| `@Plot` | Evaluates the expression → reports a Float64 plot point → passes the value through | Expression must implicitly convert to Float64 |
| `@PlotI64` | Same as `@Plot` for Int64 | |
| `@Message` | Evaluates the expression → reports it as a message → passes the value through | Optional `severity=trace\|debug\|info\|warning\|error\|fatal` (default info); type must implement ToString |
| `@Fiber` | Wraps in `enter`/`leave` | |
| `@MemAlloc` | Evaluates a pointer → reports an alloc event → passes the pointer through | Expression must be a CPointer; optional `size=<expr>` (default 0) |
| `@MemFree` | Evaluates a pointer → reports a free event → passes the pointer through | Expression must be a CPointer |
| `@GpuZone` | Wraps GPU command recording in a GpuZone scope (begin/end paired automatically) | Optional `context=<expr>` (default 0); timestamps are still reported by the render backend via `Gpu.time(gpuTime, gz.query, gz.ctx)` after fence readback |
| `@LockTrack` | Wraps a critical section into the lock timeline | Scope-lock semantics: enter = held; for true lock/unlock granularity use the `Lock` static API by hand |

### Usage examples

```cangjie
import three.profiler.*
import three.profiler.macros.*

// Function-level: the whole body becomes a zone (link three.render.shadow)
@Zone[three.render.shadow]
func renderShadow(): Unit { ... }

// Span-level (arbitrary code inside the parentheses)
@Zone[three.render.culling]( cullPass() )
@Fiber[three.jobs.worker]( workerLoop() )
@GpuZone[three.gpu.pass, context=0]( recordPass() )
@FrameStart[three.frame.render]( renderScene() )
@FrameMark( stepSimulation() )

// Value pass-through (expression position; the value joins outer computation as usual)
let fps = @Plot[three.plot.fps]( computeFps() )
let n   = @PlotI64[three.plot.batch]( batchCount() )
let s   = @Message[three.msg.state, severity=debug]( currentState() )
let p   = @MemAlloc[three.pool.geo, size=n*64]( pool.alloc(n) )
@MemFree[three.pool.geo]( pool.free(p) )
```

---

## V. Usage Constraints

1. **Import both packages**: any file using a macro must `import three.profiler.*` AND `import three.profiler.macros.*`. Macro expansions reference facade type names (`ProfZone`, ...), supplied by the wildcard facade import; facade classes carry the `Prof` prefix, so they never clash with macro names.
2. **Attribute is mandatory**: every macro in this package declares attribute parameters; calls must carry `[link]` (e.g. `@Zone[three]`). The first attribute segment without `=` is the link; the rest are parsed as `k=v` (`color` / `severity` / `size` / `context`).
3. **Do not mix macro forms**: `@Zone` may either annotate a function declaration or wrap code; `@Plot`/`@PlotI64`/`@Message`/`@MemAlloc`/`@MemFree` are expression macros and **cannot annotate declarations** — they are only valid in expression position.
4. **Expression type constraints**: `@Plot` results must implicitly convert to `Float64`; `@PlotI64` is `Int64`; `@Message` types must implement `ToString`; `@MemAlloc`/`@MemFree` expressions must be CPointers.
5. **Pair facade scope classes correctly**: `ProfZone` / `ProfGpuZone` / `ProfLockZone` / `FiberScope` all implement `Resource`; prefer try-with-resources or macro wrapping over a hand-written `close()` (close is idempotent, but missing it means the span never ends).
6. **Frames and fibers pair strictly**: `ProfFrame.start(name)`/`finish(name)` must pair by name (multiple streams may run in parallel); `ProfFiber.enter(name)`/`leave()` must pair strictly, otherwise events are attributed to the wrong flow.
7. **Memory events come in pairs**: report `ProfMemory.alloc`/`free` pairs by `(ptr, size)`; for whole-pool teardown use `discard(name)` to zero out a named pool instead of freeing pointer by pointer.
8. **Distinguish lock semantics**: `@LockTrack` has scope-lock semantics (enter = held, unlock reported on exit); for true lock/unlock granularity use the `Lock` static API by hand, and keep the handle returned by `announce` alive long-term (Tracy keeps only the pointer, no copy).
9. **GPU flow depends on the backend**: `@GpuZone`/`Gpu` only emit begin/end with a query pairing; GPU timestamps must be reported by the render backend via `Gpu.time` after fence/query readback, or the GPU panel stays empty.
10. **Instrumentation level is fixed at compile time**: `THREE_PROFILER` affects the built artifact; switching levels (`off` ↔ `all` ↔ links) requires a rebuild. For release builds keep `off` (the default) — macros expand to nothing with zero runtime overhead.
11. **Link naming convention**: name links hierarchically by module (e.g. `three.render.shadow`, `three.test.zone.func`); segment-level prefix matching then lets you toggle whole modules. The display name is the last link segment, so keep it distinguishable within a module.
12. **Viewing the data**: start the Tracy GUI (built from tracy4cj) first, then run the target program to connect automatically; use `ProfilerState.isConnected()` to check connection status. Without a GUI the program runs as usual; when on-disk artifacts and automated statistics are needed, use `scripts/tracy_receiver.py` described in section VII.
13. **Source locations (srcloc) must always use the static path**: `ProfZone` / `ProfGpuZone` internally cache a long-lived `TracySourceLocationData` struct per `(name, file, line)` and emit it by pointer, which is equivalent to Tracy's official macros; **never** cache a dynamic alloc handle and reuse it across zones — the worker frees that pointer as soon as it consumes a `ZoneBeginAllocSrcLoc` event (one-shot consumption semantics), so reusing a freed pointer causes use-after-free / double-free and shows up in the captured data as garbled zone names, `line=0`, or odd lengths. The `srcloc` argument of `Gpu.zoneBegin(srcloc, ...)` follows the same rule and must be a static srcloc pointer address.

---

## VI. Sample Project test_profile

The sample project lives at [`test/general/test_profile`](../../../test/general/test_profile/) and covers all common macros of `three.profiler.macros`: function-level/span-level `@Zone`, `@FrameMark`/`@FrameStart`/`@FrameEnd`, `@Plot`/`@PlotI64`, `@Message`, `@Fiber`, `@MemAlloc`/`@MemFree`, and `@LockTrack`.

How to run (the instrumented links are decided by the compile-time environment variable `THREE_PROFILER`):

```bash
set THREE_PROFILER=all        # instrument everything
set THREE_PROFILER=three.test # only three.test.* links
set THREE_PROFILER=off        # zero intrusion (default)
cjpm run
```

The program also prints a console profiling report (zone timing cross-check + duration statistics); with the Tracy GUI connected you will see all of the links above.

---

## VII. Headless Capture and Performance Baseline

The Tracy GUI requires manual interaction, so it cannot run in a CI pipeline. The project ships `scripts/tracy_receiver.py`, which plays the role of the Tracy GUI/Worker: it connects to the profiled process on its own, writes the full wire protocol stream to disk, and produces the statistics directly.

### 7.1 Receiver

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

Artifacts (in the `--out` directory):

| File | Content |
|---|---|
| `raw_stream.bin` | Raw wire stream, written block by block as `[uint32 size][compressed bytes]` |
| `decompressed_stream.bin` | The LZ4-stream-decompressed contiguous queue stream (64 KiB dictionary shared across blocks) |
| `events.jsonl` | Structured events (zone / plot / frame / message) |
| `metadata.json` | Handshake, Welcome, protocol version, thread names, source locations and name caches |
| `stats.json` | Hotspot statistics: call count / total duration / mean / P50 / P95 / P99, plus frame-time statistics |

After the client exits, the receiver finalizes automatically, writes `stats.json` and terminates on its own (exit code 0) — no manual interaction required.

### 7.2 Performance Baseline Test Project

[`test/windows/perf_render`](../../../test/windows/perf_render/) is a real-render-path performance test program used together with the receiver:

- **Real pipeline**: it goes through the full `ThreeRenderer.render(scene, camera)` chain (`_render` → `_collectRenderObjects` → `RenderList.sort/finish` → `BgfxBackend.draw`); all instrumentation points sit on the real `three.rendering.*` hot path;
- **Deterministic**: fixed camera (constant position/orientation), fixed object scale (FEW=25 / MANY=800 cubes in a deterministic grid), fixed measurement plan (60 warmup frames + 240 measured frames per stage); stages advance automatically and the program exits automatically;
- **Frame marks**: `ProfFrame.mark()` every frame, which the receiver uses for frame-time statistics.

How to run (PowerShell):

```bash
$env:EXTEDN_LIBS_PATH_WIN_X64="<three.cj>/libs"
$env:THREE_PROFILER="three.rendering,three.perf"   # compile-time level; a rebuild is required to switch it
cd test/windows/perf_render
cjpm build
# start the receiver in another terminal, then run the profiled program
python ../../../scripts/tracy_receiver.py --out captures/perf_run --port 8086 --scan-timeout 120
```

> Note: `THREE_PROFILER` is a **compile-time** switch — you must re-run `cjpm build` after changing it; the receiver and the profiled program must run in parallel.

### 7.3 Baseline Sample

`captures/perf_run3/stats.json` (a clean capture taken after the srcloc lifetime fix; 21 zone entries, `errors` empty):

| Metric | Value |
|---|---|
| Capture duration | 79.2 s (1841 blocks, 25.3 MB raw / 39.8 MB decompressed, compression ratio 0.63) |
| Frame samples | 587 |
| Frame time | mean 122.4 ms / P50 17.1 ms / P95 324.3 ms / P99 392.2 ms |
| `render` | 1178 calls / 147.0 s |
| `_execBgfx` | 591 calls / 74.0 s |
| `draw` | 149687 calls / 14.8 s (mean 99 µs) |
| `_getOrCreateProgram` | 149686 calls / 3.0 s |
| `_createVB` / `_createIB` | 149686 calls / 0.75 s, 0.30 s |

The hotspots concentrate on per-frame draw submission and uniform/texture binding (`draw` / `_drawRenderObject` / `bindShadowUniforms`), which is the main entry point for further performance tuning.
