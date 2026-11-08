<div align="center">
<img alt="" src="./doc/asstes/three.cj-logo.svg" style="display: inline-block;width:128px;height:128px"/>
<h1>three.cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/version-1.0.0-red" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.1.0 STS-yellow" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/domain-Computer_Graphics-8A2BE2" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/platform-Cross--Platform-lightgrey" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/Apache_2.0_License-gold" style="display: inline-block;" />
</p>

## Introduction

**three.cj** is a 3D engine runtime implemented in the [Cangjie programming language](https://cangjie-lang.cn/). It provides a full suite of 3D rendering capabilities including Scene Graph, Entities (Mesh/Points/Line/Sprite, etc.), Materials, Lights, Cameras, Geometry, Shaders, and Post-processing. It also integrates subsystems for Audio (OpenAL), Physics (Jolt), Scripting (LuaJIT), Networking (OpenSSL), Window/Input (SDL3), User Interface (IMGUI), and Profiling (Tracy, with zero-intrusion compile-time macros), covering common needs for 3D application and game development.

> **Note** three.cj is the first fully-featured game engine runtime for the Cangjie language. It offers strong extensibility and customization capabilities, but building complex games directly on top of it involves significant effort. The author recommends wrapping it into a higher-level framework or editor first — or leveraging AI engineering capabilities — before undertaking complex game projects.

### Tutorials & Examples

This project is actively maintained. Follow [Bilibili UID:3546853029185667](https://space.bilibili.com/3546853029185667) for video tutorials and latest updates!

> **Note** Test and example code can be found here: [Link](./doc/materials/en/test-windows-projects.md)

## Features

### 🎯 Core Features

- **Cross-Platform Rendering Backend** — Hardware-accelerated rendering on Windows / HarmonyOS Next / macOS / Linux / Android / iOS and more
- **Complete Scene System** — Scene Graph, Object3D, Cameras, Lights, Materials, Geometry, Render Targets, Helpers, and more
- **Pure Cangjie Math Library** — Vectors (Vector2/3/4), Matrices (Matrix2/3/4), Quaternions, Euler Angles, Colors, Bounding Boxes/Spheres/Planes/Rays, etc.
- **Rich Geometry & Curves** — Box/Capsule/Cone/Cylinder/Sphere/Torus/Extrude/Polyhedron and other parametric geometries, plus Bezier/Spline curves and paths
- **Multiple Material Types** — MeshBasic/Lambert/Phong/Standard/Physical/Toon/Matcap/Normal/Depth materials with custom ShaderMaterial support
- **Complete Post-Processing Pipeline** — FXAA/SMAA/SSAO/SSR/GTAO/Bloom/UnrealBloom/Outline/Glitch/Halftone and 30+ post-processing passes
- **Asset Loading System** — glTF/OBJ/MTL/PLY/STL models, DDS/KTX/PVR/EXR/HDR/TGA textures, Font/Animation/Audio loaders with caching and serialization
- **Asset Pipeline** — AssetBundle pack/read by name + AssetManager async frame-spread loading + AssetCache ref-counted unloading
- **Animation System** — AnimationClip / AnimationMixer / AnimationAction / KeyframeTrack (Boolean/Color/Number/Quaternion/String/Vector)
- **Physics Engine Integration** — Pluggable physics backend based on Jolt, running on an independent physics thread, supporting rigid bodies, characters, constraints, and Object3D binding, plus extended physics objects such as heightfield terrain, soft bodies/cloth, vehicles, and ragdolls, along with a physics debug renderer
- **Audio Subsystem** — Based on OpenAL: audio context / listener / static · positional · streaming sources / recording / EFX effects & filters
- **Scripting System** — Based on LuaJIT, with bidirectional Cangjie-Lua binding and script hot-reloading
- **Game Networking Stack** — PacketWriter/PacketReader protocol codec + Connection/ReliableChannel reliable transport + Lockstep lockstep/SnapshotBuffer snapshot interpolation
- **Window & Input Engine** — Cross-platform window engine v2 based on SDL3 (lifecycle callbacks + per-window independent event pump), with keyboard/mouse/touch/gamepad input providers
- **GUI Subsystem** — Immediate-mode UI based on ImGui (imgui4cj) (`three.window.ui`): enabled with a single call to `WindowEngine.useGui()`, with SDL3 event bridging and the bgfx rendering backend wired up automatically (both routed to their corresponding system threads); provides 30+ widgets (windows/buttons/input fields/sliders/trees/list boxes/color pickers, etc.) plus layout/menus/tabs/tables/popups/drag-drop/font/style themes/custom draw-list capabilities
- **Profiling Subsystem** — Real-time profiling based on Tracy (tracy4cj) (`three.profiler`): CPU zones, frame marks, plots, messages, memory events, GPU timing domains, lock contention, fibers, and call-stack sampling; scope classes (ProfZone/ProfGpuZone/ProfLockZone/FiberScope) implement the `Resource` interface for direct use with try-with-resources; facade classes carry the `Prof` prefix (ProfZone/ProfFrame/ProfPlot/ProfMessage/ProfFiber/ProfMemory, etc.) so they never clash with same-named macros — `import three.profiler.*` and `import three.profiler.macros.*` can coexist
- **Zero-Intrusion Macros in Release Builds** — Both the logging (`three.utils.log` macro package) and profiling (`three.profiler.macros` macro package) read their environment variables **at compile time (macro expansion) and bake the result into the binary**: with `THREE_LOG_LEVEL=off` and `THREE_PROFILER=off` in a release build (both off by default), every call site — including argument evaluation and string interpolation — generates no instructions, producing binaries identical to hand-written un-instrumented code; when a link matches, macros expand into try{}finally{} wrappers that close correctly on both the exception and return paths
- **Multi-DPI / High Pixel Density Support** — Based on SDL3's `SDL_WINDOW_HIGH_PIXEL_DENSITY`; `WindowEngine` provides `getPixelRatio` / `getDrawableSize`, `Renderer` separates logical and physical sizes, and post-processing RTs scale automatically by DPR
- **ECS Framework** — Built-in Entity-Component-System with macro-assisted component/entity/system definitions and runtime registration
- **Frame Dispatcher** — Forced queue + priority queue, trimmed by time budget to prevent single-frame timeout
- **Cross-Platform** — Supports OpenHarmony, Windows, Linux, macOS, Android/iOS, and more

### 📦 Sub-Package Structure

| Sub-Package | Description | Directory |
|-------------|-------------|-----------|
| `three.animation` | Animation system (clips, blending, action scheduling, keyframe tracks) | `src/animation/` |
| `three.audio` | Audio subsystem (OpenAL: context/listener/sources/recording/EFX) | `src/audio/` |
| `three.core` | Core infrastructure (math, data structures, events, frame dispatch, threads, time) | `src/core/` |
| `three.network` | Networking module (HTTP / Socket / protocol codec / reliable transport / lockstep & snapshot interpolation) | `src/network/` |
| `three.network.protocol` | Game protocol codec (PacketWriter/PacketReader big-endian streams) | `src/network/protocol/` |
| `three.network.transport` | Reliable transport (TCP Connection framing/heartbeat/reconnect + UDP ReliableChannel) | `src/network/transport/` |
| `three.network.sync` | Sync models (LockstepSession deterministic lockstep + SnapshotBuffer interpolation) | `src/network/sync/` |
| `three.physics` | Physics system (Jolt: world/rigid bodies/characters/constraints/binding/heightfield/soft bodies/vehicles/ragdolls/debug rendering) | `src/physics/` |
| `three.profiler` | Profiling subsystem (Tracy: zones/frame marks/plots/messages/memory/GPU timing/locks/fibers/sampling, plus auto-instrumentation macros) | `src/profiler/` |
| `three.rendering` | Rendering system (bgfx backend, cameras, geometry, materials, lights, post-processing, shaders) | `src/rendering/` |
| `three.resource` | Asset loading & caching (model/texture/animation loaders, serialization, asset pipeline) | `src/resource/` |
| `three.resource.pipeline` | Asset pipeline (AssetBundle pack/read, AssetManager async frame-spread loading, AssetCache ref-counted unloading) | `src/resource/pipeline/` |
| `three.scene` | Scene management (scene graph, entities, ECS, Object3D, raycasting) | `src/scene/` |
| `three.script` | Scripting system (LuaJIT VM, bidirectional binding, hot-reloading) | `src/script/` |
| `three.utils` | Utility library (logging, encoding, object pool, memory, allocator) | `src/utils/` |
| `three.window` | Window & input engine (SDL3 window, input providers) | `src/window/` |
| `three.window.ui` | GUI subsystem (ImGui widgets/windows/layout/menus/tabs/tables/popups/drag-drop/fonts/styles/draw lists/viewports/storage) | `src/window/ui/` |

## Project Structure

> Note: The directory tree only shows directory-level structure; individual files are not listed due to their volume.

```
three/
├── doc/                    # Project documentation
│   ├── api/                # API documentation
│   ├── asstes/             # Documentation assets
│   ├── dev manual/         # Development manual
│   └── materials/          # Project materials (test-case project notes, etc.)
├── libs/                   # Native library directory (static libs for per-platform test linking, incl. exclude.rsp and symbols_elf.map)
├── scripts/                # Helper scripts (see scripts/README.md)
├── src/                    # Cangjie engine source (main body of this README)
│   ├── animation/          # Animation system
│   │   ├── blend/          # Animation blending & action scheduling (AnimationMixer/Action/KeyframeTrack/PropertyBinding)
│   │   ├── clip/           # Animation clips (AnimationClip/AnimationUtils)
│   │   ├── interfaces/     # Cross-package decoupling interfaces
│   │   └── tracks/         # Keyframe tracks (Boolean/Color/Number/Quaternion/String/Vector)
│   ├── audio/              # Audio subsystem (OpenAL)
│   │   ├── capture/        # Recording (AudioRecorder)
│   │   ├── device/         # Audio context (AudioContext)
│   │   ├── interfaces/     # Audio interface contracts
│   │   ├── listener/       # Audio listener (AudioListener)
│   │   ├── mixer/          # EFX effects & filters (AudioEffect/AudioFilter/AudioEffectSlot)
│   │   └── source/         # Audio sources (Audio/PositionalAudio/StreamingAudio/AudioBuffer)
│   ├── core/               # Core infrastructure
│   │   ├── dispatch/       # Frame dispatch (FrameDispatch/FrameTask)
│   │   ├── dsa/            # Data structures (BinaryHeap/BinaryPatriciaTrie/BitArray/Queue/RingBuffer/Stack...)
│   │   ├── event/          # Event system (EventDispatcher/EventFactory/EventManager)
│   │   ├── interfaces/     # Infrastructure interface contracts
│   │   ├── math/           # Math library (vector/matrix/quaternion/color/interpolation/bounding box/ray...)
│   │   │   └── interpolants/ # Interpolants (linear/Bézier/discrete/cubic/quaternion)
│   │   ├── system/         # System info (System/SystemInfo)
│   │   ├── thread/         # Threading & synchronization (Thread/SThread/Sync/RecursiveMutex)
│   │   └── time/           # Time (Clock/Timer)
│   ├── network/            # Networking module
│   │   ├── http/           # HTTP client (via httpclient4cj)
│   │   ├── protocol/       # Game protocol codec (PacketCodec: PacketWriter/PacketReader big-endian streams)
│   │   ├── socket/         # Socket client/server/UDP
│   │   ├── sync/           # Sync models (Lockstep: LockstepSession deterministic lockstep/SnapshotBuffer interpolation)
│   │   └── transport/      # Reliable transport (Connection: TCP framing/heartbeat/reconnect; ReliableChannel: reliable UDP)
│   ├── physics/            # Physics system (Jolt)
│   │   ├── backend/        # Physics backend adapter (JoltBackend)
│   │   ├── binding/        # Object3D ↔ RigidBody binding (PhysicsBinding)
│   │   ├── body/           # Rigid body (RigidBody)
│   │   ├── character/      # Character controller (Character)
│   │   ├── constraint/     # Constraints/joints (Constraint)
│   │   ├── debug/          # Physics debug rendering (DebugRenderer: line/triangle cache bridging)
│   │   ├── heightfield/    # Heightfield terrain (HeightField)
│   │   ├── interfaces/     # Pluggable backend abstraction (IPhysicsBackend)
│   │   ├── ragdoll/        # Ragdoll (Ragdoll)
│   │   ├── softbody/       # Soft bodies/cloth (SoftBody)
│   │   ├── vehicle/        # Vehicle (wheels/suspension/engine/differential)
│   │   └── world/          # Physics world facade (PhysicsWorld, independent physics thread)
│   ├── profiler/           # Profiling subsystem (Tracy)
│   │   └── macros/         # Auto-instrumentation macros (@Zone/@Plot/@Message/..., gated by THREE_PROFILER)
│   ├── rendering/          # Rendering system (bgfx)
│   │   ├── bgfx/           # bgfx backend implementation (BgfxBackend/materials/lights/shadows/render state/shader cache)
│   │   ├── bgfxxr/         # XR extension (XR controllers/depth perception/manager)
│   │   ├── buffer/         # Vertex/index buffers (BufferAttribute/InstancedBuffer...)
│   │   ├── cameras/        # Cameras (Perspective/Orthographic/Stereo/Cube/Array/CameraView)
│   │   ├── common/         # Rendering common layer (Renderer/RenderList/Pipeline/Backend/BindGroup...)
│   │   ├── geometry/       # Geometry & curves (Box/Capsule/Cone/Cylinder/Sphere/Torus/Extrude/Path...)
│   │   ├── helpers/        # Helpers (AxesHelper/GridHelper/ArrowHelper/BoxHelper...)
│   │   ├── interfaces/     # Rendering interface contracts (IRenderer/ICamera/IRenderTarget...)
│   │   ├── lights/         # Lights (Ambient/Directional/Point/Spot/Hemisphere/RectArea/LightProbe)
│   │   ├── materials/      # Materials (Basic/Lambert/Phong/Standard/Physical/Toon/Matcap...)
│   │   ├── postprocessing/ # Post-processing (FXAA/SMAA/SSAO/SSR/GTAO/Bloom/UnrealBloom/Outline...)
│   │   ├── rendertarget/   # Render targets (RenderTarget/RenderTarget3D)
│   │   ├── shaders/        # Shaders (ShaderChunk/ShaderLib/ShaderCompiler/ShaderVariant)
│   │   │   ├── ShaderChunk/ # Shader code chunks
│   │   │   └── ShaderLib/   # Shader library
│   │   ├── textures/       # Textures (CanvasTexture/CubeTexture/CompressedTexture...)
│   │   └── types/          # bgfx type definitions
│   ├── resource/           # Asset loading & caching
│   │   ├── bgfx/           # bgfx low-level resource operations
│   │   ├── cache/          # Resource cache (Cache)
│   │   ├── loader/         # Loaders (glTF/OBJ/MTL/PLY/STL/DDS/KTX/PVR/EXR/HDR/TGA/Font...)
│   │   ├── pipeline/       # Asset pipeline (AssetBundle/AssetBundleBuilder pack & read, AssetManager async frame-spread loading, AssetCache ref-counted unloading)
│   │   └── serializer/     # Serialization (Serializer)
│   ├── scene/              # Scene management
│   │   ├── ecs/            # ECS framework (World/Entity/Component/System/Registry)
│   │   │   └── macros/     # ECS macros (Component/Entity/System macros)
│   │   ├── entity/         # Renderable entities (Mesh/Points/Line/Sprite/SkinnedMesh/InstancedMesh/LOD/BatchedMesh)
│   │   ├── interfaces/     # Scene interface contracts (IScene/IGroup/IMesh)
│   │   ├── objects/        # 3D object base classes (Object3D/Raycaster/Layers)
│   │   └── scenegraph/     # Scene graph (Scene/Group/Fog/FogExp2/ClippingGroup)
│   ├── script/             # Scripting system (LuaJIT)
│   │   ├── binding/        # Cangjie ↔ Lua bidirectional binding (LuaBinder)
│   │   ├── hotreload/      # Script hot-reloading (LuaHotReload)
│   │   └── vm/             # LuaJIT VM wrapper (LuaVM/LuaValue/LuaTable/LuaFunction/LuaError)
│   ├── utils/              # Utility library
│   │   ├── allocator/      # Object ID allocator (IdAllocator)
│   │   ├── constants/      # Constants
│   │   ├── encode/         # Encoding/decoding (Base64/MD5/SHA/Hash/Hex/UUID/UrlEncode)
│   │   ├── log/            # Logging (Logger, 5-level severity)
│   │   ├── memory/         # Memory utilities (pointer arrays/memory conversion)
│   │   └── pool/           # Object pool (ObjectPool/PoolManager)
│   └── window/             # Window & input engine (WindowEngine v2 + input providers)
│       └── ui/             # GUI subsystem (ImGui widgets/layout/menus/tabs/tables/popups/drag-drop/fonts/styles/draw lists)
└── test/                   # Test projects
    ├── general/            # General feature tests (math/data structures/ECS/network/asset pipeline/serialization/encoding...)
    ├── ohos/               # HarmonyOS test projects (audio/base/gui/pc/physics)
    └── windows/            # Windows test cases (boxshow/geometries/materials/helpers/post-processing/glTF/physics/gui...)
```

## Requirements

| Dependency | Version | Notes |
|------------|---------|-------|
| Cangjie Compiler | >= 1.1.0 | Cangjie programming language compiler (cjc) |
| cjpm | >= 1.1.0 | Cangjie package manager |
| bgfx4cj | — | bgfx rendering library Cangjie wrapper (git dependency) |
| openalsoft4cj | — | OpenAL audio library wrapper (git dependency) |
| jolt4cj | — | Jolt physics engine wrapper (git dependency) |
| luajit4cj | — | LuaJIT scripting engine wrapper (git dependency) |
| httpclient4cj | — | HTTP client wrapper (git dependency) |
| fastjson | — | JSON serialization (git dependency) |
| sdl4cj | — | SDL3 window/input wrapper (git dependency) |
| imgui4cj | — | ImGui immediate-mode UI wrapper (git dependency) |
| tracy4cj | — | Tracy real-time profiler wrapper (git dependency) |
| DevEco NDK / OHOS SDK | — | Required for HarmonyOS platform builds |

> Dependencies are automatically pulled via git dependencies defined in `cjpm.toml`; static library files required by the project should be placed in the `libs/` directory as needed.
>
> The source repositories for the underlying dependency libraries of three.cj are located at: [three.cj-cxx (github)](https://github.com/YQ-RZJ/three.cj-cxx) ([three.cj-cxx (gitcode)](https://atomgit.com/yq24w/three.cj-cxx))

## Build & Usage

### Option 1 (Recommended): Reuse the Prebuilt Binary Artifacts

The recommended path is to reuse the static artifacts published by the engine CI — no need
to build the engine yourself, collect dependency libraries, or resolve symbol conflicts:

1. Follow the [`test/bin-reuse`](./test/bin-reuse/README.md) project: download the static
   artifact package `three-<os>-<arch>-static.zip` matching your platform, and extract it
   into your project's `libs/` directory;
2. Following [`test/bin-reuse/cjpm.toml`](./test/bin-reuse/cjpm.toml), add the
   `[target.<triple>.bin-dependencies]` `path-option` (one entry per module directory) for
   your target platform, and declare `-L libs -l:three-deps.a` plus that platform's system
   library list in `link-option`;
3. Build and run:

```bash
cjpm build
cjpm run
```

Windows / Linux / macOS need no extra environment variables; OHOS / iOS / Android require
the matching SDK environment variables first (see the comments on each target in the
bin-reuse `cjpm.toml`). For caveats (cjc version match, macro plugin dynamic libraries,
platform/artifact correspondence, etc.), see
[`test/bin-reuse/README.md`](./test/bin-reuse/README.md).

### Option 2 (Advanced): Build the Engine from Source

Choose a source dependency when you need to modify the engine code:

```bash
# Build the engine in the three/ directory (outputs dynamic library)
cjpm build
```

> **Parallel build tip**: The engine has a large codebase. If you choose to build it yourself,
> it is recommended to enable parallel compilation with the `-j <N>` option to shorten the
> build time, e.g. `cjpm build -j 8`.

> **Link symbol note (cross-platform)**: cjpm links each Cangjie sub-package into a separate
> dynamic library; third-party Cangjie FFI packages are linked as static archives, so their
> mangled symbols must be kept from duplicate cross-library exports while the C APIs stay
> globally exported to converge C library global state (bgfx `g_ctx`, OpenAL context, etc.) to
> a singleton. The per-platform control files are shipped with the repository: Windows (MinGW)
> uses `libs/exclude.rsp` (an ld.lld response file); Linux/OHOS (ELF) uses
> `libs/symbols_elf.map` (`--version-script`, marking third-party Cangjie symbols and `_Z*` as
> local); macOS (ld64, two-level namespace) keeps the default configuration for now. After
> adding/removing/upgrading third-party dependencies (cjpm.toml dependencies changes or
> `cjpm update`) or rebuilding the C/C++ libraries under `libs/`, build once and then run
> `python scripts/gen_exclude_rsp.py` to regenerate both files at once
> (see [scripts/README.md](./scripts/README.md)).

### Advanced Build Configuration (effective for source builds)

The compile-time environment variables below apply to the **source-built** engine and
business code. With Option 1 (prebuilt artifacts), the engine-side levels were already
frozen into the artifacts at CI build time, while macro call sites in your own code still
follow these rules from your own build environment.

#### EXTEND_LIBS_PATH_<OS>_<ARCH>

**The key environment variable for source builds (Option 2)**: the `link-option` of each
target in the engine's `cjpm.toml` references it as `-L ${EXTEND_LIBS_PATH_<OS>_<ARCH>}`,
the **search path** for the native static libraries (bgfx/SDL3/OpenAL/Jolt/LuaJIT/OpenSSL/
tracy, etc.) and the symbol control files (`exclude.rsp` / `symbols_elf.map`). If it is
unset (or the path lacks the required `.a` files), the link stage fails with missing
libraries.

| Platform | Variables |
|------|------|
| Windows (MinGW) | `EXTEND_LIBS_PATH_WIN_X64` / `EXTEND_LIBS_PATH_WIN_ARM64` |
| Linux | `EXTEND_LIBS_PATH_LINUX_X64` / `EXTEND_LIBS_PATH_LINUX_ARM64` |
| macOS | `EXTEND_LIBS_PATH_MACOS_X64` / `EXTEND_LIBS_PATH_MACOS_ARM64` |
| OpenHarmony | `EXTEND_LIBS_PATH_OHOS_X64` / `EXTEND_LIBS_PATH_OHOS_ARM64` |
| iOS (device/simulator) | `EXTEND_LIBS_PATH_IOS_ARM64` / `EXTEND_LIBS_PATH_IOS_SIM_X64` / `EXTEND_LIBS_PATH_IOS_SIM_ARM64` |
| Android | `EXTEND_LIBS_PATH_ANDROID_X64` / `EXTEND_LIBS_PATH_ANDROID_ARM64` |

It normally points to the repository's `libs/` directory (where the native static
libraries and symbol control files live), for example:

```bash
# Windows (cmd, building the x86_64-w64-mingw32 target)
set EXTEND_LIBS_PATH_WIN_X64=D:\path\to\three\libs

# Windows (PowerShell)
$env:EXTEND_LIBS_PATH_WIN_X64 = "D:\path\to\three\libs"

# Linux / macOS
export EXTEND_LIBS_PATH_LINUX_X64=/path/to/three/libs
```

> Note: this variable is only needed when building the engine **from source** (Option 2,
> or building sub-projects that reference the engine source). With Option 1 (prebuilt
> binary artifacts) all dependencies are merged into `three-deps.a` and no such variable
> is required.

#### THREE_LOG_LEVEL

Engine logging goes through the `three.utils.log` macro package
(`@LogTrace/@LogDebug/@LogInfo/@LogWarn/@LogError/@LogWarnOnce`) and code is generated
**at compile time** based on the log level: below the configured level, call sites (including
argument evaluation and string interpolation) emit no instructions at all, so release builds
carry zero logging overhead.

The level is driven by the `THREE_LOG_LEVEL` environment variable of the compile process —
the macro package reads it while cjc expands the macros (i.e. while your code is being
compiled) and freezes the level. Default is `off` (unset or unrecognized values are treated
as `off`; an unrecognized value prints a hint at compile time):

```bash
# Windows (cmd)
set THREE_LOG_LEVEL=info

# Windows (PowerShell)
$env:THREE_LOG_LEVEL = "info"

# Linux / macOS
export THREE_LOG_LEVEL=info
```

Available levels (more verbose toward the right): `off < error < warn < info < debug < trace`.

**Overriding in sub-projects**: a sub-project can override the default level by setting the
same environment variable when building, e.g. enabling debug logs during development:

```bash
THREE_LOG_LEVEL=debug cjpm build
```

> Note: the level is read at macro expansion time (compile time) and baked into the binary;
> it is independent of the runtime environment — setting `THREE_LOG_LEVEL` when running the
> binary has no effect. After changing the level, run `cjpm clean` for a full rebuild so all
> call sites are re-expanded under the new level.

#### THREE_PROFILER

The profiling macro package (`three.profiler.macros`:
`@Zone/@FrameMark/@FrameStart/@FrameEnd/@Plot/@PlotI64/@Message/@Fiber/@MemAlloc/@MemFree/@GpuZone/@LockTrack`)
generates profiling code **at compile time** based on links: call sites whose link does not
match emit no instructions at all, so release builds carry zero profiling overhead.

A link is decided by the `THREE_PROFILER` environment variable of the compile process — the
macro package reads it while cjc expands the macros and freezes it. Default is `off` (unset
or unrecognized values are treated as `off`):

```bash
# Windows (cmd)
set THREE_PROFILER=three.render

# Windows (PowerShell)
$env:THREE_PROFILER = "three.render"

# Linux / macOS
export THREE_PROFILER=three.render
```

Value rules (**segment-level prefix matching**, split on `.`; the macro attribute is the
link, e.g. `@Zone[three.render.shadow]`):

| Value | Effect |
|-------|--------|
| `off` / unset | Everything zero-intrusion (default) |
| `all` / `on` / `full` | Everything instrumented |
| `three` | All links starting with `three.` are instrumented |
| `three.render` | Links prefixed with the `three.render` segment (`three.render.shadow` matches, `three.renderer` does not) |
| `three.render,three.test` | Comma-separated multi-link; any match instruments |

The runtime facade (direct API calls in the `three.profiler` package such as `ProfZone`/`ProfFrame`/
`ProfPlot`) is unaffected by this environment variable — calling it always instruments. Profiling
data is viewed in the Tracy GUI (provided by the tracy4cj repository); sampling and GUI
connection are controlled by `three.profiler.Sampling` / `ProfilerState`.

For headless environments (CI, no GUI available), `scripts/tracy_receiver.py` acts as a
Tracy GUI/Worker: it connects to the profiled process, writes the raw/structured artifacts to
disk and emits hotspot statistics (call count, duration, P50/P95/P99). See
[`doc/materials/en/profiler-usage.md`](./doc/materials/en/profiler-usage.md) section VII.

> Note: like `THREE_LOG_LEVEL`, links are read at macro expansion time (compile time) and
> baked into the binary; they are independent of the runtime environment. After changing,
> run `cjpm clean` for a full rebuild.

### Run Test Cases

```bash
# Windows rendering test (e.g., boxshow)
cd test/windows/boxshow
cjpm build
cjpm run
```

More examples can be found in the `test/windows/`, `test/general/`, and `test/ohos/` directories.

### Use in Your Project

**Option 1 (recommended): binary artifact reuse** — download the prebuilt artifacts into
`libs/`, then declare the binary modules and link options following
[`test/bin-reuse/cjpm.toml`](./test/bin-reuse/cjpm.toml). Example for the Windows (MinGW)
target:

```toml
[target.x86_64-w64-mingw32]
  link-option = "-L libs -l:three-deps.a -lhid -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lversion -luuid -lsetupapi -lshell32 -ldinput8 -ld3d11 -ldxgi -ld3dcompiler -lavrt -ldsound -lws2_32 -lcrypt32 -ladvapi32 -lz -ldbghelp -lsecur32"
  [target.x86_64-w64-mingw32.bin-dependencies]
    path-option = [ "./libs/bgfx4cj", "./libs/fastjson", "./libs/httpclient4cj", "./libs/imgui4cj", "./libs/jolt4cj", "./libs/luajit4cj", "./libs/openalsoft4cj", "./libs/sdl4cj", "./libs/three", "./libs/tracy4cj" ]
```

Import in your Cangjie code (identical to the source-dependency approach):

```cangjie
import three.rendering.*            // Rendering (BgfxRenderer/BgfxRenderTarget)
import three.rendering.geometry.*   // Geometry
import three.rendering.materials.*  // Materials
import three.rendering.cameras.*    // Cameras
import three.rendering.lights.*     // Lights
import three.scene.scenegraph.*     // Scene graph (Scene/Group/Fog)
import three.scene.entity.*         // Entities (Mesh/Points/Line/Sprite...)
import three.core.math.*            // Math utilities
import three.window.*               // Window & input (WindowEngine)
import three.resource.*             // Asset loading
import three.resource.pipeline.*    // Asset pipeline (AssetBundle/AssetManager/AssetCache)
import three.network.protocol.*     // Protocol codec (PacketWriter/PacketReader)
import three.network.transport.*    // Reliable transport (Connection/ReliableChannel)
import three.network.sync.*         // Sync models (LockstepSession/SnapshotBuffer)
import three.physics.*              // Physics
import three.audio.*                // Audio
import three.script.*               // Scripting
import three.window.ui.*           // Immediate-mode UI (ImGui widgets)
```

**Option 2 (Advanced): source dependency** — when you need to modify the engine source,
pull the engine repository in as a path dependency:

```toml
[dependencies]
  [dependencies.three]
    path = "path/to/three"
    output-type = "static"
```

> **Note**: with the source-dependency approach, the `cjpm.toml` of this project references
> the `EXTEND_LIBS_PATH_*` environment variable in `link-option`. You need to set it to the
> actual location of the dependency files before use. For example:
> `cmd: set EXTEND_LIBS_PATH_WIN_X64=/path/to/three/libs`

## Threading Model

All engine subsystems follow a unified "dedicated system thread + serialized calls" threading model, avoiding platform API constraints caused by Cangjie user-mode threads (M:N) migrating between system threads:

| Subsystem | Threading Model |
|-----------|-----------------|
| `BgfxRenderer` | All bgfx API calls are serialized to a dedicated rendering system thread (`SThread`) via `_execBgfx` |
| `AudioContext` | All OpenAL calls are serialized to an audio system thread |
| `PhysicsWorld` | Physics backend calls are serialized to a physics thread via `_execPhysics`; the rendering thread only reads back transform data for synchronization |
| `WindowEngine` | SDL main-thread APIs are pinned to a single system thread (event pump); each window has its own user-mode pump thread (reads fixed event snapshots + lifecycle callbacks); the main loop pumps `AssetManager` every frame, dispatching async asset-load completions across frames within a time budget |
| `Connection` / `ReliableChannel` | Each spawns a receive thread after `connect()`/`bind()` (blocking frame reads / `receiveFrom`) handling heartbeat replies, ack receipts and the out-of-order cache; `onMessage` and connection-state callbacks are dispatched on the main-loop `update()`, and `send`/`update` are concurrency-safe with the receive thread |
| `ShaderCompiler` | Runtime shader compilation spawns dedicated system threads on demand (`SThread`, custom stack default 8MB); a single worker compiles serially (glslang is not thread-safe), started/stopped via `start()`/`restart()` |

## API Documentation

[API Documentation](./doc/api/en/)

Project source code follows a unified [documentation comment standard](./doc/dev%20manual/en/comment-writing-standard.md) (based on cjdoc, bilingual Chinese/English). API documentation can be extracted directly from source code using the [cjdoc](https://gitcode.com/yq24w/cjdoc) tool.

## Contact

![QQ Group](https://24dim.com/other/qq%20group.png)
<a href="https://24dim.com/other/qq%20group.png"><img alt="QQ Group" src="https://24dim.com/other/qq%20group.png" style="display: inline-block;" /></a>

> Note: Since external links are used, some platforms may not support inline preview. Please download the file and view it locally, or click the broken image icon to try loading it directly.

## License

This project is open-sourced under the [Apache 2.0](./LICENSE) license.

### Dependency Licenses

> **Note**: The native C/C++ libraries this project depends on follow their own original open-source licenses. Please comply with the respective license obligations when using them. Dependency list and licenses:

| Native C/C++ Project | Git Repository | License |
|----------------------|----------------|---------|
| bgfx (rendering engine, includes bimg image library and bx base library) | https://github.com/bkaradzic/bgfx | BSD 2-Clause |
| OpenAL Soft (audio) | https://github.com/kcat/openal-soft | LGPL-2.1-or-later |
| Jolt Physics (physics) | https://github.com/jrouwe/JoltPhysics | MIT |
| LuaJIT (scripting) | https://github.com/LuaJIT/LuaJIT | MIT |
| SDL3 (window/input) | https://github.com/libsdl-org/SDL | zlib |
| OpenSSL | https://github.com/openssl/openssl | Apache-2.0 |
| imgui | https://github.com/ocornut/imgui | MIT |
| Tracy Profiler (profiling) | https://github.com/wolfpld/tracy | BSD 3-Clause |

> The above native libraries are integrated through their respective Cangjie wrapper projects (`bgfx4cj` / `openalsoft4cj` / `jolt4cj` / `luajit4cj` / `sdl4cj` / `httpclient4cj`/`imgui4cj`/`tracy4cj`; the wrapper layer is MIT-licensed). Additionally, bgfx's toolchain (shaderc/geometryc, etc.) and third-party libraries (glslang, miniz, tinyexr, etc.) each have their own independent licenses. Please refer to the LICENSE files in the respective project source directories before use.

## Contributing

Pull requests and issues are welcome! Contributions of all kinds are greatly appreciated!
