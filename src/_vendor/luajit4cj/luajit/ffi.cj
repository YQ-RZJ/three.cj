/**
 * @file luajit4cj.luajit CFFI 函数声明（lua.h / lauxlib.h / lualib.h / luajit.h 核心）
 * @brief Lua/LuaJIT 核心 C API 的 foreign 函数声明
 * @explain 本文件包含 lua.h、lauxlib.h、lualib.h 及 luajit.h 中全部公开 API
 *         的 foreign 声明。lua_State 为不透明指针，使用 CPointer<Unit> 表示；
 *         lua_CFunction 使用 CFunc 表示；lua_Number 对应 Float64；lua_Integer
 *         对应 Int64（LuaJIT 默认 ptrdiff_t）；枚举参数使用底层整数。
 * @note 本文件的函数是包级私有，外部调用请使用 ffi_exports.cj 中的 _cj 包装。
 */
protected package three._vendor.luajit4cj.luajit

// =============================================================================
// 状态操作（State manipulation）
// =============================================================================

@FastNative
foreign func lua_newstate(f: CFunc<(CPointer<Unit>, CPointer<Unit>, UIntNative, UIntNative) -> CPointer<Unit>>, ud: CPointer<Unit>): CPointer<Unit>

@FastNative
foreign func lua_close(L: CPointer<Unit>): Unit

@FastNative
foreign func lua_newthread(L: CPointer<Unit>): CPointer<Unit>

@FastNative
foreign func lua_atpanic(L: CPointer<Unit>, panicf: CFunc<(CPointer<Unit>) -> Int32>): CFunc<(CPointer<Unit>) -> Int32>

// =============================================================================
// 基本栈操作（Basic stack manipulation）
// =============================================================================

@FastNative
foreign func lua_gettop(L: CPointer<Unit>): Int32

@FastNative
foreign func lua_settop(L: CPointer<Unit>, idx: Int32): Unit

@FastNative
foreign func lua_pushvalue(L: CPointer<Unit>, idx: Int32): Unit

@FastNative
foreign func lua_remove(L: CPointer<Unit>, idx: Int32): Unit

@FastNative
foreign func lua_insert(L: CPointer<Unit>, idx: Int32): Unit

@FastNative
foreign func lua_replace(L: CPointer<Unit>, idx: Int32): Unit

@FastNative
foreign func lua_checkstack(L: CPointer<Unit>, sz: Int32): Int32

@FastNative
foreign func lua_xmove(from: CPointer<Unit>, to: CPointer<Unit>, n: Int32): Unit

// =============================================================================
// 栈访问函数（Access functions — stack → C）
// =============================================================================

@FastNative
foreign func lua_isnumber(L: CPointer<Unit>, idx: Int32): Int32

@FastNative
foreign func lua_isstring(L: CPointer<Unit>, idx: Int32): Int32

@FastNative
foreign func lua_iscfunction(L: CPointer<Unit>, idx: Int32): Int32

@FastNative
foreign func lua_isuserdata(L: CPointer<Unit>, idx: Int32): Int32

@FastNative
foreign func lua_type(L: CPointer<Unit>, idx: Int32): Int32

@FastNative
foreign func lua_typename(L: CPointer<Unit>, tp: Int32): CString

@FastNative
foreign func lua_equal(L: CPointer<Unit>, idx1: Int32, idx2: Int32): Int32

@FastNative
foreign func lua_rawequal(L: CPointer<Unit>, idx1: Int32, idx2: Int32): Int32

@FastNative
foreign func lua_lessthan(L: CPointer<Unit>, idx1: Int32, idx2: Int32): Int32

@FastNative
foreign func lua_tonumber(L: CPointer<Unit>, idx: Int32): Float64

@FastNative
foreign func lua_tointeger(L: CPointer<Unit>, idx: Int32): Int64

@FastNative
foreign func lua_toboolean(L: CPointer<Unit>, idx: Int32): Int32

@FastNative
foreign func lua_tolstring(L: CPointer<Unit>, idx: Int32, len: CPointer<UIntNative>): CString

@FastNative
foreign func lua_objlen(L: CPointer<Unit>, idx: Int32): UIntNative

@FastNative
foreign func lua_tocfunction(L: CPointer<Unit>, idx: Int32): CFunc<(CPointer<Unit>) -> Int32>

@FastNative
foreign func lua_touserdata(L: CPointer<Unit>, idx: Int32): CPointer<Unit>

@FastNative
foreign func lua_tothread(L: CPointer<Unit>, idx: Int32): CPointer<Unit>

@FastNative
foreign func lua_topointer(L: CPointer<Unit>, idx: Int32): CPointer<Unit>

// =============================================================================
// Lua 5.2+ 扩展访问函数
// =============================================================================

@FastNative
foreign func lua_tonumberx(L: CPointer<Unit>, idx: Int32, isnum: CPointer<Int32>): Float64

@FastNative
foreign func lua_tointegerx(L: CPointer<Unit>, idx: Int32, isnum: CPointer<Int32>): Int64

// =============================================================================
// 压栈函数（Push functions — C → stack）
// =============================================================================

@FastNative
foreign func lua_pushnil(L: CPointer<Unit>): Unit

@FastNative
foreign func lua_pushnumber(L: CPointer<Unit>, n: Float64): Unit

@FastNative
foreign func lua_pushinteger(L: CPointer<Unit>, n: Int64): Unit

@FastNative
foreign func lua_pushlstring(L: CPointer<Unit>, s: CString, l: UIntNative): Unit

@FastNative
foreign func lua_pushstring(L: CPointer<Unit>, s: CString): Unit

// 变参格式化压栈（lua_pushfstring(L, fmt, ...) / lua_pushvfstring(L, fmt, argp)）。
// 仓颉 foreign 不支持变参：lua_pushfstring 只声明固定部分（fmt），
// 需要格式化参数时请使用 lua_pushvfstring（argp 为 va_list，以指针传递）。
@FastNative
foreign func lua_pushfstring(L: CPointer<Unit>, fmt: CString): CString

@FastNative
foreign func lua_pushvfstring(L: CPointer<Unit>, fmt: CString, argp: CPointer<Unit>): CString

@FastNative
foreign func lua_pushcclosure(L: CPointer<Unit>, fn: CFunc<(CPointer<Unit>) -> Int32>, n: Int32): Unit

@FastNative
foreign func lua_pushboolean(L: CPointer<Unit>, b: Int32): Unit

@FastNative
foreign func lua_pushlightuserdata(L: CPointer<Unit>, p: CPointer<Unit>): Unit

@FastNative
foreign func lua_pushthread(L: CPointer<Unit>): Int32

// =============================================================================
// Get 函数（Lua → stack）
// =============================================================================

@FastNative
foreign func lua_gettable(L: CPointer<Unit>, idx: Int32): Unit

@FastNative
foreign func lua_getfield(L: CPointer<Unit>, idx: Int32, k: CString): Unit

@FastNative
foreign func lua_rawget(L: CPointer<Unit>, idx: Int32): Unit

@FastNative
foreign func lua_rawgeti(L: CPointer<Unit>, idx: Int32, n: Int32): Unit

@FastNative
foreign func lua_createtable(L: CPointer<Unit>, narr: Int32, nrec: Int32): Unit

@FastNative
foreign func lua_newuserdata(L: CPointer<Unit>, sz: UIntNative): CPointer<Unit>

@FastNative
foreign func lua_getmetatable(L: CPointer<Unit>, objindex: Int32): Int32

@FastNative
foreign func lua_getfenv(L: CPointer<Unit>, idx: Int32): Unit

// =============================================================================
// Set 函数（stack → Lua）
// =============================================================================

@FastNative
foreign func lua_settable(L: CPointer<Unit>, idx: Int32): Unit

@FastNative
foreign func lua_setfield(L: CPointer<Unit>, idx: Int32, k: CString): Unit

@FastNative
foreign func lua_rawset(L: CPointer<Unit>, idx: Int32): Unit

@FastNative
foreign func lua_rawseti(L: CPointer<Unit>, idx: Int32, n: Int32): Unit

@FastNative
foreign func lua_setmetatable(L: CPointer<Unit>, objindex: Int32): Int32

@FastNative
foreign func lua_setfenv(L: CPointer<Unit>, idx: Int32): Int32

// =============================================================================
// 加载与调用（Load and call functions）
// =============================================================================

foreign func lua_call(L: CPointer<Unit>, nargs: Int32, nresults: Int32): Unit

foreign func lua_pcall(L: CPointer<Unit>, nargs: Int32, nresults: Int32, errfunc: Int32): Int32

foreign func lua_cpcall(L: CPointer<Unit>, `func`: CFunc<(CPointer<Unit>) -> Int32>, ud: CPointer<Unit>): Int32

foreign func lua_load(L: CPointer<Unit>, reader: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<UIntNative>) -> CString>, dt: CPointer<Unit>, chunkname: CString): Int32

@FastNative
foreign func lua_dump(L: CPointer<Unit>, writer: CFunc<(CPointer<Unit>, CPointer<Unit>, UIntNative, CPointer<Unit>) -> Int32>, data: CPointer<Unit>): Int32

// Lua 5.2+ 扩展
foreign func lua_loadx(L: CPointer<Unit>, reader: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<UIntNative>) -> CString>, dt: CPointer<Unit>, chunkname: CString, mode: CString): Int32

// =============================================================================
// 协程函数（Coroutine functions）
// =============================================================================

@FastNative
foreign func lua_yield(L: CPointer<Unit>, nresults: Int32): Int32

@FastNative
foreign func lua_resume(L: CPointer<Unit>, narg: Int32): Int32

@FastNative
foreign func lua_status(L: CPointer<Unit>): Int32

@FastNative
foreign func lua_isyieldable(L: CPointer<Unit>): Int32

// =============================================================================
// GC 函数
// =============================================================================

foreign func lua_gc(L: CPointer<Unit>, what: Int32, data: Int32): Int32

// =============================================================================
// 杂项函数
// =============================================================================

foreign func lua_error(L: CPointer<Unit>): Int32

@FastNative
foreign func lua_next(L: CPointer<Unit>, idx: Int32): Int32

@FastNative
foreign func lua_concat(L: CPointer<Unit>, n: Int32): Unit

@FastNative
foreign func lua_getallocf(L: CPointer<Unit>, ud: CPointer<CPointer<Unit>>): CFunc<(CPointer<Unit>, CPointer<Unit>, UIntNative, UIntNative) -> CPointer<Unit>>

@FastNative
foreign func lua_setallocf(L: CPointer<Unit>, f: CFunc<(CPointer<Unit>, CPointer<Unit>, UIntNative, UIntNative) -> CPointer<Unit>>, ud: CPointer<Unit>): Unit

// Lua 5.2+ 扩展
@FastNative
foreign func lua_version(L: CPointer<Unit>): CPointer<Float64>

@FastNative
foreign func lua_copy(L: CPointer<Unit>, fromidx: Int32, toidx: Int32): Unit

// 注意：lua_setlevel 在 lua.h 中保留声明，但 LuaJIT 并未实现/导出该符号
// （DLL 与静态库中均无此函数），调用会导致链接失败，仅保留声明以对齐头文件。
@FastNative
foreign func lua_setlevel(from: CPointer<Unit>, to: CPointer<Unit>): Unit

// Upvalue 操作
@FastNative
foreign func lua_upvalueid(L: CPointer<Unit>, idx: Int32, n: Int32): CPointer<Unit>

@FastNative
foreign func lua_upvaluejoin(L: CPointer<Unit>, idx1: Int32, n1: Int32, idx2: Int32, n2: Int32): Unit

// =============================================================================
// Debug API
// =============================================================================

@FastNative
foreign func lua_getstack(L: CPointer<Unit>, level: Int32, ar: CPointer<Unit>): Int32

@FastNative
foreign func lua_getinfo(L: CPointer<Unit>, what: CString, ar: CPointer<Unit>): Int32

@FastNative
foreign func lua_getlocal(L: CPointer<Unit>, ar: CPointer<Unit>, n: Int32): CString

@FastNative
foreign func lua_setlocal(L: CPointer<Unit>, ar: CPointer<Unit>, n: Int32): CString

@FastNative
foreign func lua_getupvalue(L: CPointer<Unit>, funcindex: Int32, n: Int32): CString

@FastNative
foreign func lua_setupvalue(L: CPointer<Unit>, funcindex: Int32, n: Int32): CString

@FastNative
foreign func lua_sethook(L: CPointer<Unit>, `func`: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Unit>, mask: Int32, count: Int32): Int32

@FastNative
foreign func lua_gethook(L: CPointer<Unit>): CFunc<(CPointer<Unit>, CPointer<Unit>) -> Unit>

@FastNative
foreign func lua_gethookmask(L: CPointer<Unit>): Int32

@FastNative
foreign func lua_gethookcount(L: CPointer<Unit>): Int32

// =============================================================================
// 辅助库（lauxlib.h）
// =============================================================================

@FastNative
foreign func luaL_openlib(L: CPointer<Unit>, libname: CString, l: CPointer<Unit>, nup: Int32): Unit

@FastNative
foreign func luaL_register(L: CPointer<Unit>, libname: CString, l: CPointer<Unit>): Unit

@FastNative
foreign func luaL_getmetafield(L: CPointer<Unit>, obj: Int32, e: CString): Int32

@FastNative
foreign func luaL_callmeta(L: CPointer<Unit>, obj: Int32, e: CString): Int32

@FastNative
foreign func luaL_typerror(L: CPointer<Unit>, narg: Int32, tname: CString): Int32

@FastNative
foreign func luaL_argerror(L: CPointer<Unit>, numarg: Int32, extramsg: CString): Int32

@FastNative
foreign func luaL_checklstring(L: CPointer<Unit>, numArg: Int32, l: CPointer<UIntNative>): CString

@FastNative
foreign func luaL_optlstring(L: CPointer<Unit>, numArg: Int32, def: CString, l: CPointer<UIntNative>): CString

@FastNative
foreign func luaL_checknumber(L: CPointer<Unit>, numArg: Int32): Float64

@FastNative
foreign func luaL_optnumber(L: CPointer<Unit>, nArg: Int32, def: Float64): Float64

@FastNative
foreign func luaL_checkinteger(L: CPointer<Unit>, numArg: Int32): Int64

@FastNative
foreign func luaL_optinteger(L: CPointer<Unit>, nArg: Int32, def: Int64): Int64

@FastNative
foreign func luaL_checkstack(L: CPointer<Unit>, sz: Int32, msg: CString): Unit

@FastNative
foreign func luaL_checktype(L: CPointer<Unit>, narg: Int32, t: Int32): Unit

@FastNative
foreign func luaL_checkany(L: CPointer<Unit>, narg: Int32): Unit

@FastNative
foreign func luaL_newmetatable(L: CPointer<Unit>, tname: CString): Int32

@FastNative
foreign func luaL_checkudata(L: CPointer<Unit>, ud: Int32, tname: CString): CPointer<Unit>

@FastNative
foreign func luaL_where(L: CPointer<Unit>, lvl: Int32): Unit

@FastNative
foreign func luaL_error(L: CPointer<Unit>, fmt: CString): Int32

@FastNative
foreign func luaL_checkoption(L: CPointer<Unit>, narg: Int32, def: CString, lst: CPointer<CString>): Int32

@FastNative
foreign func luaL_ref(L: CPointer<Unit>, t: Int32): Int32

@FastNative
foreign func luaL_unref(L: CPointer<Unit>, t: Int32, ref: Int32): Unit

foreign func luaL_loadfile(L: CPointer<Unit>, filename: CString): Int32

foreign func luaL_loadbuffer(L: CPointer<Unit>, buff: CString, sz: UIntNative, name: CString): Int32

foreign func luaL_loadstring(L: CPointer<Unit>, s: CString): Int32

@FastNative
foreign func luaL_newstate(): CPointer<Unit>

@FastNative
foreign func luaL_gsub(L: CPointer<Unit>, s: CString, p: CString, r: CString): CString

@FastNative
foreign func luaL_findtable(L: CPointer<Unit>, idx: Int32, fname: CString, szhint: Int32): CString

// Lua 5.2+ 辅助库
@FastNative
foreign func luaL_fileresult(L: CPointer<Unit>, stat: Int32, fname: CString): Int32

@FastNative
foreign func luaL_execresult(L: CPointer<Unit>, stat: Int32): Int32

foreign func luaL_loadfilex(L: CPointer<Unit>, filename: CString, mode: CString): Int32

foreign func luaL_loadbufferx(L: CPointer<Unit>, buff: CString, sz: UIntNative, name: CString, mode: CString): Int32

@FastNative
foreign func luaL_traceback(L: CPointer<Unit>, L1: CPointer<Unit>, msg: CString, level: Int32): Unit

@FastNative
foreign func luaL_setfuncs(L: CPointer<Unit>, l: CPointer<Unit>, nup: Int32): Unit

@FastNative
foreign func luaL_pushmodule(L: CPointer<Unit>, modname: CString, sizehint: Int32): Unit

@FastNative
foreign func luaL_testudata(L: CPointer<Unit>, ud: Int32, tname: CString): CPointer<Unit>

@FastNative
foreign func luaL_setmetatable(L: CPointer<Unit>, tname: CString): Unit

// Buffer 操作
@FastNative
foreign func luaL_buffinit(L: CPointer<Unit>, B: CPointer<Unit>): Unit

@FastNative
foreign func luaL_prepbuffer(B: CPointer<Unit>): CString

@FastNative
foreign func luaL_addlstring(B: CPointer<Unit>, s: CString, l: UIntNative): Unit

@FastNative
foreign func luaL_addstring(B: CPointer<Unit>, s: CString): Unit

@FastNative
foreign func luaL_addvalue(B: CPointer<Unit>): Unit

@FastNative
foreign func luaL_pushresult(B: CPointer<Unit>): Unit

// =============================================================================
// 标准库打开函数（lualib.h）
// =============================================================================

@FastNative
foreign func luaopen_base(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_math(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_string(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_table(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_io(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_os(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_package(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_debug(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_bit(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_jit(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_ffi(L: CPointer<Unit>): Int32

@FastNative
foreign func luaopen_string_buffer(L: CPointer<Unit>): Int32

@FastNative
foreign func luaL_openlibs(L: CPointer<Unit>): Unit

// =============================================================================
// LuaJIT 扩展 API（luajit.h）
// =============================================================================

@FastNative
foreign func luaJIT_setmode(L: CPointer<Unit>, idx: Int32, mode: Int32): Int32

@FastNative
foreign func luaJIT_profile_start(L: CPointer<Unit>, mode: CString, cb: CFunc<(CPointer<Unit>, CPointer<Unit>, Int32, Int32) -> Unit>, data: CPointer<Unit>): Unit

@FastNative
foreign func luaJIT_profile_stop(L: CPointer<Unit>): Unit

@FastNative
foreign func luaJIT_profile_dumpstack(L: CPointer<Unit>, fmt: CString, depth: Int32, len: CPointer<UIntNative>): CString
