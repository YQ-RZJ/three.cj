<div align="center">
<img alt="" src="./doc/asstes/three.cj-logo.svg" style="display: inline-block;width:128px;height:128px"/>
<h1>three.cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/version-0.0.375-red" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.1.0 STS-yellow" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/domain-Computer_Graphics-8A2BE2" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/platform-跨平台-lightgrey" style="display: inline-block;" />
</p>

## 介绍

**three.cj** 是一个使用[仓颉编程语言](https://cangjie-lang.cn/)实现的 3D 引擎运行时，提供场景图（Scene Graph）、实体（Mesh/Points/Line/Sprite 等）、材质（Material）、灯光（Light）、相机（Camera）、几何体（Geometry）、着色器（Shader）、后期处理（Post-processing）等一整套三维渲染能力，同时集成了音频（OpenAL）、物理（Jolt）、脚本（LuaJIT）、网络（OpenSSL）、窗口与输入（SDL3）、用户交互界面（IMGUI）等子系统，覆盖 3D 应用与游戏开发的常见需求。

**'注意** three.cj 是仓颉语言首个功能完备的游戏引擎运行时，其具备极强的扩展和定制化改造能力，但直接基于其实现复杂游戏的开发工作量较大，作者建议基于引擎运行时进行高级封装、编辑器化后，或是借助AI工程的能力，再进行复杂游戏项目的开发。

### 教程与案例

本项目长期维护，关注 [Bilibili UID:3546853029185667](https://space.bilibili.com/3546853029185667) 观看视频教程与最新动态！

**'注意** 测试及案例代码可见：[链接](./doc/materials/zh-cn/测试案例项目.md)

## 项目特点

### 🎯 核心特性

- **跨平台渲染后端** — 支持 Windows / HarmonyOS Next / MacOS / Linux / Android / iOS 等平台的硬件加速渲染
- **完整的场景体系** — 场景图、Object3D、相机、灯光、材质、几何体、渲染目标、辅助对象等一应俱全
- **纯仓颉数学库** — 向量（Vector2/3/4）、矩阵（Matrix2/3/4）、四元数（Quaternion）、欧拉角、颜色、包围盒/球/平面/射线等
- **丰富几何体与曲线** — Box/Capsule/Cone/Cylinder/Sphere/Torus/Extrude/Polyhedron 等参数化几何体，以及贝塞尔/样条等曲线与路径
- **多材质体系** — MeshBasic/Lambert/Phong/Standard/Physical/Toon/Matcap/Normal/Depth 等材质，支持自定义 ShaderMaterial
- **完整后处理管线** — FXAA/SMAA/SSAO/SSR/GTAO/Bloom/UnrealBloom/Outline/Glitch/Halftone 等 30+ 后期处理 Pass
- **资源加载体系** — glTF/OBJ/MTL/PLY/STL 模型，DDS/KTX/PVR/EXR/HDR/TGA 纹理，Font/Animation/Audio 等加载器，含缓存与序列化
- **动画系统** — AnimationClip / AnimationMixer / AnimationAction / KeyframeTrack（布尔/颜色/数值/四元数/字符串/向量）
- **物理引擎集成** — 基于 Jolt 的可插拔物理后端，物理世界独立线程运行，支持刚体/角色/约束/Object3D 绑定，以及高度场地形、布料软体、载具、布娃娃等扩展物理对象与调试渲染器
- **音频子系统** — 基于 OpenAL，音频上下文 / 监听器 / 静态·位置·流式音源 / 录音 / EFX 效果与滤波器
- **脚本系统** — 基于 LuaJIT，仓颉与 Lua 双向绑定 + 脚本热更新
- **窗口与输入引擎** — 基于 SDL3 的跨平台窗口引擎 v2（生命周期回调 + 每窗口独立事件泵），键盘/鼠标/触摸/手柄输入提供者
- **GUI 子系统** — 基于 ImGui（imgui4cj）的即时模式 UI（`three.window.ui`）：`WindowEngine.useGui()` 一键启用，SDL3 事件桥接 + bgfx 渲染后端自动接入（均路由到对应系统线程），提供 30+ 控件（窗口/按钮/输入框/滑条/树/列表框/颜色选择等）与布局/菜单/标签页/表格/弹窗/拖放/字体/样式主题/自定义绘制列表能力
- **多 DPI / 高像素密度支持** — 基于 SDL3 的 `SDL_WINDOW_HIGH_PIXEL_DENSITY`，`WindowEngine` 提供 `getPixelRatio` / `getDrawableSize`，`Renderer` 区分逻辑/物理尺寸，后处理 RT 自动按 DPR 缩放
- **ECS 框架** — 内置 Entity-Component-System，支持宏辅助组件/实体/系统定义与运行时注册
- **帧调度器** — 强制队列 + 优先级队列，按时间预算裁剪，避免单帧超时
- **跨平台** — 支持 OpenHarmony、Windows、Linux、macOS 与 Android/iOS 等平台

### 📦 子包结构

| 子包 | 说明 | 目录 |
|------|------|------|
| `three.animation` | 动画系统（剪辑、混合、动作调度、关键帧轨道） | `src/animation/` |
| `three.audio` | 音频子系统（OpenAL：上下文/监听器/音源/录音/EFX） | `src/audio/` |
| `three.core` | 核心基础设施（数学、数据结构、事件、帧调度、线程、时间） | `src/core/` |
| `three.network` | 网络模块（HTTP / Socket） | `src/network/` |
| `three.physics` | 物理系统（Jolt：世界/刚体/角色/约束/绑定/高度场/软体/载具/布娃娃/调试渲染） | `src/physics/` |
| `three.rendering` | 渲染系统（bgfx 后端、相机、几何体、材质、灯光、后处理、着色器） | `src/rendering/` |
| `three.resource` | 资源加载与缓存（模型/纹理/动画加载器、序列化） | `src/resource/` |
| `three.scene` | 场景管理（场景图、实体、ECS、Object3D、射线） | `src/scene/` |
| `three.script` | 脚本系统（LuaJIT VM、双向绑定、热更新） | `src/script/` |
| `three.utils` | 工具库（日志、编解码、对象池、内存、分配器） | `src/utils/` |
| `three.window` | 窗口与输入引擎（SDL3 窗口、输入提供者） | `src/window/` |
| `three.window.ui` | GUI 子系统（ImGui 控件/窗口/布局/菜单/标签页/表格/弹窗/拖放/字体/样式/绘制列表/视口/存储） | `src/window/ui/` |

## 项目结构

> 说明：目录树仅展示到目录层级，具体文件较多不再展开。

```
three/
├── doc/                    # 项目文档
│   ├── api/                # API 文档
│   ├── asstes/             # 文档资源
│   ├── dev manual/         # 开发手册
│   └── materials/          # 项目材料（测试案例项目说明等）
├── libs/                   # 原生库目录（各平台测试链接所需静态库，含 exclude.rsp 与 symbols_elf.map）
├── scripts/                # 辅助脚本（详见 scripts/README_zh.md）
│   ├── gen_exclude_rsp.py  # 生成跨平台链接符号控制文件 exclude.rsp / symbols_elf.map（依赖增减/C 库重编译后刷新）
│   ├── check_so_deps.py    # 递归检查 .so 依赖链（OHOS/Linux 排障）
│   └── generate_structure.py # 生成目录清单/树状层级
├── src/                    # 仓颉引擎源码（本 README 主体）
│   ├── animation/          # 动画系统
│   │   ├── blend/          # 动画混合与动作调度（AnimationMixer/Action/KeyframeTrack/PropertyBinding）
│   │   ├── clip/           # 动画剪辑（AnimationClip/AnimationUtils）
│   │   ├── interfaces/     # 跨包解耦接口
│   │   └── tracks/         # 关键帧轨道（Boolean/Color/Number/Quaternion/String/Vector）
│   ├── audio/              # 音频子系统（OpenAL）
│   │   ├── capture/        # 录音（AudioRecorder）
│   │   ├── device/         # 音频上下文（AudioContext）
│   │   ├── interfaces/     # 音频接口契约
│   │   ├── listener/       # 音频监听器（AudioListener）
│   │   ├── mixer/          # EFX 效果与滤波器（AudioEffect/AudioFilter/AudioEffectSlot）
│   │   └── source/         # 音频源（Audio/PositionalAudio/StreamingAudio/AudioBuffer）
│   ├── core/               # 核心基础设施
│   │   ├── dispatch/       # 帧调度（FrameDispatch/FrameTask）
│   │   ├── dsa/            # 数据结构（BinaryHeap/BinaryPatriciaTrie/BitArray/Queue/RingBuffer/Stack...）
│   │   ├── event/          # 事件系统（EventDispatcher/EventFactory/EventManager）
│   │   ├── interfaces/     # 基础设施接口契约
│   │   ├── math/           # 数学库（向量/矩阵/四元数/颜色/插值/包围盒/射线...）
│   │   │   └── interpolants/ # 插值器（线性/贝塞尔/离散/三次/四元数）
│   │   ├── system/         # 系统信息（System/SystemInfo）
│   │   ├── thread/         # 线程与同步（Thread/SThread/Sync/RecursiveMutex）
│   │   └── time/           # 时间（Clock/Timer）
│   ├── network/            # 网络模块
│   │   ├── http/           # HTTP 客户端（基于 httpclient4cj）
│   │   └── socket/         # Socket 客户端/服务器/UDP
│   ├── physics/            # 物理系统（Jolt）
│   │   ├── backend/        # 物理后端适配（JoltBackend）
│   │   ├── binding/        # Object3D ↔ 刚体绑定（PhysicsBinding）
│   │   ├── body/           # 刚体（RigidBody）
│   │   ├── character/      # 角色控制器（Character）
│   │   ├── constraint/     # 约束/关节（Constraint）
│   │   ├── debug/          # 物理调试渲染（DebugRenderer：线段/三角形缓存桥接）
│   │   ├── heightfield/    # 高度场地形（HeightField）
│   │   ├── interfaces/     # 可插拔后端抽象（IPhysicsBackend）
│   │   ├── ragdoll/        # 布娃娃（Ragdoll）
│   │   ├── softbody/       # 软体/布料（SoftBody）
│   │   ├── vehicle/        # 载具（Vehicle：车轮/悬挂/引擎/差速器）
│   │   └── world/          # 物理世界门面（PhysicsWorld，独立物理线程）
│   ├── rendering/          # 渲染系统（bgfx）
│   │   ├── bgfx/           # bgfx 后端实现（BgfxBackend/材质/灯光/阴影/渲染状态/着色器缓存）
│   │   ├── bgfxxr/         # XR 扩展（XR 控制器/深度感知/管理器）
│   │   ├── buffer/         # 顶点/索引缓冲（BufferAttribute/InstancedBuffer...）
│   │   ├── cameras/        # 相机（Perspective/Orthographic/Stereo/Cube/Array/CameraView）
│   │   ├── common/         # 渲染公共层（Renderer/RenderList/Pipeline/Backend/BindGroup...）
│   │   ├── geometry/       # 几何体与曲线（Box/Capsule/Cone/Cylinder/Sphere/Torus/Extrude/Path...）
│   │   ├── helpers/        # 辅助对象（AxesHelper/GridHelper/ArrowHelper/BoxHelper...）
│   │   ├── interfaces/     # 渲染接口契约（IRenderer/ICamera/IRenderTarget...）
│   │   ├── lights/         # 灯光（Ambient/Directional/Point/Spot/Hemisphere/RectArea/LightProbe）
│   │   ├── materials/      # 材质（Basic/Lambert/Phong/Standard/Physical/Toon/Matcap...）
│   │   ├── postprocessing/ # 后期处理（FXAA/SMAA/SSAO/SSR/GTAO/Bloom/UnrealBloom/Outline...）
│   │   ├── rendertarget/   # 渲染目标（RenderTarget/RenderTarget3D）
│   │   ├── shaders/        # 着色器（ShaderChunk/ShaderLib/ShaderCompiler/ShaderVariant）
│   │   │   ├── ShaderChunk/ # 着色器代码块
│   │   │   └── ShaderLib/   # 着色器库
│   │   ├── textures/       # 纹理（CanvasTexture/CubeTexture/CompressedTexture...）
│   │   └── types/          # bgfx 类型定义
│   ├── resource/           # 资源加载与缓存
│   │   ├── bgfx/           # bgfx 底层资源操作
│   │   ├── cache/          # 资源缓存（Cache）
│   │   ├── loader/         # 加载器（glTF/OBJ/MTL/PLY/STL/DDS/KTX/PVR/EXR/HDR/TGA/Font...）
│   │   └── serializer/     # 序列化（Serializer）
│   ├── scene/              # 场景管理
│   │   ├── ecs/            # ECS 框架（World/Entity/Component/System/Registry）
│   │   │   └── macros/     # ECS 宏（Component/Entity/System 宏）
│   │   ├── entity/         # 可渲染实体（Mesh/Points/Line/Sprite/SkinnedMesh/InstancedMesh/LOD/BatchedMesh）
│   │   ├── interfaces/     # 场景接口契约（IScene/IGroup/IMesh）
│   │   ├── objects/        # 3D 对象基类（Object3D/Raycaster/Layers）
│   │   └── scenegraph/     # 场景图（Scene/Group/Fog/FogExp2/ClippingGroup）
│   ├── script/             # 脚本系统（LuaJIT）
│   │   ├── binding/        # 仓颉 ↔ Lua 双向绑定（LuaBinder）
│   │   ├── hotreload/      # 脚本热更新（LuaHotReload）
│   │   └── vm/             # LuaJIT VM 封装（LuaVM/LuaValue/LuaTable/LuaFunction/LuaError）
│   ├── utils/              # 工具库
│   │   ├── allocator/      # 对象 ID 分配器（IdAllocator）
│   │   ├── constants/      # 常量
│   │   ├── encode/         # 编解码（Base64/MD5/SHA/Hash/Hex/UUID/UrlEncode）
│   │   ├── log/            # 日志（Logger，五级分级）
│   │   ├── memory/         # 内存工具（指针数组/内存转换）
│   │   └── pool/           # 对象池（ObjectPool/PoolManager）
│   ├── window/             # 窗口与输入引擎（WindowEngine v2 + 输入提供者）
│   │   └── ui/             # 即时模式 UI（ImGui 控件/布局/菜单/标签页/表格/弹窗/拖放/字体/样式/绘制）
│   └── main.cj             # 引擎程序入口
├── test/                   # 测试项目
│   ├── general/            # 通用功能测试（数学/数据结构/ECS/网络/序列化/编码...）
│   ├── ohos/               # HarmonyOS 测试工程（audio/base/gui/pc/physics）
│   └── windows/            # Windows 测试案例（boxshow/geometries/materials/helpers/后期处理/glTF/physics/gui...）
├── cjpm.toml               # 项目配置
```

## 环境要求

| 依赖 | 版本 | 说明 |
|------|------|------|
| 仓颉编译器 | >= 1.1.0 | 仓颉编程语言编译器（cjc） |
| cjpm | >= 1.1.0 | 仓颉包管理器 |
| bgfx4cj | — | bgfx 渲染库仓颉封装（git 依赖） |
| openalsoft4cj | — | OpenAL 音频库封装（git 依赖） |
| jolt4cj | — | Jolt 物理引擎封装（git 依赖） |
| luajit4cj | — | LuaJIT 脚本引擎封装（git 依赖） |
| httpclient4cj | — | HTTP 客户端封装（git 依赖） |
| fastjson | — | JSON 序列化（git 依赖） |
| sdl4cj | — | SDL3 窗口/输入封装（git 依赖） |
| imgui4cj | — | ImGui 即时模式 UI 封装（git 依赖） |
| DevEco NDK / OHOS SDK | — | HarmonyOS 平台构建需要 |

> 依赖库通过 `cjpm.toml` 的 git 依赖自动拉取；项目依赖的静态库文件按需置入 `libs/` 目录。

## 构建与使用

### 构建引擎库

```bash
# 在 three/ 目录下构建引擎（输出动态库）
cjpm build
```

> **链接符号说明（跨平台）**：cjpm 将每个仓颉子包链接为独立动态库，第三方仓颉 FFI 包以
> 静态归档链入，需抑制其 mangled 符号的跨动态库重复导出、同时保持 C API 全局导出以收敛
> C 库全局状态（bgfx `g_ctx`、OpenAL context 等）单例。各平台控制文件均随仓库提供：
> Windows（MinGW）用 `libs/exclude.rsp`（ld.lld response file）；Linux/OHOS（ELF）用
> `libs/symbols_elf.map`（`--version-script`，第三方仓颉符号与 `_Z*` 标记为 local）；
> macOS（ld64）为两阶段命名空间，暂用默认配置。第三方依赖增减/升级（改 cjpm.toml
> dependencies 或 `cjpm update`）或 `libs/` 下 C/C++ 库重编译后，先构建一次再运行
> `python scripts/gen_exclude_rsp.py` 即可同时刷新两个文件
> （详见 [scripts/README_zh.md](./scripts/README_zh.md)）。

### 辅助脚本

`scripts/` 目录提供工程辅助脚本（Python 3.9+，仅标准库）：

| 脚本 | 说明 |
|------|------|
| `gen_exclude_rsp.py` | 扫描编译归档，自动生成跨平台链接符号控制文件：Windows 用 `libs/exclude.rsp`、Linux/OHOS 用 `libs/symbols_elf.map`（依赖增减/升级或 C 库重编译后刷新；支持 `--dry-run` 只统计） |
| `check_so_deps.py` | 递归分析 `.so` 的 `DT_NEEDED` 依赖链并输出 Markdown，标注缺失/系统/循环依赖，用于 OHOS HAP / Linux so 加载排障 |
| `generate_structure.py` | 生成目录的文件清单（`--mode 1`）或树状层级（`--mode 2`）Markdown |

完整参数与示例见 [scripts/README_zh.md](./scripts/README_zh.md)。

### 运行测试案例

```bash
# Windows 渲染案例（以 boxshow 为例）
cd test/windows/boxshow
cjpm build
cjpm run
```

更多案例见 `test/windows/`、`test/general/` 与 `test/ohos/` 目录。

### 在项目中使用

**注意**：本项目 `cjpm.toml` 的 `link-option` 引用了 `EXTEDN_LIBS_PATH_*` 环境变量，使用前需配置其值为依赖文件的实际存放位置。比如：`cmd: set EXTEDN_LIBS_PATH_WIN_X64=/path/to/three/libs`

在 `cjpm.toml` 中添加依赖：

```toml
[dependencies]
  [dependencies.three]
    path = "path/to/three"
    output-type = "static"
```

在仓颉代码中导入：

```cangjie
import three.rendering.*      // 渲染（BgfxRenderer/BgfxRenderTarget）
import three.rendering.geometry.*  // 几何体
import three.rendering.materials.* // 材质
import three.rendering.cameras.*   // 相机
import three.rendering.lights.*    // 灯光
import three.scene.scenegraph.*    // 场景图（Scene/Group/Fog）
import three.scene.entity.*        // 实体（Mesh/Points/Line/Sprite...）
import three.core.math.*           // 数学工具
import three.window.*              // 窗口与输入（WindowEngine）
import three.resource.*            // 资源加载
import three.physics.*             // 物理
import three.audio.*               // 音频
import three.script.*              // 脚本
import three.window.ui.*          // 即时模式 UI（ImGui 控件）
```

## 线程模型

引擎各子系统采用"独立系统线程 + 串行化调用"的统一线程模型，避免仓颉用户态线程（M:N）在系统线程间迁移带来的平台 API 约束：

| 子系统 | 线程模型 |
|--------|----------|
| `BgfxRenderer` | 全部 bgfx API 经 `_execBgfx` 串行化到专用渲染系统线程（`SThread`）执行 |
| `AudioContext` | 全部 OpenAL 调用串行化到音频系统线程 |
| `PhysicsWorld` | 物理后端调用经 `_execPhysics` 串行化到物理线程，渲染线程仅回读 transform 同步 |
| `WindowEngine` | SDL 主线程 API 固定在一个系统线程（事件泵），每窗口一条用户态泵线程（读固定事件快照 + 生命周期回调） |
| `ShaderCompiler` | 运行时 shader 编译按需启动专用系统线程（`SThread`，自定义栈默认 8MB），单 worker 串行编译（glslang 非线程安全），经 `start()`/`restart()` 启停 |

## API 文档

项目[API](./doc/api/zh-cn/)

项目源码遵循统一的[文档注释书写标准](./doc/dev%20manual/zh-cn/注释书写标准.md)（基于 cjdoc，中英双语），可通过 [cjdoc](https://gitcode.com/yq24w/cjdoc) 工具直接从源码提取生成 API 文档。

## 联系方式

![QQ群](https://24dim.com/other/qq%20group.png)
<a href="https://24dim.com/other/qq%20group.png"><img alt="QQ群" src="https://24dim.com/other/qq%20group.png" style="display: inline-block;" /></a>

> 注：由于使用的是外链，部分平台可能无法在线预览，请下载文件后本地浏览，或者点击加载异常图标尝试跳转浏览。

## 开源协议

本项目代码基于 [MIT](./LICENSE) 协议开源。

### 依赖项目许可

**注意**：本项目依赖的原生 C/C++ 库各自遵循其原始开源协议，使用时请遵守对应库的协议义务。依赖清单及协议如下：

| 原生 C/C++ 项目 | Git 仓库 | 协议 |
|------------------|----------|------|
| bgfx（渲染引擎，含 bimg 图像库、bx 基础库） | https://github.com/bkaradzic/bgfx | BSD 2-Clause |
| OpenAL Soft（音频） | https://github.com/kcat/openal-soft | LGPL-2.1-or-later |
| Jolt Physics（物理） | https://github.com/jrouwe/JoltPhysics | MIT |
| LuaJIT（脚本） | https://github.com/LuaJIT/LuaJIT | MIT |
| SDL3（窗口/输入） | https://github.com/libsdl-org/SDL | zlib |
| OpenSSL | https://github.com/openssl/openssl | Apache-2.0 |
| imgui | https://github.com/ocornut/imgui | MIT |

> 以上原生库通过对应的仓颉封装工程接入（`bgfx4cj` / `openalsoft4cj` / `jolt4cj` / `luajit4cj` / `sdl4cj` / `httpclient4cj`/`imgui4cj`，封装层均为 MIT 协议）。另注：bgfx 附带的工具链（shaderc/geometryc 等）及第三方库（glslang、miniz、tinyexr 等）各有其独立协议，使用前请查阅对应项目源码目录下的 LICENSE。

## 参与贡献

欢迎大家提交 PR、Issue，欢迎大家参与任何形式的贡献！