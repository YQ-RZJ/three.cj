/**
 * @file luajit4cj.luajit 常量定义
 * @brief Lua/LuaJIT 核心 API 的常量
 * @explain 本文件包含 lua.h / lauxlib.h / luajit.h 中全部 #define 常量的
 *         仓颉版本（过滤编译宏），直接映射自 C 头文件。
 * @note 枚举值（类型码/状态码/GC 操作码/JIT 模式等）见 types.cj。
 */
protected package three._vendor.luajit4cj.luajit

// =============================================================================
// 版本信息
// =============================================================================

/** @brief Lua 版本号（LUA_VERSION_NUM = 501） */
public const LUA_VERSION_NUM: Int32 = 501

/** @brief Lua 版本字符串（LUA_VERSION = "Lua 5.1"） */
public const LUA_VERSION: String = "Lua 5.1"

/** @brief Lua 发布版本（LUA_RELEASE = "Lua 5.1.4"） */
public const LUA_RELEASE: String = "Lua 5.1.4"

/** @brief Lua 版权声明（LUA_COPYRIGHT） */
public const LUA_COPYRIGHT: String = "Copyright (C) 1994-2008 Lua.org, PUC-Rio"

/** @brief LuaJIT 版本字符串（LUAJIT_VERSION） */
public const LUAJIT_VERSION: String = "LuaJIT 2.1.1785746657"

/** @brief LuaJIT 版本号（LUAJIT_VERSION_NUM，已弃用） */
public const LUAJIT_VERSION_NUM: Int32 = 20199

/** @brief LuaJIT 版权声明（LUAJIT_COPYRIGHT） */
public const LUAJIT_COPYRIGHT: String = "Copyright (C) 2005-2026 Mike Pall"

/** @brief LuaJIT 官网（LUAJIT_URL） */
public const LUAJIT_URL: String = "https://luajit.org/"

// =============================================================================
// 伪索引
// =============================================================================

/** @brief 注册表索引（LUA_REGISTRYINDEX = -10000） */
public const LUA_REGISTRYINDEX: Int32 = -10000
/** @brief 环境表索引（LUA_ENVIRONINDEX = -10001） */
public const LUA_ENVIRONINDEX: Int32 = -10001
/** @brief 全局表索引（LUA_GLOBALSINDEX = -10002） */
public const LUA_GLOBALSINDEX: Int32 = -10002

// =============================================================================
// 多返回值
// =============================================================================

/** @brief 多返回值标记（LUA_MULTRET = -1） */
public const LUA_MULTRET: Int32 = -1

// =============================================================================
// 线程状态
// =============================================================================

/** @brief 成功（LUA_OK = 0） */
public const LUA_OK: Int32 = 0
/** @brief 让出（LUA_YIELD = 1） */
public const LUA_YIELD: Int32 = 1
/** @brief 运行错误（LUA_ERRRUN = 2） */
public const LUA_ERRRUN: Int32 = 2
/** @brief 语法错误（LUA_ERRSYNTAX = 3） */
public const LUA_ERRSYNTAX: Int32 = 3
/** @brief 内存错误（LUA_ERRMEM = 4） */
public const LUA_ERRMEM: Int32 = 4
/** @brief 错误处理中的错误（LUA_ERRERR = 5） */
public const LUA_ERRERR: Int32 = 5

// =============================================================================
// lauxlib 错误码
// =============================================================================

/** @brief 文件错误（LUA_ERRFILE = LUA_ERRERR + 1 = 6） */
public const LUA_ERRFILE: Int32 = 6

// =============================================================================
// 类型码（与 types.cj LuaType 对应）
// =============================================================================

/** @brief 无值（LUA_TNONE = -1） */
public const LUA_TNONE: Int32 = -1
/** @brief nil（LUA_TNIL = 0） */
public const LUA_TNIL: Int32 = 0
/** @brief 布尔（LUA_TBOOLEAN = 1） */
public const LUA_TBOOLEAN: Int32 = 1
/** @brief 轻量 userdata（LUA_TLIGHTUSERDATA = 2） */
public const LUA_TLIGHTUSERDATA: Int32 = 2
/** @brief 数值（LUA_TNUMBER = 3） */
public const LUA_TNUMBER: Int32 = 3
/** @brief 字符串（LUA_TSTRING = 4） */
public const LUA_TSTRING: Int32 = 4
/** @brief 表（LUA_TTABLE = 5） */
public const LUA_TTABLE: Int32 = 5
/** @brief 函数（LUA_TFUNCTION = 6） */
public const LUA_TFUNCTION: Int32 = 6
/** @brief 完整 userdata（LUA_TUSERDATA = 7） */
public const LUA_TUSERDATA: Int32 = 7
/** @brief 协程/线程（LUA_TTHREAD = 8） */
public const LUA_TTHREAD: Int32 = 8

// =============================================================================
// 栈
// =============================================================================

/** @brief C 函数最小可用栈空间（LUA_MINSTACK = 20） */
public const LUA_MINSTACK: Int32 = 20

// =============================================================================
// 其他 lua.h / luaconf.h 常量
// =============================================================================

/** @brief 调试信息短源码缓冲大小（LUA_IDSIZE = 60，luaconf.h） */
public const LUA_IDSIZE: Int32 = 60

/** @brief 模式匹配最大捕获数（LUA_MAXCAPTURES = 32，luaconf.h） */
public const LUA_MAXCAPTURES: Int32 = 32

/**
 * @brief luaL_Buffer 内部缓冲大小（LUAL_BUFFERSIZE，lauxlib.h）
 * @explain C 侧定义为 (BUFSIZ > 16384 ? 8192 : BUFSIZ)；
 *         本机 mingw 的 BUFSIZ = 512，故取 512（与 types.cj 中 luaL_Buffer 一致）。
 */
public const LUAL_BUFFERSIZE: Int32 = 512

/** @brief 目录分隔符（LUA_DIRSEP，Windows 为 "\\"） */
public const LUA_DIRSEP: String = "\\"

/** @brief 路径列表分隔符（LUA_PATHSEP，Windows 为 ";"） */
public const LUA_PATHSEP: String = ";"

/** @brief 路径模板占位符（LUA_PATH_MARK = "?"） */
public const LUA_PATH_MARK: String = "?"

// =============================================================================
// GC 操作码（与 types.cj GcOption 对应）
// =============================================================================

/** @brief 停止 GC（LUA_GCSTOP = 0） */
public const LUA_GCSTOP: Int32 = 0
/** @brief 重启 GC（LUA_GCRESTART = 1） */
public const LUA_GCRESTART: Int32 = 1
/** @brief 执行完整 GC 周期（LUA_GCCOLLECT = 2） */
public const LUA_GCCOLLECT: Int32 = 2
/** @brief 返回当前内存使用量 KB（LUA_GCCOUNT = 3） */
public const LUA_GCCOUNT: Int32 = 3
/** @brief 返回当前内存使用量余数字节（LUA_GCCOUNTB = 4） */
public const LUA_GCCOUNTB: Int32 = 4
/** @brief 执行增量 GC 步骤（LUA_GCSTEP = 5） */
public const LUA_GCSTEP: Int32 = 5
/** @brief 设置 GC 间歇率（LUA_GCSETPAUSE = 6） */
public const LUA_GCSETPAUSE: Int32 = 6
/** @brief 设置 GC 步进倍率（LUA_GCSETSTEPMUL = 7） */
public const LUA_GCSETSTEPMUL: Int32 = 7
/** @brief 返回 GC 是否运行（LUA_GCISRUNNING = 9） */
public const LUA_GCISRUNNING: Int32 = 9

// =============================================================================
// Debug Hook 事件码
// =============================================================================

/** @brief 函数调用（LUA_HOOKCALL = 0） */
public const LUA_HOOKCALL: Int32 = 0
/** @brief 函数返回（LUA_HOOKRET = 1） */
public const LUA_HOOKRET: Int32 = 1
/** @brief 行执行（LUA_HOOKLINE = 2） */
public const LUA_HOOKLINE: Int32 = 2
/** @brief 计数触发（LUA_HOOKCOUNT = 3） */
public const LUA_HOOKCOUNT: Int32 = 3
/** @brief 尾调用返回（LUA_HOOKTAILRET = 4） */
public const LUA_HOOKTAILRET: Int32 = 4

// =============================================================================
// Debug Hook 掩码
// =============================================================================

/** @brief 调用掩码（LUA_MASKCALL = 1 << 0） */
public const LUA_MASKCALL: Int32 = 1 << 0
/** @brief 返回掩码（LUA_MASKRET = 1 << 1） */
public const LUA_MASKRET: Int32 = 1 << 1
/** @brief 行掩码（LUA_MASKLINE = 1 << 2） */
public const LUA_MASKLINE: Int32 = 1 << 2
/** @brief 计数掩码（LUA_MASKCOUNT = 1 << 3） */
public const LUA_MASKCOUNT: Int32 = 1 << 3

// =============================================================================
// lauxlib 引用常量
// =============================================================================

/** @brief 无引用（LUA_NOREF = -2） */
public const LUA_NOREF: Int32 = -2
/** @brief 引用 nil（LUA_REFNIL = -1） */
public const LUA_REFNIL: Int32 = -1

// =============================================================================
// 标准库名
// =============================================================================

/** @brief 协程库名（LUA_COLIBNAME） */
public const LUA_COLIBNAME: String = "coroutine"
/** @brief 数学库名（LUA_MATHLIBNAME） */
public const LUA_MATHLIBNAME: String = "math"
/** @brief 字符串库名（LUA_STRLIBNAME） */
public const LUA_STRLIBNAME: String = "string"
/** @brief 表库名（LUA_TABLIBNAME） */
public const LUA_TABLIBNAME: String = "table"
/** @brief I/O 库名（LUA_IOLIBNAME） */
public const LUA_IOLIBNAME: String = "io"
/** @brief OS 库名（LUA_OSLIBNAME） */
public const LUA_OSLIBNAME: String = "os"
/** @brief 包库名（LUA_LOADLIBNAME） */
public const LUA_LOADLIBNAME: String = "package"
/** @brief 调试库名（LUA_DBLIBNAME） */
public const LUA_DBLIBNAME: String = "debug"
/** @brief 位操作库名（LUA_BITLIBNAME） */
public const LUA_BITLIBNAME: String = "bit"
/** @brief JIT 库名（LUA_JITLIBNAME） */
public const LUA_JITLIBNAME: String = "jit"
/** @brief FFI 库名（LUA_FFILIBNAME） */
public const LUA_FFILIBNAME: String = "ffi"

// =============================================================================
// LuaJIT 模式常量
// =============================================================================

/** @brief 模式掩码（LUAJIT_MODE_MASK = 0x00FF） */
public const LUAJIT_MODE_MASK: Int32 = 0x00FF

/** @brief 关闭模式（LUAJIT_MODE_OFF = 0x0000） */
public const LUAJIT_MODE_OFF: Int32 = 0x0000
/** @brief 开启模式（LUAJIT_MODE_ON = 0x0100） */
public const LUAJIT_MODE_ON: Int32 = 0x0100
/** @brief 刷新模式（LUAJIT_MODE_FLUSH = 0x0200） */
public const LUAJIT_MODE_FLUSH: Int32 = 0x0200

/** @brief JIT 引擎模式（LUAJIT_MODE_ENGINE = 0） */
public const LUAJIT_MODE_ENGINE: Int32 = 0
/** @brief 调试模式（LUAJIT_MODE_DEBUG = 1） */
public const LUAJIT_MODE_DEBUG: Int32 = 1
/** @brief 函数模式（LUAJIT_MODE_FUNC = 2） */
public const LUAJIT_MODE_FUNC: Int32 = 2
/** @brief 递归全部函数（LUAJIT_MODE_ALLFUNC = 3） */
public const LUAJIT_MODE_ALLFUNC: Int32 = 3
/** @brief 递归子函数（LUAJIT_MODE_ALLSUBFUNC = 4） */
public const LUAJIT_MODE_ALLSUBFUNC: Int32 = 4
/** @brief 刷新 trace（LUAJIT_MODE_TRACE = 5） */
public const LUAJIT_MODE_TRACE: Int32 = 5
/** @brief C 函数包装（LUAJIT_MODE_WRAPCFUNC = 0x10） */
public const LUAJIT_MODE_WRAPCFUNC: Int32 = 0x10
