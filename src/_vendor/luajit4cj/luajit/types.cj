/**
 * @file luajit4cj.luajit 类型定义
 * @brief Lua/LuaJIT 核心 API 的枚举与类型定义
 * @explain 本文件包含 lua.h / lauxlib.h / luajit.h 中的枚举类型。
 *         仓颉枚举是引用类型，不满足 CType 约束，不能直接用作 foreign
 *         函数参数/返回值类型。foreign 函数使用底层整数表示（Int32 / UInt32），
 *         调用方通过 `EnumType.value()` 与 `EnumType.fromValue(i32)` 转换。
 * @note 参数标识符（如 LUA_TNIL、LUA_REGISTRYINDEX 等）为普通常量，
 *       见 constants.cj。
 */
protected package three._vendor.luajit4cj.luajit

/**
 * @brief Lua 类型码（lua_type 返回值）
 * @explain 对应 lua.h 中 LUA_TNONE ~ LUA_TTHREAD。
 */
public enum LuaType {
    /** @brief 无值（LUA_TNONE = -1） */
    | None
    /** @brief nil（LUA_TNIL = 0） */
    | Nil
    /** @brief 布尔（LUA_TBOOLEAN = 1） */
    | Boolean
    /** @brief 轻量 userdata（LUA_TLIGHTUSERDATA = 2） */
    | LightUserData
    /** @brief 数值（LUA_TNUMBER = 3） */
    | Number
    /** @brief 字符串（LUA_TSTRING = 4） */
    | String
    /** @brief 表（LUA_TTABLE = 5） */
    | Table
    /** @brief 函数（LUA_TFUNCTION = 6） */
    | Function
    /** @brief 完整 userdata（LUA_TUSERDATA = 7） */
    | UserData
    /** @brief 协程/线程（LUA_TTHREAD = 8） */
    | Thread

    /** @brief 将枚举值转换为 Int32（C ABI 兼容） */
    public func value(): Int32 {
        match (this) {
            case None => -1
            case Nil => 0
            case Boolean => 1
            case LightUserData => 2
            case Number => 3
            case String => 4
            case Table => 5
            case Function => 6
            case UserData => 7
            case Thread => 8
        }
    }

    /** @brief 从 Int32 转换回枚举值 */
    public static func fromValue(v: Int32): LuaType {
        match (v) {
            case -1 => None
            case 0 => Nil
            case 1 => Boolean
            case 2 => LightUserData
            case 3 => Number
            case 4 => String
            case 5 => Table
            case 6 => Function
            case 7 => UserData
            case 8 => Thread
            case _ => None
        }
    }
}

/**
 * @brief Lua 状态码（lua_pcall / lua_resume / lua_status 返回值）
 * @explain 对应 lua.h 中 LUA_OK ~ LUA_ERRERR。
 */
public enum LuaStatus {
    /** @brief 成功（LUA_OK = 0） */
    | Ok
    /** @brief 让出（LUA_YIELD = 1） */
    | Yield
    /** @brief 运行错误（LUA_ERRRUN = 2） */
    | ErrRun
    /** @brief 语法错误（LUA_ERRSYNTAX = 3） */
    | ErrSyntax
    /** @brief 内存错误（LUA_ERRMEM = 4） */
    | ErrMem
    /** @brief 错误处理中的错误（LUA_ERRERR = 5） */
    | ErrErr
    /** @brief 文件错误（LUA_ERRFILE = 6，lauxlib.h） */
    | ErrFile

    public func value(): Int32 {
        match (this) {
            case Ok => 0
            case Yield => 1
            case ErrRun => 2
            case ErrSyntax => 3
            case ErrMem => 4
            case ErrErr => 5
            case ErrFile => 6
        }
    }

    public static func fromValue(v: Int32): LuaStatus {
        match (v) {
            case 0 => Ok
            case 1 => Yield
            case 2 => ErrRun
            case 3 => ErrSyntax
            case 4 => ErrMem
            case 5 => ErrErr
            case 6 => ErrFile
            case _ => ErrRun
        }
    }
}

/**
 * @brief GC 操作码（lua_gc 的 what 参数）
 * @explain 对应 lua.h 中 LUA_GCSTOP ~ LUA_GCISRUNNING。
 */
public enum GcOption {
    /** @brief 停止 GC（LUA_GCSTOP = 0） */
    | Stop
    /** @brief 重启 GC（LUA_GCRESTART = 1） */
    | Restart
    /** @brief 执行完整 GC 周期（LUA_GCCOLLECT = 2） */
    | Collect
    /** @brief 返回当前内存使用量（KB）（LUA_GCCOUNT = 3） */
    | Count
    /** @brief 返回当前内存使用量余数（字节）（LUA_GCCOUNTB = 4） */
    | CountB
    /** @brief 执行增量 GC 步骤（LUA_GCSTEP = 5） */
    | Step
    /** @brief 设置 GC 间歇率（LUA_GCSETPAUSE = 6） */
    | SetPause
    /** @brief 设置 GC 步进倍率（LUA_GCSETSTEPMUL = 7） */
    | SetStepMul
    /** @brief 返回 GC 是否运行（LUA_GCISRUNNING = 9） */
    | IsRunning

    public func value(): Int32 {
        match (this) {
            case Stop => 0
            case Restart => 1
            case Collect => 2
            case Count => 3
            case CountB => 4
            case Step => 5
            case SetPause => 6
            case SetStepMul => 7
            case IsRunning => 9
        }
    }

    public static func fromValue(v: Int32): GcOption {
        match (v) {
            case 0 => Stop
            case 1 => Restart
            case 2 => Collect
            case 3 => Count
            case 4 => CountB
            case 5 => Step
            case 6 => SetPause
            case 7 => SetStepMul
            case 9 => IsRunning
            case _ => Stop
        }
    }
}

/**
 * @brief LuaJIT 模式操作码（luaJIT_setmode 的 mode 参数低 8 位）
 * @explain 对应 luajit.h 中 LUAJIT_MODE_ENGINE ~ LUAJIT_MODE_MAX。
 */
public enum JitMode {
    /** @brief 设置 JIT 引擎模式（LUAJIT_MODE_ENGINE = 0） */
    | Engine
    /** @brief 设置调试模式（LUAJIT_MODE_DEBUG = 1） */
    | Debug
    /** @brief 改变函数模式（LUAJIT_MODE_FUNC = 2） */
    | Func
    /** @brief 递归子函数原型（LUAJIT_MODE_ALLFUNC = 3） */
    | AllFunc
    /** @brief 仅改变子函数（LUAJIT_MODE_ALLSUBFUNC = 4） */
    | AllSubFunc
    /** @brief 刷新已编译 trace（LUAJIT_MODE_TRACE = 5） */
    | Trace
    /** @brief 设置 C 函数包装模式（LUAJIT_MODE_WRAPCFUNC = 0x10） */
    | WrapCFunc

    public func value(): Int32 {
        match (this) {
            case Engine => 0
            case Debug => 1
            case Func => 2
            case AllFunc => 3
            case AllSubFunc => 4
            case Trace => 5
            case WrapCFunc => 0x10
        }
    }

    /** @brief 从 Int32 转换回枚举值 */
    public static func fromValue(v: Int32): JitMode {
        match (v) {
            case 0 => Engine
            case 1 => Debug
            case 2 => Func
            case 3 => AllFunc
            case 4 => AllSubFunc
            case 5 => Trace
            case 0x10 => WrapCFunc
            case _ => Engine
        }
    }
}

/**
 * @brief LuaJIT 模式标志位（与 JitMode 按位或）
 * @explain 对应 luajit.h 中 LUAJIT_MODE_OFF / ON / FLUSH。
 */
public enum JitModeFlag {
    /** @brief 关闭（LUAJIT_MODE_OFF = 0x0000） */
    | Off
    /** @brief 开启（LUAJIT_MODE_ON = 0x0100） */
    | On
    /** @brief 刷新（LUAJIT_MODE_FLUSH = 0x0200） */
    | Flush

    public func value(): Int32 {
        match (this) {
            case Off => 0x0000
            case On => 0x0100
            case Flush => 0x0200
        }
    }
}

/**
 * @brief Debug 事件码（lua_Hook 回调的 event 参数）
 * @explain 对应 lua.h 中 LUA_HOOKCALL ~ LUA_HOOKTAILRET。
 */
public enum HookEvent {
    /** @brief 函数调用（LUA_HOOKCALL = 0） */
    | Call
    /** @brief 函数返回（LUA_HOOKRET = 1） */
    | Return
    /** @brief 行执行（LUA_HOOKLINE = 2） */
    | Line
    /** @brief 计数触发（LUA_HOOKCOUNT = 3） */
    | Count
    /** @brief 尾调用返回（LUA_HOOKTAILRET = 4） */
    | TailReturn

    public func value(): Int32 {
        match (this) {
            case Call => 0
            case Return => 1
            case Line => 2
            case Count => 3
            case TailReturn => 4
        }
    }
}

/**
 * @brief Debug 事件掩码（用于 lua_sethook 的 mask 参数）
 * @explain 对应 lua.h 中 LUA_MASKCALL ~ LUA_MASKCOUNT。
 */
public enum HookMask {
    /** @brief 调用掩码（LUA_MASKCALL = 1 << 0） */
    | Call
    /** @brief 返回掩码（LUA_MASKRET = 1 << 1） */
    | Return
    /** @brief 行掩码（LUA_MASKLINE = 1 << 2） */
    | Line
    /** @brief 计数掩码（LUA_MASKCOUNT = 1 << 3） */
    | Count

    public func value(): Int32 {
        match (this) {
            case Call => 1 << 0
            case Return => 1 << 1
            case Line => 1 << 2
            case Count => 1 << 3
        }
    }
}

// =============================================================================
// C 结构体（@C struct，内存布局与 C 一致）
// =============================================================================

/**
 * @brief 库函数注册表项（lauxlib.h 的 luaL_Reg）
 * @explain 对应 C 的：
 *   typedef struct luaL_Reg { const char *name; lua_CFunction func; } luaL_Reg;
 *   用于 luaL_register / luaL_setfuncs / luaL_openlib 等注册 API。
 */
@C
public struct luaL_Reg {
    /** @brief 函数名（C 字符串） */
    public var name: CString
    /** @brief 函数指针（lua_CFunction） */
    public var `func`: CFunc<(CPointer<Unit>) -> Int32>

    public init() {
        this.name = CString(CPointer<UInt8>())
        this.`func` = CFunc<(CPointer<Unit>) -> Int32>(CPointer<Int8>())
    }
}

/**
 * @brief Lua 调试信息结构（lua.h 的 lua_Debug）
 * @explain 对应 C 的 lua_Debug，由 lua_getstack / lua_getinfo 填充。
 *   short_src 为 char[LUA_IDSIZE]，LUA_IDSIZE = 60。
 */
@C
public struct lua_Debug {
    /** @brief 事件类型（LUA_HOOKCALL 等） */
    public var event: Int32 = 0
    /** @brief (n) 函数名，可为 null */
    public var name: CString
    /** @brief (n) 名称类别：global/local/field/method */
    public var namewhat: CString
    /** @brief (S) 类型：Lua/C/main/tail */
    public var what: CString
    /** @brief (S) 源码位置描述 */
    public var source: CString
    /** @brief (l) 当前行号 */
    public var currentline: Int32 = 0
    /** @brief (u) upvalue 数量 */
    public var nups: Int32 = 0
    /** @brief (S) 定义起始行 */
    public var linedefined: Int32 = 0
    /** @brief (S) 定义结束行 */
    public var lastlinedefined: Int32 = 0
    /** @brief (S) 短源码描述，char[LUA_IDSIZE] */
    public var short_src = VArray<UInt8, $60>(repeat: 0)
    /** @brief 私有字段：激活函数索引 */
    public var i_ci: Int32 = 0

    public init() {
        this.name = CString(CPointer<UInt8>())
        this.namewhat = CString(CPointer<UInt8>())
        this.what = CString(CPointer<UInt8>())
        this.source = CString(CPointer<UInt8>())
    }
}

/**
 * @brief 字符串缓冲区（lauxlib.h 的 luaL_Buffer）
 * @explain 对应 C 的：
 *   typedef struct luaL_Buffer {
 *     char *p; lua_State *L; int lvl; char buffer[LUAL_BUFFERSIZE];
 *   } luaL_Buffer;
 *   注意：LUAL_BUFFERSIZE 取决于平台 BUFSIZ（mingw 为 512），
 *   此结构体通常配合 luaL_buffinit / luaL_addlstring / luaL_pushresult 使用，
 *   一般无需直接访问内部字段。
 */
@C
public struct luaL_Buffer {
    /** @brief 当前缓冲区写指针 */
    public var p: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 栈上字符串数量（level） */
    public var lvl: Int32 = 0
    /** @brief Lua 状态机指针 */
    public var L: CPointer<Unit> = CPointer<Unit>()
    /** @brief 缓冲区本体，char[LUAL_BUFFERSIZE] */
    public var buffer = VArray<UInt8, $512>(repeat: 0)

    public init() {}
}
