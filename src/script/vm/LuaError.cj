/**
 * @file[zh-cn] LuaError Lua 脚本引擎异常类型（three.script.vm 子包）
 * @brief[zh-cn] 脚本引擎异常类型，统一表示 Lua 脚本执行期间发生的各类错误
 * @explain[zh-cn] 所有 Lua 脚本相关错误（语法错误/运行时错误/内存错误/文件加载失败）统一抛出 LuaError，
 * 携带错误码与错误消息，便于上层 try/catch 捕获。错误码对照 luajit4cj.constants：
 * - LUA_OK = 0        成功（不会抛异常）
 * - LUA_ERRRUN = 2    运行时错误
 * - LUA_ERRSYNTAX = 3 语法错误
 * - LUA_ERRMEM = 4    内存错误
 * - LUA_ERRERR = 5    错误处理函数出错
 * - LUA_ERRFILE = 6   文件打开/加载失败
 *
 * @file[en] LuaError  Scripting engine exception type (three.script.vm sub-package)
 * @brief[en] Scripting engine exception type unifying all errors raised during Lua script execution
 * @explain[en] All Lua-related errors (syntax/runtime/memory/file-loading) are raised as LuaError,
 * carrying an error code and message so upper layers can catch them with try/catch.
 * Error codes match luajit4cj.constants:
 * - LUA_OK = 0        success (never thrown)
 * - LUA_ERRRUN = 2    runtime error
 * - LUA_ERRSYNTAX = 3 syntax error
 * - LUA_ERRMEM = 4    memory error
 * - LUA_ERRERR = 5    error in error-handling function
 * - LUA_ERRFILE = 6   file open/load failure
 */
package three.script.vm

/**
 * @brief[zh-cn] Lua 脚本执行异常
 * @explain[zh-cn] 携带 Lua 错误码与错误消息，供上层统一捕获并识别错误类别。
 *
 * @brief[en] Lua script execution exception
 * @explain[en] Carries the Lua error code and message so upper layers can catch and
 * classify errors uniformly.
 *
 * @example[zh-cn] 捕获脚本语法错误
 * @example[en] Catching a script syntax error
 * try {
 * vm.doString("return 1 + ")
 * } catch (e: LuaError) {
 * println("脚本错误: " + e.message)  // 语法错误
 * }
 */
public class LuaError <: Exception {
    /**
     * @brief[zh-cn] Lua 错误码（LUA_ERRRUN 等）
     *
     * @brief[en] Lua error code (LUA_ERRRUN etc.)
     */
    public let code: Int32

    /**
     * @brief[zh-cn] 构造脚本异常
     * @param[zh-cn] message 错误消息（含栈回溯时更长）
     * code    Lua 错误码（默认 LUA_ERRRUN）
     *
     * @brief[en] Constructs a script exception
     * @param[en] message Error message (longer when it includes a stack traceback)
     * code    Lua error code (defaults to LUA_ERRRUN)
     */
    public init(message: String, code!: Int32 = 2) {
        super(message)
        this.code = code
    }

    /**
     * @brief[zh-cn] 错误码名称（便于日志输出）
     *
     * @brief[en] Error code name (useful for logging)
     */
    public prop codeName: String {
        get() {
            match (this.code) {
                case 2 => "LUA_ERRRUN"
                case 3 => "LUA_ERRSYNTAX"
                case 4 => "LUA_ERRMEM"
                case 5 => "LUA_ERRERR"
                case 6 => "LUA_ERRFILE"
                case _ => "LUA_ERRUNKNOWN(${this.code})"
            }
        }
    }
}
