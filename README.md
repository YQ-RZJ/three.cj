<div align="center">
<img alt="" src="./doc/asstes/three.cj-logo.svg" style="display: inline-block;width:128px;height:128px"/>
<h1>three.cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/version-0.0.341-red" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.1.0 STS-yellow" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/domain-Computer_Graphics-8A2BE2" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/platform-Cross--Platform-lightgrey" style="display: inline-block;" />
</p>

## Introduction

**three.cj** is a 3D engine runtime implemented in the [Cangjie programming language](https://cangjie-lang.cn/). The project adopts a "pluggable backend" architecture and provides a full suite of 3D rendering capabilities including Scene Graph, Entities (Mesh/Points/Line/Sprite, etc.), Materials, Lights, Cameras, Geometry, Shaders, and Post-processing. It also integrates subsystems for Audio (OpenAL), Physics (Jolt), Scripting (LuaJIT), Networking (OpenSSL), and Window/Input (SDL3), covering common needs for 3D application and game development.

> **Note** three.cj is the first fully-featured game engine runtime for the Cangjie language. It offers strong extensibility and customization capabilities, but building complex games directly on top of it involves significant effort. The author recommends wrapping it into a higher-level framework or editor first — or leveraging AI engineering capabilities — before undertaking complex game projects.

### Tutorials & Examples

This project is actively maintained. Follow [Bilibili UID:3546853029185667](https://space.bilibili.com/3546853029185667) for video tutorials and latest updates!

> **Note** Test and example code can be found here: [Link](./doc/materials/en/test-windows-projects.md)

## Features

### 🎯 Core Features

- **Pluggable Rendering Backend** — The rendering layer abstracts a `Backend` interface, with `BgfxBackend` implemented via bgfx4cj, supporting hardware-accelerated rendering on Windows / HarmonyOS Next / macOS / Linux / Android / iOS
- **Complete Scene System** — Scene Graph, Object3D, Cameras, Lights, Materials, Geometry, Render Targets, Helpers, and more
- **Pure Cangjie Math Library** — Vectors (Vector2/3/4), Matrices (Matrix2/3/4), Quaternions, Euler Angles, Colors, Bounding Boxes/Spheres/Planes/Rays, etc.
- **Rich Geometry & Curves** — Box/Capsule/Cone/Cylinder/Sphere/Torus/Extrude/Polyhedron and other parametric geometries, plus Bezier/Spline curves and paths
- **Multiple Material Types** — MeshBasic/Lambert/Phong/Standard/Physical/Toon/Matcap/Normal/Depth materials with custom ShaderMaterial support
- **Complete Post-Processing Pipeline** — FXAA/SMAA/SSAO/SSR/GTAO/Bloom/UnrealBloom/Outline/Glitch/Halftone and 30+ post-processing passes
- **Asset Loading System** — glTF/OBJ/MTL/PLY/STL models, DDS/KTX/PVR/EXR/HDR/TGA textures, Font/Animation/Audio loaders with caching and serialization
- **Animation System** — AnimationClip / AnimationMixer / AnimationAction / KeyframeTrack (Boolean/Color/Number/Quaternion/String/Vector)
- **Physics Engine Integration** — Pluggable physics backend based on Jolt, running on an independent physics thread, supporting rigid bodies, characters, constraints, and Object3D binding
- **Audio Subsystem** — Based on OpenAL: audio context / listener / static · positional · streaming sources / recording / EFX effects & filters
- **Scripting System** — Based on LuaJIT, with bidirectional Cangjie-Lua binding and script hot-reloading
- **Window & Input Engine** — Cross-platform window engine v2 based on SDL3 (lifecycle callbacks + per-window independent event pump), with keyboard/mouse/touch/gamepad input providers
- **ECS Framework** — Built-in Entity-Component-System with macro-assisted component/entity/system definitions and runtime registration
- **Frame Dispatcher** — Forced queue + priority queue, trimmed by time budget to prevent single-frame timeout
- **Cross-Platform** — Supports OpenHarmony, Windows, Linux, macOS, Android/iOS, and more

### 📦 Sub-Package Structure

| Sub-Package | Description | Directory |
|-------------|-------------|-----------|
| `three.animation` | Animation system (clips, blending, action scheduling, keyframe tracks) | `src/animation/` |
| `three.audio` | Audio subsystem (OpenAL: context/listener/sources/recording/EFX) | `src/audio/` |
| `three.core` | Core infrastructure (math, data structures, events, frame dispatch, threads, time) | `src/core/` |
| `three.network` | Networking module (HTTP / Socket) | `src/network/` |
| `three.physics` | Physics system (Jolt: world/rigid bodies/characters/constraints/binding) | `src/physics/` |
| `three.rendering` | Rendering system (bgfx backend, cameras, geometry, materials, lights, post-processing, shaders) | `src/rendering/` |
| `three.resource` | Asset loading & caching (model/texture/animation loaders, serialization) | `src/resource/` |
| `three.scene` | Scene management (scene graph, entities, ECS, Object3D, raycasting) | `src/scene/` |
| `three.script` | Scripting system (LuaJIT VM, bidirectional binding, hot-reloading) | `src/script/` |
| `three.utils` | Utility library (logging, encoding, object pool, memory, allocator) | `src/utils/` |
| `three.window` | Window & input engine (SDL3 window, input providers) | `src/window/` |

## Project Structure

> Note: The directory tree only shows directory-level structure; individual files are not listed due to their volume.

```
three/
├── doc/                    # Project documentation
│   └── dev manual/         # Development manual (comment standards, etc.)
├── libs/                   # Native library directory (static libs required for Windows testing)
├── script/                 # Helper scripts
│   ├── check_so_deps.py    # Check .so dependencies
│   └── generate_structure.py # Generate directory listing/tree
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
│   │   └── socket/         # Socket client/server/UDP
│   ├── physics/            # Physics system (Jolt)
│   │   ├── backend/        # Physics backend adapter (JoltBackend)
│   │   ├── binding/        # Object3D ↔ RigidBody binding (PhysicsBinding)
│   │   ├── body/           # Rigid body (RigidBody)
│   │   ├── character/      # Character controller (Character)
│   │   ├── constraint/     # Constraints/joints (Constraint)
│   │   ├── interfaces/     # Pluggable backend abstraction (IPhysicsBackend)
│   │   └── world/          # Physics world facade (PhysicsWorld, independent physics thread)
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
│   ├── window/             # Window & input engine (WindowEngine v2 + input providers)
│   └── main.cj             # Engine program entry point
├── test/                   # Test projects
│   ├── general/            # General feature tests (math/data structures/ECS/network/serialization/encoding...)
│   ├── ohos/               # HarmonyOS test projects (audio/base/pc/physics)
│   └── windows/            # Windows rendering test cases (boxshow/geometries/materials/helpers/post-processing/glTF...)
├── cjpm.toml               # Project configuration
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
| DevEco NDK / OHOS SDK | — | Required for HarmonyOS platform builds |

> Dependencies are automatically pulled via git dependencies defined in `cjpm.toml`; static library files required by the project should be placed in the `libs/` directory as needed.

## Build & Usage

### Build the Engine Library

```bash
# Build the engine in the three/ directory (outputs dynamic library)
cjpm build
```

### Run Test Cases

```bash
# Windows rendering test (e.g., boxshow)
cd test/windows/boxshow
cjpm build
cjpm run
```

More examples can be found in the `test/windows/`, `test/general/`, and `test/ohos/` directories.

### Use in Your Project

> **Note**: The `cjpm.toml` of this project references the `EXTEDN_LIBS_PATH` environment variable in `link-option`. You need to set it to the actual location of the dependency files before use. For example: `cmd: set EXTEDN_LIBS_PATH=/path/to/three/libs`

Add the dependency in your `cjpm.toml`:

```toml
[dependencies]
  [dependencies.three]
    path = "path/to/three"
    output-type = "static"
```

Import in your Cangjie code:

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
import three.physics.*              // Physics
import three.audio.*                // Audio
import three.script.*               // Scripting
```

## Threading Model

All engine subsystems follow a unified "dedicated system thread + serialized calls" threading model, avoiding platform API constraints caused by Cangjie user-mode threads (M:N) migrating between system threads:

| Subsystem | Threading Model |
|-----------|-----------------|
| `BgfxRenderer` | All bgfx API calls are serialized to a dedicated rendering system thread (`SThread`) via `_execBgfx` |
| `AudioContext` | All OpenAL calls are serialized to an audio system thread |
| `PhysicsWorld` | Physics backend calls are serialized to a physics thread via `_execPhysics`; the rendering thread only reads back transform data for synchronization |
| `WindowEngine` | SDL main-thread APIs are pinned to a single system thread (event pump); each window has its own user-mode pump thread (reads fixed event snapshots + lifecycle callbacks) |
| `ShaderCompiler` | Runtime shader compilation spawns dedicated system threads on demand (`SThread`, custom stack default 8MB); a single worker compiles serially (glslang is not thread-safe), started/stopped via `start()`/`restart()` |

## API Documentation

[API Documentation](./doc/api/en/)

Project source code follows a unified [documentation comment standard](./doc/dev%20manual/en/comment-writing-standard.md) (based on cjdoc, bilingual Chinese/English). API documentation can be extracted directly from source code using the [cjdoc](https://gitcode.com/yq24w/cjdoc) tool.

## Contact

![QQ Group](https://24dim.com/other/qq%20group.png)
<a href="https://24dim.com/other/qq%20group.png"><img alt="QQ Group" src="https://24dim.com/other/qq%20group.png" style="display: inline-block;" /></a>

> Note: Since external links are used, some platforms may not support inline preview. Please download the file and view it locally, or click the broken image icon to try loading it directly.

## License

This project is open-sourced under the [MIT](./LICENSE) license.

### Dependency Licenses

> **Note**: The native C/C++ libraries this project depends on follow their own original open-source licenses. Please comply with the respective license obligations when using them. Dependency list and licenses:

| Native C/C++ Project | Git Repository | License |
|----------------------|----------------|---------|
| bgfx (rendering engine, includes bimg image library and bx base library) | https://github.com/bkaradzic/bgfx | BSD 2-Clause |
| OpenAL Soft (audio) | https://github.com/kcat/openal-soft | LGPL-2.1-or-later |
| Jolt Physics (physics) | https://github.com/jrouwe/JoltPhysics | MIT |
| LuaJIT (scripting) | https://github.com/LuaJIT/LuaJIT | MIT |
| SDL3 (window/input) | https://github.com/libsdl-org/SDL | zlib |
| OpenSSL (HTTP TLS, bridged via httpclient4cj) | https://github.com/openssl/openssl | Apache-2.0 |

> The above native libraries are integrated through their respective Cangjie wrapper projects (`bgfx4cj` / `openalsoft4cj` / `jolt4cj` / `luajit4cj` / `sdl4cj` / `httpclient4cj`; the wrapper layer is MIT-licensed). Additionally, bgfx's toolchain (shaderc/geometryc, etc.) and third-party libraries (glslang, miniz, tinyexr, etc.) each have their own independent licenses. Please refer to the LICENSE files in the respective project source directories before use.

## Contributing

Pull requests and issues are welcome! Contributions of all kinds are greatly appreciated!
