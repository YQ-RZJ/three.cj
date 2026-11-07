# Memory Leak Investigation Handbook

> This is an operating manual: anyone (developer, tester, maintainer) suspecting a memory leak in the engine should follow the SOP below and produce reproducible tracking data.

---

## 1. Scope & Environment

- Scope: the engine source (`src/`) and its callers (test projects under `test/`).
- Platform: Windows x64 + MinGW/D3D11 is the default verification platform; use the compiler (`cjc`) and package manager (`cjpm`) versions declared by the repository or newer.
- Language/runtime constraints: the engine is written in Cangjie with a generational GC, and uses bgfx as the render backend with explicit handle lifetimes. **The two resource classes have different leak criteria** (see Sections 2 and 3).

### 1.1 Build Environment Variable Standard

Set the following environment variables, then run `cjpm build`:

| Variable | Recommended value | Description |
|---|---|---|
| `EXTEDN_LIBS_PATH_WIN_X64` | path to local dependency libraries | Windows x64 native dependency search path |
| `EXTEDN_LINK_OPTION_WIN_X64` | empty | extra link options (usually empty) |
| `THREE_LOG_LEVEL` | `off` (memory measurement) / `info`, `debug` (feature debugging) | **compile-time** logging level; `info/debug` introduce allocation noise |
| `THREE_PROFILER` | `off` (memory measurement) / `all` or group prefix (profiling) | **compile-time** profiling switch |
| `cjHeapSize` | `4GB` for large projects | compiler JVM/parser heap size, unrelated to runtime heap |

> Notes:
> - `THREE_PROFILER` / `THREE_LOG_LEVEL` are **compile-time** switches; you must rebuild before changes take effect.
> - For memory measurement always use `THREE_LOG_LEVEL=off` and `THREE_PROFILER=off`; otherwise logging/instrumentation allocations pollute the statistics.
> - Comparative experiments must use **exactly the same build configuration**; otherwise the artifacts and allocation behavior are not comparable.

### 1.2 Build Strategy & Resource Constraints

- Each test project statically links the entire engine source; a single build is slow and resource-hungry. **Do not build multiple projects concurrently** — concurrency causes CPU/memory contention, slow builds, and even failures.
- **Always build sequentially, one project at a time**; before building, ensure no leftover compiler processes hold the incremental cache.
- When many projects need verification, do static convergence first (see Section 5) and rebuild only suspicious items instead of rebuilding everything.

---

## 2. Acceptance Criteria: What Counts as a Memory Leak

> Core principle: **RSS / private-memory growth alone never proves a leak.**

### 2.1 Conditions That Prove a Leak

A leak is confirmed if **any** of the following holds:

1. **Live heap keeps growing**: after forcing `gc()`, `getAllocatedHeapSize()` keeps rising with frames/iterations (monotonic across multiple sample points, with growth well above noise).
2. **Native graphics handles keep growing**: bgfx stats `numPrograms / numShaders / numTextures / numVertexBuffers / numIndexBuffers / numFrameBuffers / numUniforms` keep rising with frames.
3. **Native memory keeps growing**: external sampling (process private memory `PrivateMemorySize64`) keeps rising **after crossing multiple GC expansion steps** (distinguish from the misconceptions in Section 8).
4. **OS resources keep growing**: monotonically increasing handle count, thread count, or open file count (system-resource leaks).

### 2.2 Negative Criteria (Not a Leak)

- Cangjie GC uses **lazy expansion / generational collection**: even with a constant set of live objects, the host process private memory grows stepwise and then plateaus. This is normal behavior.
- A single step up followed by a plateau, with a step size matching the GC expansion threshold → most likely not a leak.
- Objects **intentionally retained by the tested code** (e.g. newly added scene objects on user actions, growing caches) are legitimate growth; judge against business logic, and do not confuse them with per-frame accumulation.

---

## 3. Tools & Information Sources

| Category | Tool / Material | Purpose |
|---|---|---|
| Compiler | `cjc` / `cjpm` | build, compile-time macro levels, run |
| Cangjie runtime | `std.runtime`: `gc()`, `getAllocatedHeapSize()`, `getGCCount()`, `getGCFreedSize()`, `dumpHeapData(Path)` | in-process heap stats / heap snapshots |
| Heap analysis | `cjprof heap`, `cjprof --dump-report`, `cjprof --show-reference` | object-type / reference analysis from snapshots |
| Graphics API | bgfx stats (exposed by the engine's Renderer via `getStats()`) | native graphics resource counts |
| Process monitor | OS process monitoring (working set / private memory / handles / threads) | non-intrusive external sampling |
| Engine profiler | built-in Profiler (Tracy) | frame timing / call hotspots; memory must be instrumented manually |
| Official docs | Cangjie compiler / runtime / stdlib authoritative contracts | semantics of `std.runtime`, `cjprof`, macros & conditional compilation |
| Upstream semantics | bgfx headers (`bgfx_create_program(vsh, fsh, destroyShaders)`, etc.) | handle ownership: with `destroyShaders=true` the shaders are owned by the program |
| Reference | three.js renderer/objects/textures/resource lifetimes | reference model for resource lifecycle & cache eviction |

> Information-source priority: **official Cangjie contracts > upstream (bgfx) semantics > engine internals > community references**. When semantics conflict, defer to official contracts and validate with a minimal repro experiment.

---

## 4. Resource Ownership Ledger

The first step is establishing an **ownership ledger** per resource type: creation point, destruction point, cache key, cache invalidation condition.

| Class | Creation | Destruction | Cache key | Invalidation |
|---|---|---|---|---|
| bgfx resources | `*_create_*` APIs | matching `*_destroy_*` | variant/geometry/material/texture ids | object removal, size/variant change, shader recompile |
| Native memory | `LibC.malloc` / C-string conversion | paired `LibC.free` / `AutoFreePtr` | — | all early-return branches |
| Threads/sync | `SThread`, `spawn`, mutex/cond/semaphore | exit & destroy | — | process exit / teardown |
| Audio | decoder / AL buffers / PCM | decoder uninit / buffer delete / free | audio id | reload, dispose |
| Physics | Jolt bodies / constraints / shapes | paired destroy (incl. cascade) | body id | body destruction, system shutdown |
| UI | ImGui context / fonts / glyphs | explicit finalize / destructor | font config | context shutdown |
| Events/caches | listener registrations, maps | bucket/entry removal | name/type keys | remove key when emptied |

---

## 5. Static Audit Method

Audit the code statically and flag suspicious sites **before** writing any probes:

### 5.1 Five Must-Check Items

1. **Per-frame hot paths calling `*_create_*`**: any uncached resource creation in render/draw/per-frame update is highly suspicious.
2. **Recompile/recreate paths destroying old handles first**: when a program (e.g. shader program) is compiled a second time, are the old program/shader/uniform released?
3. **Cache eviction entries**: for maps keyed by object id, is there a `remove + destroy` when the object is deleted? Is there eviction for cache keys not accessed this frame?
4. **Exception / early-`return` branches**: does a mid-path `return` after creation leak? Prefer `AutoFreePtr` / `try-finally`.
5. **Static collections**: do `static` `HashMap` / `ArrayList` only grow (listeners, window registry, resource registry, transform-slot registry, etc.)?

### 5.2 Guard-Direction Audit

Lesson from the past: **inverted guards** directly cause per-frame leaks.

- For example, `if (Handle.isValid(...)) { compile/create }` recreates every frame *when the handle is valid* — i.e. "create only when invalid" was written as "create when valid".
- For every guard (`isValid / isNone / size > 0 / isEmpty`), confirm the **semantic direction** matches the intent.

### 5.3 Macro & Conditional-Compilation Constraints

- Conditional-compilation directives **cannot appear inside macro-expanded code** (the compiler reports an error).
- For fields that must be gated by compiler version, put the conditional compilation on a **plain top-level declaration**, not on a class member decorated by another macro (e.g. a serialization adapter).

### 5.4 Common Checklist

- [ ] Vertex/index buffers cached by object + version; old buffers destroyed on version change
- [ ] Shader program variant cache + negative cache; old handles released before recompile
- [ ] Shadow/post-processing passes: cross-frame programs compiled once only, no per-frame recompilation
- [ ] Render-object cache: untouched keys evicted at frame end
- [ ] Audio: release old decoder/buffers before repeated `load()`; `dispose()` unregisters listeners/transform slots
- [ ] Physics: destroying a body cascades to its constraints; shutdown releases constraints before the system is destroyed; shapes freed on both success/failure branches
- [ ] UI: per-frame native strings freed after use; font-config classes have destructors
- [ ] Events: keys removed as soon as emptied; no residual empty buckets
- [ ] Window/input: unified cleanup on exception paths; temporary arrays (e.g. pad ids) freed on both paths
- [ ] Network/streaming: reconnect/timeout/close paths all release old sockets/buffers

---

## 6. Dynamic Monitoring Methods

Static audit only **locates suspects**; conclusions must come from dynamic monitoring. Four levels, from least to most intrusive:

### 6.1 Level 1: External Process Sampling (non-intrusive, batch screening)

Sample the target executable for 60–90 seconds:

```
time / working set / private memory / handle count / thread count
```

Interpretation:

- Observe the slope of the **tail after crossing multiple GC expansion steps**;
- Only a continuously rising tail (last ~20 s) is suspicious;
- Monotonically rising handles/threads must be logged separately (OS resource leak).

### 6.2 Level 2: In-Process Live Heap (did live objects really grow?)

Add a **temporary probe** (remove after judgment) in the per-frame callback that periodically forces GC and reads the live heap:

```cangjie
import std.runtime.*

if (frame % 300 == 0) {
    let before = getAllocatedHeapSize()
    gc()
    println("[heap] frame=${frame} before=${before} after=${getAllocatedHeapSize()} " +
            "gcCount=${getGCCount()} freed=${getGCFreedSize()}")
}
```

- `after` stays flat across sample points → no live-object leak;
- `after` rises monotonically → real leak.

### 6.3 Level 3: bgfx Resource Counts (native graphics handle leaks)

Periodically read and print graphics resource counts:

```cangjie
let st = renderer.getStats()
let s = unsafe { st.value.read() }
println("[stats] programs=${s.numPrograms} shaders=${s.numShaders} " +
        "textures=${s.numTextures} vbs=${s.numVertexBuffers} ibs=${s.numIndexBuffers} " +
        "fbs=${s.numFrameBuffers} uniforms=${s.numUniforms}")
```

- Counts constant → no handle leak;
- Counts rising per frame → unpaired `*_create_*`.

> Print every 60–120 frames; to keep measurement windows consistent, let the test request window close after a fixed frame count.

### 6.3.1 Rebuild-Cycle Method (key validation for lifecycle-class leaks)

**Scope**: A probe that merely runs once and creates handles a single time **cannot detect lifecycle-class leaks** — e.g. `EffectComposer` / Pass create new resources only when they are **rebuilt or swapped**; if the old instance's `dispose()` fails to release its private handles, every rebuild accumulates. Such leaks are exposed only by repeatedly creating/destroying the same resource chain.

**Procedure**: In the per-frame callback, periodically run "create full resource chain → run some frames → dispose old chain → rebuild the same chain" while printing resource counts:

```cangjie
import std.runtime.*

// Rebuild the EffectComposer chain every 400 frames; watch whether uniforms/programs accumulate
if (frame % 400 == 0) {
    let st = renderer.getStats()
    let s = unsafe { st.value.read() }
    let before = getAllocatedHeapSize()
    gc()
    println("[rebuild] frame=${frame} uniforms=${s.numUniforms} programs=${s.numPrograms} " +
            "shaders=${s.numShaders} heapBefore=${before} heapAfter=${getAllocatedHeapSize()}")
    match (this.composer) {
        case Some(old) =>
            old.dispose()
            let nc = EffectComposer(renderer)
            nc.addPass(RenderPass(scene, camera))
            nc.addPass(BloomPass(...))
            nc.setSize(Int64(w), Int64(h))
            this.composer = Some(nc)
        case None => ()
    }
}
```

- After N rebuilds, resource counts **stay constant** (e.g. uniforms=27 unchanged) → lifecycle release is correct;
- Counts grow **linearly** with rebuild count (+K uniforms/programs/shaders per cycle) → `dispose()` lacks paired releases; add `_disposePassUniforms()` / `destroy*` one by one.

> Verified: bloom_basic rebuilt 6 times (2400 frames); uniforms/programs/shaders/textures/vbs/ibs/fbs all stayed constant, confirming the `Pass._disposePassUniforms()` fix is effective.
> **Extending a single-run frame count does NOT expose this class of leak** (handles are created once); the rebuild cycle is required.

### 6.4 Level 4: Profiler / Heap Snapshot (locate path & object types)

- **Profiler (Tracy)**: confirms the frequency/cost anomaly of a leak path (e.g. "recompiling a shader every frame" shows up as a hotspot). The memory panel only shows explicitly instrumented memory, not the GC heap or bgfx internals — therefore it is **not the primary basis** for leak decisions.
- **Heap snapshot + cjprof**: export heap data at a suspicious moment and analyze object types/reference chains with `cjprof heap`.

> Practically: snapshot APIs may behave inconsistently across platforms/runtime versions (possibly generating empty files or blocking). **Prefer 6.2 / 6.3 for judgment; use snapshots only to identify object types.**

---

## 7. Diff & Validation

1. **Baseline comparison**: use the simplest scene (single basic object, no post-processing/shadows) as the baseline; if the baseline live heap is stable after GC, the difference must come from a specific module.
2. **Before/after comparison**: same test, same build configuration, same run duration, same measurement window; compare tracking data.
3. **Resource-count regression**: after a fix, key counts must stay **completely unchanged** over hundreds of frames.
4. **Functional regression**: after releasing handles, run the corresponding test to confirm rendering/behavior is correct, and avoid destroying resources still in use.

---

## 8. Common Misjudgments & Pitfalls

1. **GC lazy expansion**: host private memory jumps in fixed steps then plateaus — not a leak. Quick test: if adjacent-sample growth concentrates on **multiples of 64 MB** with plateaus between steps → likely GC expansion; a real per-frame leak usually looks like **continuous, non-quantized, no-plateau** linear growth. Final conclusions must return to the 6.2 live-heap check.
2. **bgfx handles are not OS handles**: `numPrograms / numShaders` growth is invisible in the process handle count; use graphics resource stats.
3. **Full rebuilds are expensive**: statically linking the whole engine is slow; converge statically then rebuild selectively.
4. **Heap-snapshot platform differences**: see 6.4.
5. **Macro levels change artifacts**: different log/profiling levels produce different code and allocation behavior; comparative experiments must keep levels identical.
6. **Logging itself allocates**: string concatenation at `info/debug` pollutes heap stats; use `off` for memory measurement.
7. **Legitimate growth ≠ leak**: objects a test intentionally adds per stage, cache entries, etc., are legitimate; distinguish from per-frame accumulation.

---

## 9. Standard Operating Procedure (SOP)

1. Set build environment variables (see 1.1); `cjpm build` passes.
2. Run the **baseline project** first: external sampling (6.1) + in-process live heap (6.2) to confirm the baseline is stable.
3. Pick the test project covering the target module (each test project usually covers different modules; see module mapping).
4. Do the static audit (Section 5) first; flag suspicious creation sites / guards / caches to narrow the scope.
5. Add temporary probes (6.2 + 6.3); run hundreds of frames or more, auto-terminating at a fixed frame count for a consistent window.
6. Judge (Section 2):
   - live heap or resource counts keep growing → leak;
   - only external private memory grows stepwise → record as "GC expansion", not a leak.
7. Fix: paired release, cache eviction, guard direction, `dispose` cleanup, exception-path coverage.
8. Re-test: resource counts constant + live heap flat + functionality correct.
9. **Remove temporary probes**, and record run method, measurement window, and conclusion in the tracking log (see 9.1).

### 9.1 Tracking-Log Template

| Field | Content |
|---|---|
| Project under test / modules covered |  |
| Build configuration (log/profiling) | `THREE_LOG_LEVEL` = ?, `THREE_PROFILER` = ? |
| Executable / run method |  |
| Duration / frames |  |
| Live-heap trend (after gc) | flat / steps-then-flat / monotonic-up |
| Graphics resource counts | constant or varying; describe pattern if varying |
| Handles / threads |  |
| Static-audit findings | suspicious sites & disposition |
| Conclusion | no leak / fixed / needs retest |
| Notes | evidence for GC-expansion-vs-leak discrimination |

> The log is the regression baseline: same project, same configuration, same window — conclusions must be reproducible.

---

## 10. Limitations

- **External sampling cannot read the Cangjie heap**: GC expansion is easily misread; definitive conclusions require in-process probes (6.2).
- **Graphics resource counts cover only bgfx**: CPU-side collection caches, event listeners, threads, etc., need static audit + live-heap trend.
- **Eviction under dynamic add/remove**: current caches may lack eviction callbacks when objects/materials/textures are deleted at runtime; long-running apps that add/remove resources need a removal-notification chain and frame-end eviction.
- **Many projects, slow builds**: full per-project verification is expensive; when coverage of all projects is required, verify representative projects in-process per module mapping, batch-screen the rest with 6.1, and advance strictly sequentially.
- **Platform & tool-version differences**: heap snapshots and runtime stats may vary with compiler/runtime versions; record the verification environment in the conclusion.
