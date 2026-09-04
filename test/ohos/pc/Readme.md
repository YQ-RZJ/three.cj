# three.cj OHOS PC(2in1) 工程说明

本工程在 OHOS 官方**不支持仓颉运行于 2in1 deviceTypes** 的限制下，实现仓颉 three 引擎跑在 PC(2in1) 上。

实现原理：`pc` 工程不再配置 `cangjieOptions`（否则 hvigor 报 `01103012 Configuration Error`），而是改用 **"C/C++ & ArkTS" 混合模式**，通过 `externalNativeOptions`(CMake) 间接调用 **OHOS 仓颉 SDK 自带的 `cjpm`** 交叉编译仓颉工程，再把产物与仓颉 runtime `.so` 拷入 `entry/libs/<abi>` 打包进 HAP。

```
hvigor(构建 ArkTS)
  └─ externalNativeOptions -> CMakeLists.txt
        └─ cjpm.exe build --target aarch64-linux-ohos   (编译 three 引擎 + entry 仓颉代码)
              └─ link-option 链接 entry/libs/librequirecj_napi.a (C++ NAPI 桥接库, 注册 requireCJLib)
        └─ 拷贝 target/<triple>/release/*.so + 仓颉 runtime .so -> entry/libs/<abi>
  └─ hvigor 将 entry/libs/<abi>/*.so 打包进 HAP
```

> 桥接库 `requireCJLib-ark` 通过 `__attribute__((constructor))` 自动注册 NAPI 模块，因此必须用 `--whole-archive` 强制链接，否则 constructor 会被链接器丢弃。源码位于仓库 `cxx_bridge/requireCJLib/requireCJLib-ark`，预编译产物在 `cxx_bridge/dist/requireCJLib-ophm-arm64-v8a-release-static-native.zip`。

---

## 1. 复用前置条件

- **DevEco Studio**（含 HarmonyOS SDK + 仓颉插件；本工程基于 HarmonyOS `6.1.0(23)` / 仓颉 SDK `26.0` 验证）。
- **OHOS 仓颉 SDK**：由 DevEco 仓颉插件自动安装，默认位于 `C:\Users\<你的用户名>\.cangjie-sdk\<版本>\cangjie`（本机为 `C:\Users\AI\.cangjie-sdk\26.0\cangjie`）。
- **保持 three.cj 仓库的目录结构**：`pc` 工程通过**相对路径** `entry/cjpm.toml` 中 `path = "../../../../"` 依赖 three 引擎根目录，因此复制/迁移时请保留 `three.cj/three` 相对关系。

---

## 2. 换机器 / 换 DevEco / 换 SDK 版本时需调整的内容

### 2.1 绝对路径（换机器必改）

| 文件 | 配置项 | 当前值（示例） | 说明 |
| --- | --- | --- | --- |
| `hvigorfile.ts` L19 | `cjSdkRoot` | `C:\\Users\\AI\\.cangjie-sdk\\26.0\\cangjie` | **OHOS 仓颉 SDK 根目录**，按新机器实际安装位置修改 |
| `hvigorfile.ts` L20 | `ohNativeRoot` | `C:\\Program Files\\HuaWei\\DevEco Studio\\sdk\\default\\openharmony\\native` | **DevEco 的 OHOS NDK 根目录**，按新机器 DevEco 安装位置修改 |
| `build-profile.json5` | `signingConfigs`（certpath / keyAlias / keyPassword / profile / storeFile / storePassword） | 指向 `C:\\Users\\AI\\.ohos\\config\\...` | **签名材料与机器/用户绑定**，新机器在 DevEco 中 `File → Project Structure → Signing Configs → Automatically generate signature` 重新生成即可（会回写此文件） |
| `.idea/.deveco/cangjie/syscap_api_config.json` | 被 `hvigorfile.ts` 的 `COMPILE_CONDITION_ENTRY` 引用 | （随工程生成） | 由 DevEco 仓颉插件自动生成，已被 `.gitignore` 忽略；换机器后重新打开工程会自动重建，**若缺失需让 DevEco 重新生成**（不可手动伪造）（缺失可复制提供的 [syscap_api_config.json](./syscap_api_config.json) 到该位置） |

> 注意：`hvigorfile.ts` 内的 `ohNativeRoot` 与 DevEco 安装位置强相关；换机器若 DevEco 装在非默认路径，务必同步修改，否则 `cjpm.toml` 中 `${DEVECO_OH_NATIVE_HOME}/sysroot` 等指向会失效。

### 2.2 版本号（换 DevEco / SDK 版本必改）

| 文件 | 配置项 | 当前值 | 需匹配/说明 |
| --- | --- | --- | --- |
| `entry/cjpm.toml`、`three/cjpm.toml` | `cjc-version` | `1.1.0` | 必须与所用仓颉 SDK 的 cjc 编译器版本一致（OHOS 仓颉 SDK 26.0 对应 1.1.0） |
| `entry/cjpm.toml`、`three/cjpm.toml` | target `compile-option` 中的 `llvm/lib/clang/15.0.4/lib/...` | `15.0.4` | 必须与 DevEco 自带 NDK 的 clang 版本一致；换 DevEco 后查看 `<NDK>/llvm/lib/clang/` 下实际目录名并同步修改 |
| `hvigorfile.ts` L51 | `COMPILE_CONDITION_ENTRY` 的 `APILevel_level=` | `23` | 必须与 `build-profile.json5` 的 `compatibleSdkVersion` 一致（`6.1.0(23)` → 23） |
| `build-profile.json5` | `targetSdkVersion` / `compatibleSdkVersion` | `6.1.0(23)` | 按新 SDK 支持的版本调整 |
| `hvigor/hvigor-config.json5`、`oh-package.json5` | `modelVersion` | `6.1.0` | 与 DevEco/HarmonyOS SDK 大版本匹配 |
| `hvigorfile.ts` L19 | 路径中的版本目录 | `26.0` | 仓颉 SDK 版本目录名，随 `CANGJIE_HOME` 一起改 |
| `entry/src/main/cangjie/types/*/Index.d.ts` | 仓颉 SDK 生成的类型声明（`libohos_app_cangjie_entry` / `libSDL3`） | 随版本 | 换 SDK 后让 DevEco 仓颉插件**重新生成**，避免 API 不匹配 |
| `entry/oh-package.json5` | `libohos_app_cangjie_entry.so` / `@types/libSDL3.so` 的 `file:` 依赖 | 随版本 | 同上，指向生成的 types 目录 |

### 2.3 目标架构（当前为 arm64-v8a）

- 本工程当前面向 **arm64-v8a**（`aarch64-linux-ohos`）验证通过；`CMakeLists.txt` 已内置 `x86_64`（`x86_64-linux-ohos`）映射，`cjpm.toml` 也已有对应 target。
- 但以下内容**硬编码了 arm64-v8a**，若切到 x86_64（Intel/AMD 的 2in1）需一并替换：
  - `hvigorfile.ts` L44 `EXTEDN_LIBS_PATH = ... -L ${libsPath}/arm64-v8a`（需按目标 abi 改）；
  - `entry/libs/librequirecj_napi.a`（桥接库，当前为 arm64 产物；需用 `cxx_bridge` 重新产出 x86_64 版本）；
  - `entry/libs/*.a`（three 引擎 arm64 静态库）与运行时 `.so`。

### 2.4 随仓库分发的预编译库（勿随意删改）

| 目录/文件 | 内容 | 来源 |
| --- | --- | --- |
| `entry/libs/*.a` | three 引擎 arm64-v8a 静态库（`libSDL3.a`、`libbgfx.a`、`libbimg*.a`、`libjoltc.a`、`libJolt.a` 等）+ 桥接库 `librequirecj_napi.a` | 引擎/桥接库预编译产物，由 `cjpm.toml` 的 `link-option` 直接链接 |
| `entry/libs/arm64-v8a/*.so` | 构建时由 CMake 从 `entry/target/<triple>/release` 与仓颉 SDK runtime 拷贝而来 | **构建产物**，删掉会在下一次构建自动重建 |
| `entry/target/**` | cjpm 增量编译输出（含 `ohos_app_cangjie_entry/libohos_app_cangjie_entry.so`） | **构建产物**，可删除重建 |

---

## 3. 换机器首次构建前的清理

新机器上打开工程前，建议删除以下**本机构建缓存**，避免残留旧产物/旧 .idea 干扰：

```
.hvigor
.idea          # DevEco 会自动重建（含 .deveco/cangjie/syscap_api_config.json）
.cxx
**/build
oh_modules
entry/target   # cjpm 增量缓存
```

然后：

1. DevEco 打开 `pc` 目录，等待插件生成 `.idea/.deveco/...` 与 `oh_modules`；
2. `File → Project Structure → Signing Configs` 自动生成签名（会回写 `build-profile.json5`）；
3. 按第 2 节核对 `hvigorfile.ts` 的两个绝对路径与各版本号；
4. 直接 Run / 构建。

> 首次构建 `entry/target` 为空时会全量编译 three 引擎，耗时较长属正常；后续为增量。

---

## 4. 常见问题（换环境后最可能遇到）

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `01103012 Configuration Error` | 直接给工程配置了 `cangjieOptions` 且 deviceTypes 含 `2in1` | 本工程已用 CMake 方案规避；若新建工程，**不要**添加 `cangjieOptions` |
| `00308018 Unknown Error` / ninja subcommand failed | 多种原因，看 ninja 下方具体 cjpm 报错 | 用下面几行定位 |
| 卡在 `[cjpm] building aarch64-linux-ohos ...` 长时间无输出 | 有**残留的 cjc/cjpm 进程**占着 `entry/target` 增量锁（多为被取消的构建残留，甚至来自错误工具链） | `Get-Process | Where-Object {$_.ProcessName -match 'cjc|cjpm'}` 找到并 `Stop-Process -Id <pid> -Force` 后重编 |
| `0xC0000139`（STATUS_ENTRYPOINT_NOT_FOUND） | cjpm.exe 启动时 PATH 缺少 OHOS 仓颉 SDK 宿主 DLL 目录 | 已由 `CMakeLists.txt` 前置 `runtime/lib/windows_x86_64_cjnative` 等目录解决；手动跑 cjpm 时需同样设置 PATH |
| `ld.lld: error: unknown argument '-Wl,--whole-archive'` | `cjpm.toml` 的 `link-option` 直接传给 ld.lld，`-Wl,` 是 clang/gcc 驱动才剥的前缀 | 用 `--whole-archive` / `--no-whole-archive`（不要带 `-Wl,`） |
| `target library path is not exist` | `CANGJIE_HOME` 指错了层级 | 必须指向 `<SDK>/build-tools`（cjc 据此定位 `modules/<triple>`），不能指向 SDK 根 |
| `COMPILE_CONDITION_ENTRY` 未设置 / 宏包链接报 `undefined symbol` | 手动命令行跑 cjpm 时缺少环境变量 | 手动复现时按下文第 5 节逐项注入环境变量 |

---

## 5. 手动跑 cjpm（排障用）

DevEco 内部实际执行的是 `entry/src/main/cpp/CMakeLists.txt` 生成的 `cjpm_build-*.bat`（位于 `entry/.cxx/default/default/debug/arm64-v8a/CMakeFiles/`）。手动复现时需注入同一组环境变量：

```powershell
$env:PATH  = 'C:\Users\<user>\.cangjie-sdk\26.0\cangjie\build-tools\runtime\lib\windows_x86_64_cjnative;' +
             'C:\Users\<user>\.cangjie-sdk\26.0\cangjie\build-tools\lib\windows_x86_64_cjnative;' +
             'C:\Users\<user>\.cangjie-sdk\26.0\cangjie\build-tools\bin;' +
             'C:\Users\<user>\.cangjie-sdk\26.0\cangjie\build-tools\tools\bin;' +
             'C:\Users\<user>\.cangjie-sdk\26.0\cangjie\build-tools\tools\lib;' + $env:PATH
$env:CANGJIE_HOME         = 'C:\Users\<user>\.cangjie-sdk\26.0\cangjie\build-tools'
$env:DEVECO_CANGJIE_HOME  = 'C:\Users\<user>\.cangjie-sdk\26.0\cangjie'
$env:DEVECO_OH_NATIVE_HOME= 'C:\Program Files\HuaWei\DevEco Studio\sdk\default\openharmony\native'
$env:AARCH64_LIBS         = "$env:DEVECO_CANGJIE_HOME\api\lib\linux_ohos_aarch64_cjnative\ohos"
$env:AARCH64_MACRO_LIBS   = "$env:DEVECO_CANGJIE_HOME\api\macro\ohos"
$env:AARCH64_KIT_LIBS     = "$env:DEVECO_CANGJIE_HOME\api\lib\linux_ohos_aarch64_cjnative\kit"
$env:EXTEDN_LIBS_PATH     = 'C:\workspace\Web\24w\three.cj\three\test\ohos\pc\entry\libs -L C:\workspace\Web\24w\three.cj\three\test\ohos\pc\entry\libs\arm64-v8a'
$env:COMPILE_CONDITION_ENTRY = 'APILevel_level=23,product=default,APILevel_syscap=C:\workspace\Web\24w\three.cj\three\test\ohos\pc\.idea\.deveco\cangjie\syscap_api_config.json,target=default'

cd C:\workspace\Web\24w\three.cj\three\test\ohos\pc\entry
& "$env:DEVECO_CANGJIE_HOME\build-tools\tools\bin\cjpm.exe" build --target aarch64-linux-ohos
```

产物位于 `entry/target/aarch64-linux-ohos/release/<包名>/*.so`，需自行拷贝到 `entry/libs/arm64-v8a`（CMake 自动完成该步骤）。

---

## 6. 相关工程/文件索引

| 路径 | 说明 |
| --- | --- |
| `three/test/ohos/base` | 官方支持的 OHOS 仓颉样例工程（参考环境变量/编译配置的来源） |
| `cxx_bridge/requireCJLib/requireCJLib-ark` | C++ NAPI 桥接库源码（自动注册 `requireCJLib` NAPI 模块） |
| `cxx_bridge/dist/requireCJLib-ophm-arm64-v8a-release-static-native.zip` | 桥接库预编译产物（解压取 `lib/napi/lib/librequirecj_napi.a` 放入 `entry/libs`） |
| `entry/src/main/cpp/CMakeLists.txt` | 编排 cjpm 构建 + 拷贝 `.so` 的核心脚本 |
| `hvigorfile.ts` | 注入 `CANGJIE_HOME` / `DEVECO_*` / `EXTEDN_LIBS_PATH` / `COMPILE_CONDITION_ENTRY` 等环境变量 |
| `entry/cjpm.toml` | entry 仓颉工程配置（link-option 链接桥接库 + 静态库） |
| `three/cjpm.toml` | three 引擎仓颉工程配置（目标平台 compile-option） |
