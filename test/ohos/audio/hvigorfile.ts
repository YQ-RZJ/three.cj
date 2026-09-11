import { appTasks } from '@ohos/hvigor-ohos-plugin';
import * as path from 'node:path'
import { existsSync } from 'node:fs'

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
// "lld: error: unable to find library"。项目根向上 3 级回到 three/，
// 故为 ../../../libs；置于搜索路径末尾，OHOS 目标链接仍优先命中
// entry/libs 与 arm64-v8a 下的库。
let threeLibsPath = path.resolve(process.cwd(), '../../../libs')
// 系统 MinGW 库目录：宏包按 Windows 宿主链接为 DLL 时，需要 Windows 系统
// 库（libgdi32.a、libd3d11.a、libwinmm.a 等）。pc 工程通过 CMake 显式设置
// PATH 保留系统 MinGW，cjc 据此推导出库路径；使用 cangjieOptions 走
// DevEco 插件调 cjpm 时，插件可能覆盖 PATH，导致 cjc 找不到 gcc 而生成空前缀
// 路径（-L/lib 而非 -LD:\...\mingw64/lib）。此处直接补到搜索路径末尾。
let mingwLibs = (() => {
  let dirs = process.env.PATH?.split(';') ?? []
  for (let d of dirs) {
    if (d && existsSync(path.join(d, 'gcc.exe'))) {
      // gcc.exe 位于 <prefix>/bin/，Windows 系统库在
      // <prefix>/x86_64-w64-mingw32/lib/（libgdi32.a、libd3d11.a 等）
      return ` -L ${path.resolve(d, '..', 'x86_64-w64-mingw32', 'lib')}`
    }
  }
  return ''
})()
process.env.EXTEDN_LIBS_PATH = `${libsPath}`
process.env.EXTEDN_LINK_OPTION = `-L ${libsPath}/arm64-v8a -L ${threeLibsPath}${mingwLibs}`

export default {
  system: appTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: []       /* Custom plugin to extend the functionality of Hvigor. */
}
