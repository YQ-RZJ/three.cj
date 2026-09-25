import { appTasks } from '@ohos/hvigor-ohos-plugin';
import * as path from 'node:path'

// ============================================================================
// 仓颉 PC(2in1) 交叉编译环境变量
//
// pc 工程移除 cangjieOptions，改用 externalNativeOptions(CMake) 间接调用
// OHOS 仓颉 SDK 的 cjpm 编译仓颉工程（规避 2in1 deviceTypes 限制）。cjpm
// 子进程继承 hvigor 进程的环境变量，因此在此统一注入：
//   CANGJIE_HOME         -> 指向 OHOS 仓颉 SDK 的 build-tools（cjc 据此定位
//                           modules/<triple>，不能指向 SDK 根，否则 cjc 会找
//                           到不存在的 .../modules 目录而报
//                           "target library path is not exist"）
//   DEVECO_CANGJIE_HOME  -> SDK 根，cjpm.toml 用 ${DEVECO_CANGJIE_HOME}/api 等
//   DEVECO_OH_NATIVE_HOME-> OHOS NDK 根，cjpm.toml 用其 sysroot/llvm 交叉编译
//   AARCH64_*            -> aarch64-linux-ohos 目标的 bin-dependencies
//   EXTEDN_LIBS_PATH     -> three 包 link-option 引用的扩展静态库目录
// ============================================================================
const cjSdkRoot = 'C:\\Users\\Administrator\\.cangjie-sdk\\6.1\\cangjie'
const ohNativeRoot = 'D:\\Venv\\OpenHarmonySDK\\23\\native'

// cjc 依据 CANGJIE_HOME 定位标准库 modules；OHOS SDK 的 cjc 位于
// <root>/build-tools/bin，modules 位于 <root>/build-tools/modules
process.env.CANGJIE_HOME = path.join(cjSdkRoot, 'build-tools')
process.env.DEVECO_CANGJIE_HOME = cjSdkRoot
process.env.DEVECO_OH_NATIVE_HOME = ohNativeRoot

process.env.AARCH64_LIBS = path.join(cjSdkRoot, 'api/lib/linux_ohos_aarch64_cjnative/ohos')
process.env.AARCH64_MACRO_LIBS = path.join(cjSdkRoot, 'api/macro/ohos')
process.env.AARCH64_KIT_LIBS = path.join(cjSdkRoot, 'api/lib/linux_ohos_aarch64_cjnative/kit')

// x86_64-linux-ohos 目标（cjpm.toml bin-dependencies + CMake 透传），备用
process.env.X86_64_OHOS_LIBS = path.join(cjSdkRoot, 'api/lib/linux_ohos_x86_64_cjnative/ohos')
process.env.X86_64_MACRO_LIBS = path.join(cjSdkRoot, 'api/macro/ohos')
process.env.X86_64_KIT_LIBS = path.join(cjSdkRoot, 'api/lib/linux_ohos_x86_64_cjnative/kit')

// three 包（test/three/cjpm.toml 的 link-option）引用 ${EXTEDN_LIBS_PATH}，
// 指向 three 引擎扩展静态库目录。cjpm 子进程继承 hvigor 进程的环境变量；
// 若该变量为空，ld.lld 链接宏包 DLL 时会出现孤立 "-L"，把紧跟其后的
// -l:libcangjie-std-*.dll 吞作 -L 的目录参数，导致宏包链接报
// undefined symbol: _CGPatiiHv（std.core 宏 ABI init 符号）。
// hvigor 以项目根（本文件所在目录）为 cwd，libs 位于 entry/libs 下。
let libsPath = path.resolve(process.cwd(), 'entry/libs')
// three 引擎扩展静态库目录（Windows 宿主版 libSDL3.a / libOpenAL32.a /
// libstdc++.a / libgcc_eh.a 等）：交叉编译时宏包按宿主（Windows x86_64）
// 链接为 DLL，而 entry/libs 仅部署 OHOS aarch64 产物，缺少这 4 个宿主库会报
// "lld: error: unable to find library"。项目根(pc) 向上 3 级回到 three/，
// 故为 ../../../libs；置于搜索路径末尾，OHOS 目标链接仍优先命中
// entry/libs 与 arm64-v8a 下的库。
let threeLibsPath = path.resolve(process.cwd(), '../../../libs')
process.env.EXTEDN_LIBS_PATH_OHOS_ARM64 = `${libsPath}`
process.env.EXTEDN_LINK_OPTION_OHOS_ARM64 = `-L ${libsPath}/arm64-v8a`
process.env.EXTEDN_LIBS_PATH_WIN_X64 = `${threeLibsPath}`

// cjpm.toml 的 compile-option 引用 ${COMPILE_CONDITION_ENTRY}
// （--cfg="${COMPILE_CONDITION_ENTRY}"）。DevEco 插件在 getCjpmProcessEnv 中注入，
// 此处手动补齐，取值与 base 工程编译日志一致：
//   APILevel_level=<compatibleSdkVersion.fullVersion>,product=<product>,APILevel_syscap=<syscap json>,target=default
const syscapJson = path.join(process.cwd(), '.idea/.deveco/cangjie/syscap_api_config.json')
process.env.COMPILE_CONDITION_ENTRY = `APILevel_level=23,product=default,APILevel_syscap=${syscapJson},target=default`
process.env.COMPILE_CONDITION = process.env.COMPILE_CONDITION_ENTRY

// ============================================================================
// 仓颉 runtime .so 拷贝黑白名单（纯 CMake 在 configure 期过滤拷贝）
// 规则：白名单为空 -> 全量拷贝 SDK runtime 目录，仅剔除黑名单；
//       白名单非空 -> 只拷白名单内的库（黑名单仍优先剔除）。
// 修改名单后重新构建即生效；从黑名单移除的库会在下次构建时被补拷回来
// （清理只作用于仓颉 runtime 家族：libcangjie-* / libsecurec / libboundscheck /
//  libpcre2-*，libSDL3 等工程自有 .so 不受影响）。
//
// 通配符：名单项支持 * 匹配任意字符序列（仅 *，按完整文件名锚定匹配）：
//   '*'                        -> 全部 .so（黑名单=全不拷 / 白名单=全拷）
//   'libcangjie-std-unittest*' -> unittest 全族一条顶 8 项
//   'libcangjie-std-math*'     -> 选中 std-math.so + std-math.numeric.so
//   精确名（如 'libcangjie-runtime.so'）照常使用。
// ============================================================================
// 白名单：仅拷贝这些 .so（逗号分隔，空 = 全量拷贝）
process.env.CJ_STD_INCLUDE = [
  // 'libcangjie-std-core.so',
].join(',')
// 黑名单：始终排除的 .so（逗号分隔，支持通配符）
process.env.CJ_STD_EXCLUDE = [
  // unittest 全族（UI 应用用不到）
  'libcangjie-std-unittest*',
  // ast/reflect（unittest 依赖链，运行期不使用）
  'libcangjie-std-ast.so',
  'libcangjie-std-reflect.so',
  // database（当前工程未使用）
  'libcangjie-std-database.so',
  'libcangjie-std-database.sql.so',
].join(',')

export default {
  system: appTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: []       /* Custom plugin to extend the functionality of Hvigor. */
}
