/**
 * @file luajit4cj 包入口
 * @brief luajit4cj 根包声明
 * @explain luajit4cj 是将 C 语言动态脚本引擎 LuaJIT 封装到仓颉生态系统的项目。
 *         提供以下子包（通过完整包路径引用）：
 *         - luajit4cj.luajit — Lua/LuaJIT 核心 API 绑定
 *           （lua.h / lauxlib.h / lualib.h / luajit.h 的全部公开 API）
 *         包含：
 *         - ffi.cj — foreign 函数声明（包级私有）
 *         - ffi_exports.cj — 安全包装函数（公开，_cj 后缀）
 *         - types.cj — 枚举类型（LuaType / LuaStatus / GcOption / JitMode 等）
 *         - constants.cj — 常量（伪索引 / 类型码 / GC 码 / 标准库名等）
 */
protected package three._vendor.luajit4cj
