import { appTasks } from '@ohos/hvigor-ohos-plugin';
import * as path from 'node:path'

// three 包（test/three/cjpm.toml 的 link-option）引用 ${EXTEDN_LIBS_PATH}，
// 指向 three 引擎扩展静态库目录。cjpm 子进程继承 hvigor 进程的环境变量；
// 若该变量为空，ld.lld 链接宏包 DLL 时会出现孤立 "-L"，把紧跟其后的
// -l:libcangjie-std-*.dll 吞作 -L 的目录参数，导致宏包链接报
// undefined symbol: _CGPatiiHv（std.core 宏 ABI init 符号）。
// hvigor 以项目根（本文件所在目录）为 cwd，libs 位于 entry/libs 下。
let libsPath = path.resolve(process.cwd(), 'entry/libs')
process.env.EXTEDN_LIBS_PATH = `${libsPath} -L ${libsPath}/arm64-v8a`

export default {
  system: appTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: []       /* Custom plugin to extend the functionality of Hvigor. */
}