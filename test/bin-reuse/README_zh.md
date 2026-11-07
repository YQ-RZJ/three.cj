# bin-reuse —— three 引擎二进制产物复用示例

本项目演示**直接复用 three 引擎的二进制产物**（`bin-dependencies` + `three-deps.a`），
而非引入引擎源码自行编译、收集依赖。

## 为什么用二进制复用

| 方式 | 需要准备 | 适用场景 |
|---|---|---|
| **二进制复用（本项目）** | 下载 release 静态产物包，解压进 `libs/` | 快速集成、验证、业务开发 |
| 源码依赖（参考引擎仓库 cjpm.toml 的 `[dependencies]`） | 引擎源码 + 9 个依赖包源码 + native 静态库包（`EXTEDN_LIBS_PATH` 环境）+ exclude.rsp 生成 | 需要修改引擎代码 |

二进制复用把"编译引擎、收集 20+ 个依赖库、处理符号冲突"这些事全部留在了
引擎 CI 里，下游只剩**解压 + 声明链接**两步。

## 快速开始

### 1. 下载产物

到 [three.cj releases](https://github.com/YQ-RZJ/three.cj/releases) 下载与
本机平台匹配的静态产物包 `three-<os>-<arch>-static.zip`，解压到本项目 `libs/`。

解压后目录结构（与 cjpm.toml 中的约定对应）：

```
libs/
├── three-deps.a        # 全部 native 依赖 + 工具链 C++ 运行时的合并归档
├── three/              # 引擎本体：*.cjo + lib<包名>.a + 宏插件动态库
├── bgfx4cj/            # 9 个依赖包：各自 *.cjo + lib<包名>.a
├── fastjson/
├── httpclient4cj/
├── imgui4cj/
├── jolt4cj/
├── luajit4cj/
├── openalsoft4cj/
├── sdl4cj/
└── tracy4cj/
```

### 2. 编译运行

```bash
cjpm build            # 默认本机 target
cjpm build --target x86_64-w64-mingw32   # 或指定 target（见 cjpm.toml 支持列表）
cjpm run
```

Windows / Linux / macOS 无需任何额外环境变量；
**OHOS / iOS / Android** 需先设置对应 SDK 环境变量（见 cjpm.toml 各 target 注释）：

| 平台 | 环境变量 |
|---|---|
| OHOS | `DEVECO_CANGJIE_HOME`、`DEVECO_OH_NATIVE_HOME` |
| iOS | `IOS_SYSROOT`、`IOS_XCODE_TOOLCHAIN` |
| Android | `CANGJIE_HOME`、`ANDROID_NDK_HOME` |

## 工作原理

- **`[target.<triple>.bin-dependencies].path-option`**：把 `libs/<模块>/` 声明为
  二进制模块目录，cjc 编译期直接从中加载 `.cjo`（import 解析、类型检查），
  cjpm 链接期自动带上同目录的 `lib<包名>.a`——等价于源码依赖，但跳过编译；
- **`three-deps.a`**：引擎 CI 已把全部 native 静态库（bgfx/SDL3/OpenSSL/Jolt/
  LuaJIT/tracy 等 24 个）与工具链 C++ 运行时（`libc++.a`/`libunwind.a`、
  `libstdc++.a`/`libgcc_eh.a`、`libc++_static.a`/`libc++abi.a` 等）合并成的单一归档，
  下游 `link-option` 中一行 `-l:three-deps.a` 即可全部带入；
- **`link-option` 尾部的系统库/框架清单**：只有操作系统提供的内容
  （Windows 的 d3d11/ws2_32 等、macOS/iOS 的 Cocoa/UIKit 等框架、Linux 的 X11/pthread 等、
  OHOS 的 native_window.so、Android 的 EGL/ndk 库）。清单与引擎仓库 cjpm.toml
  各 target 保持一致——引擎依赖集变化时以引擎仓库 cjpm.toml 为准同步。

## 自行引入（不用本仓库）

若想在已有工程里引入引擎二进制产物，参考本目录 cjpm.toml：

1. 把产物解压到工程的某个目录（如 `libs/`，也可按平台分目录并用条件配置）；
2. 为当前 target 添加 `[target.<triple>.bin-dependencies]` 的
   `path-option = ["./libs/<模块>", ...]`（每个模块目录一项）；
3. 在 `[target.<triple>]` 的 `link-option` 里加 `-L libs -l:three-deps.a`
   加上该平台系统库清单；
4. 若需要静态库清单核对，可参考产物包内的 `MANIFEST.txt`（列出 three-deps.a
   的全部输入归档与成员数）。

## 注意事项

- **cjc 版本匹配**：产物 `.cjo`/`.a` 与编译器版本绑定，
  升级仓颉 SDK 后需换用对应版本的 release 产物；
- **宏插件动态库**：各模块目录内的 `lib-macro_*.dll/.dylib/.so` 在**编译期**
  由 cjc 加载执行，请勿删除；Windows 下若宏加载失败，将所在目录加入 `Path`；
- **平台与产物对应**：`--target` 必须与解压产物包的平台一致
  （如用 `three-macos-arm64-v8a-static.zip` 就不要切到 `x86_64-apple-darwin`）；
- **OHOS 特例**：SDL3 在 OHOS 上为动态链接，运行期需 `libSDL3.so` 与应用同目录
  （产物包内已附带）；`-l:libnative_window.so` 由系统提供；
- **首次编译报 undefined symbol**：检查 `libs/three-deps.a` 是否存在且来自
  与本 target 匹配的平台包（MANIFEST.txt 可核对内容）。

## 目录内容

```
cjpm.toml      # 全平台链接配置（本 README 的配置载体）
src/main.cj    # 最小使用示例
src/renderer.cj
src/resources.cj
libs/          # 解压 release 静态产物到此处（不入库，见 .gitignore）
```
