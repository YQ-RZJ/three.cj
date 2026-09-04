/**
 * @file[zh-cn] Script 脚本模块父包（three.script）
 * @brief[zh-cn] 脚本模块父包（仅声明 three.script 包，便于 cjpm 识别 vm/binding/hotreload 子包）
 * @explain[zh-cn] 本文件为包锚文件，不含任何代码。脚本模块按职责拆分为三个子包：
 * - three.script.vm：LuaJIT 虚拟机高级封装（LuaVM/LuaValue/LuaTable/LuaFunction/LuaError）；
 * - three.script.binding：仓颉与 Lua 双向绑定（LuaBinder 将仓颉函数注册为 Lua 全局函数/表方法）；
 * - three.script.hotreload：脚本热更新（LuaHotReload 检测文件变更并自动重新加载）。
 * 底层依赖 luajit4cj（LuaJIT 2.1 CFFI，覆盖 lua.h/lauxlib.h/lualib.h/luajit.h 全部 API）。
 *
 * @file[en] Script  Script module root package (three.script)
 * @brief[en] Script module root package (declares only the three.script package
 * so cjpm can recognize the vm/binding/hotreload sub-packages)
 * @explain[en] This file is a package anchor and contains no code. The script module is
 * split into three sub-packages by responsibility:
 * - three.script.vm: high-level LuaJIT VM wrapper (LuaVM/LuaValue/LuaTable/LuaFunction/LuaError);
 * - three.script.binding: bidirectional Cangjie-Lua binding (LuaBinder registers Cangjie
 * functions as Lua globals or table methods);
 * - three.script.hotreload: script hot reload (LuaHotReload detects file changes and reloads automatically).
 * It is built on luajit4cj (LuaJIT 2.1 CFFI, covering the full lua.h/lauxlib.h/lualib.h/luajit.h API).
 *
 * @intro[zh-cn] three.script 提供基于 LuaJIT 的脚本子系统：VM 封装、仓颉与 Lua 双向绑定与脚本热更新。
 * @intro[en] three.script provides a LuaJIT-based scripting subsystem: VM wrapper,
 * Cangjie-Lua bidirectional binding and script hot reload.
 */
package three.script
