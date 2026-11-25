/**
 * @file luajit4cj.luajit 公共函数包装
 * @brief Lua/LuaJIT 核心 API 的仓颉安全包装函数
 * @explain 本文件为每个 foreign 函数提供 `_cj` 后缀的公共包装，
 *         所有 foreign 调用被包裹在 unsafe 块中以满足仓颉 FFI 要求。
 * @note 每个函数对应一个 C 端 Lua/LuaJIT 函数，功能与 C API 一致。
 */
protected package three._vendor.luajit4cj.luajit

// =============================================================================
// 状态操作（State manipulation）
// =============================================================================

/**
 * @brief 创建一个新的 Lua 状态机
 * @param f 内存分配函数（传 CPointer<Unit>() 使用默认分配器）
 * @param ud 内存分配器的用户数据
 * @return 新的 lua_State 指针，失败返回空指针
 */
public func lua_newstate_cj(f: CFunc<(CPointer<Unit>, CPointer<Unit>, UIntNative, UIntNative) -> CPointer<Unit>>, ud: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        lua_newstate(f, ud)
    }
}

/**
 * @brief 销毁 Lua 状态机及其所有对象
 * @param L Lua 状态机指针
 */
public func lua_close_cj(L: CPointer<Unit>): Unit {
    unsafe {
        lua_close(L)
    }
}

/**
 * @brief 创建一个新的协程线程
 * @param L 主线程
 * @return 新线程指针，压入栈顶
 */
public func lua_newthread_cj(L: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        lua_newthread(L)
    }
}

/**
 * @brief 设置 panic 函数
 * @param L Lua 状态机指针
 * @param panicf panic 回调函数
 * @return 旧的 panic 函数
 */
public func lua_atpanic_cj(L: CPointer<Unit>, panicf: CFunc<(CPointer<Unit>) -> Int32>): CFunc<(CPointer<Unit>) -> Int32> {
    unsafe {
        lua_atpanic(L, panicf)
    }
}

// =============================================================================
// 基本栈操作（Basic stack manipulation）
// =============================================================================

/**
 * @brief 获取栈顶元素的索引
 * @param L Lua 状态机指针
 * @return 栈顶索引（栈中元素数量）
 */
public func lua_gettop_cj(L: CPointer<Unit>): Int32 {
    unsafe {
        lua_gettop(L)
    }
}

/**
 * @brief 设置栈顶（增减栈元素）
 * @param L Lua 状态机指针
 * @param idx 新栈顶索引
 */
public func lua_settop_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_settop(L, idx)
    }
}

/**
 * @brief 将指定索引的值压入栈顶
 * @param L Lua 状态机指针
 * @param idx 源索引
 */
public func lua_pushvalue_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_pushvalue(L, idx)
    }
}

/**
 * @brief 移除指定索引的元素
 * @param L Lua 状态机指针
 * @param idx 要移除的索引
 */
public func lua_remove_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_remove(L, idx)
    }
}

/**
 * @brief 将栈顶元素插入到指定位置
 * @param L Lua 状态机指针
 * @param idx 目标索引
 */
public func lua_insert_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_insert(L, idx)
    }
}

/**
 * @brief 将栈顶元素替换指定索引
 * @param L Lua 状态机指针
 * @param idx 目标索引
 */
public func lua_replace_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_replace(L, idx)
    }
}

/**
 * @brief 确保栈有足够空间
 * @param L Lua 状态机指针
 * @param sz 需要的额外栈空间
 * @return 成功返回 1，失败返回 0
 */
public func lua_checkstack_cj(L: CPointer<Unit>, sz: Int32): Int32 {
    unsafe {
        lua_checkstack(L, sz)
    }
}

/**
 * @brief 在两个线程间交换栈元素
 * @param from 源线程
 * @param to 目标线程
 * @param n 交换元素数量
 */
public func lua_xmove_cj(from: CPointer<Unit>, to: CPointer<Unit>, n: Int32): Unit {
    unsafe {
        lua_xmove(from, to, n)
    }
}

// =============================================================================
// 栈访问函数（Access functions — stack → C）
// =============================================================================

/**
 * @brief 检查指定索引是否为数值（或可转换为数值）
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 1 表示是数值，0 表示不是
 */
public func lua_isnumber_cj(L: CPointer<Unit>, idx: Int32): Int32 {
    unsafe {
        lua_isnumber(L, idx)
    }
}

/**
 * @brief 检查指定索引是否为字符串（或数值，数值总可转为字符串）
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 1 表示是字符串，0 表示不是
 */
public func lua_isstring_cj(L: CPointer<Unit>, idx: Int32): Int32 {
    unsafe {
        lua_isstring(L, idx)
    }
}

/**
 * @brief 检查指定索引是否为 C 函数
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 1 表示是 C 函数，0 表示不是
 */
public func lua_iscfunction_cj(L: CPointer<Unit>, idx: Int32): Int32 {
    unsafe {
        lua_iscfunction(L, idx)
    }
}

/**
 * @brief 检查指定索引是否为 userdata
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 1 表示是 userdata，0 表示不是
 */
public func lua_isuserdata_cj(L: CPointer<Unit>, idx: Int32): Int32 {
    unsafe {
        lua_isuserdata(L, idx)
    }
}

/**
 * @brief 获取指定索引元素的类型
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 类型码（LUA_TNIL 等）
 */
public func lua_type_cj(L: CPointer<Unit>, idx: Int32): Int32 {
    unsafe {
        lua_type(L, idx)
    }
}

/**
 * @brief 获取类型名称
 * @param L Lua 状态机指针
 * @param tp 类型码
 * @return 类型名称 C 字符串
 */
public func lua_typename_cj(L: CPointer<Unit>, tp: Int32): CString {
    unsafe {
        lua_typename(L, tp)
    }
}

/**
 * @brief 比较两个元素是否相等（使用 __eq 元方法）
 * @param L Lua 状态机指针
 * @param idx1 第一个索引
 * @param idx2 第二个索引
 * @return 1 相等，0 不等
 */
public func lua_equal_cj(L: CPointer<Unit>, idx1: Int32, idx2: Int32): Int32 {
    unsafe {
        lua_equal(L, idx1, idx2)
    }
}

/**
 * @brief 原始比较两个元素是否相等（不使用元方法）
 * @param L Lua 状态机指针
 * @param idx1 第一个索引
 * @param idx2 第二个索引
 * @return 1 相等，0 不等
 */
public func lua_rawequal_cj(L: CPointer<Unit>, idx1: Int32, idx2: Int32): Int32 {
    unsafe {
        lua_rawequal(L, idx1, idx2)
    }
}

/**
 * @brief 比较两个元素的小于关系
 * @param L Lua 状态机指针
 * @param idx1 第一个索引
 * @param idx2 第二个索引
 * @return 1 表示 idx1 < idx2，0 表示不小于
 */
public func lua_lessthan_cj(L: CPointer<Unit>, idx1: Int32, idx2: Int32): Int32 {
    unsafe {
        lua_lessthan(L, idx1, idx2)
    }
}

/**
 * @brief 将指定索引的值转为 Float64 数值
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 数值（非数值返回 0）
 */
public func lua_tonumber_cj(L: CPointer<Unit>, idx: Int32): Float64 {
    unsafe {
        lua_tonumber(L, idx)
    }
}

/**
 * @brief 将指定索引的值转为 Int64 整数
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 整数值
 */
public func lua_tointeger_cj(L: CPointer<Unit>, idx: Int32): Int64 {
    unsafe {
        lua_tointeger(L, idx)
    }
}

/**
 * @brief 将指定索引的值转为布尔值
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 0 为假，非 0 为真
 */
public func lua_toboolean_cj(L: CPointer<Unit>, idx: Int32): Int32 {
    unsafe {
        lua_toboolean(L, idx)
    }
}

/**
 * @brief 将指定索引的值转为 C 字符串
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @param len 输出字符串长度的指针（传 CPointer<UIntNative>() 则不获取长度）
 * @return C 字符串指针
 */
public func lua_tolstring_cj(L: CPointer<Unit>, idx: Int32, len: CPointer<UIntNative>): CString {
    unsafe {
        lua_tolstring(L, idx, len)
    }
}

/**
 * @brief 获取对象的长度（# 运算符）
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 对象长度
 */
public func lua_objlen_cj(L: CPointer<Unit>, idx: Int32): UIntNative {
    unsafe {
        lua_objlen(L, idx)
    }
}

/**
 * @brief 将指定索引的值转为 C 函数
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return C 函数指针
 */
public func lua_tocfunction_cj(L: CPointer<Unit>, idx: Int32): CFunc<(CPointer<Unit>) -> Int32> {
    unsafe {
        lua_tocfunction(L, idx)
    }
}

/**
 * @brief 将指定索引的值转为 userdata 指针
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return userdata 指针
 */
public func lua_touserdata_cj(L: CPointer<Unit>, idx: Int32): CPointer<Unit> {
    unsafe {
        lua_touserdata(L, idx)
    }
}

/**
 * @brief 将指定索引的值转为线程指针
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 线程指针
 */
public func lua_tothread_cj(L: CPointer<Unit>, idx: Int32): CPointer<Unit> {
    unsafe {
        lua_tothread(L, idx)
    }
}

/**
 * @brief 将指定索引的值转为通用指针
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @return 通用指针
 */
public func lua_topointer_cj(L: CPointer<Unit>, idx: Int32): CPointer<Unit> {
    unsafe {
        lua_topointer(L, idx)
    }
}

// =============================================================================
// Lua 5.2+ 扩展访问函数
// =============================================================================

/**
 * @brief 将指定索引的值转为 Float64（带类型检查）
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @param isnum 输出是否为数值的指针
 * @return 数值
 */
public func lua_tonumberx_cj(L: CPointer<Unit>, idx: Int32, isnum: CPointer<Int32>): Float64 {
    unsafe {
        lua_tonumberx(L, idx, isnum)
    }
}

/**
 * @brief 将指定索引的值转为 Int64（带类型检查）
 * @param L Lua 状态机指针
 * @param idx 栈索引
 * @param isnum 输出是否为整数指针
 * @return 整数值
 */
public func lua_tointegerx_cj(L: CPointer<Unit>, idx: Int32, isnum: CPointer<Int32>): Int64 {
    unsafe {
        lua_tointegerx(L, idx, isnum)
    }
}

// =============================================================================
// 压栈函数（Push functions — C → stack）
// =============================================================================

/**
 * @brief 压入 nil
 * @param L Lua 状态机指针
 */
public func lua_pushnil_cj(L: CPointer<Unit>): Unit {
    unsafe {
        lua_pushnil(L)
    }
}

/**
 * @brief 压入 Float64 数值
 * @param L Lua 状态机指针
 * @param n 数值
 */
public func lua_pushnumber_cj(L: CPointer<Unit>, n: Float64): Unit {
    unsafe {
        lua_pushnumber(L, n)
    }
}

/**
 * @brief 压入 Int64 整数
 * @param L Lua 状态机指针
 * @param n 整数值
 */
public func lua_pushinteger_cj(L: CPointer<Unit>, n: Int64): Unit {
    unsafe {
        lua_pushinteger(L, n)
    }
}

/**
 * @brief 压入指定长度的字符串
 * @param L Lua 状态机指针
 * @param s C 字符串指针
 * @param l 字符串长度
 */
public func lua_pushlstring_cj(L: CPointer<Unit>, s: CString, l: UIntNative): Unit {
    unsafe {
        lua_pushlstring(L, s, l)
    }
}

/**
 * @brief 压入以 \\0 结尾的字符串
 * @param L Lua 状态机指针
 * @param s C 字符串指针
 */
public func lua_pushstring_cj(L: CPointer<Unit>, s: CString): Unit {
    unsafe {
        lua_pushstring(L, s)
    }
}

/**
 * @brief 格式化字符串并压栈（lua_pushfstring 的固定参数形式）
 * @explain 对应 C 的 lua_pushfstring(L, fmt, ...)，仓颉侧仅暴露固定参数部分；
 *          需要可变参数时请使用 lua_pushvfstring_cj。
 * @param L Lua 状态机指针
 * @param fmt 格式字符串
 * @return 格式化后的字符串指针（Lua 内部管理，勿释放）
 */
public func lua_pushfstring_cj(L: CPointer<Unit>, fmt: CString): CString {
    unsafe {
        lua_pushfstring(L, fmt)
    }
}

/**
 * @brief 以 va_list 格式化字符串并压栈（对应 C 的 lua_pushvfstring）
 * @param L Lua 状态机指针
 * @param fmt 格式字符串
 * @param argp va_list 指针（由调用方构造）
 * @return 格式化后的字符串指针（Lua 内部管理，勿释放）
 */
public func lua_pushvfstring_cj(L: CPointer<Unit>, fmt: CString, argp: CPointer<Unit>): CString {
    unsafe {
        lua_pushvfstring(L, fmt, argp)
    }
}

/**
 * @brief 压入闭包（C 函数 + n 个 upvalue）
 * @param L Lua 状态机指针
 * @param fn C 函数
 * @param n upvalue 数量
 */
public func lua_pushcclosure_cj(L: CPointer<Unit>, fn: CFunc<(CPointer<Unit>) -> Int32>, n: Int32): Unit {
    unsafe {
        lua_pushcclosure(L, fn, n)
    }
}

/**
 * @brief 压入布尔值
 * @param L Lua 状态机指针
 * @param b 布尔值（0 为假，非 0 为真）
 */
public func lua_pushboolean_cj(L: CPointer<Unit>, b: Int32): Unit {
    unsafe {
        lua_pushboolean(L, b)
    }
}

/**
 * @brief 压入轻量 userdata
 * @param L Lua 状态机指针
 * @param p 指针
 */
public func lua_pushlightuserdata_cj(L: CPointer<Unit>, p: CPointer<Unit>): Unit {
    unsafe {
        lua_pushlightuserdata(L, p)
    }
}

/**
 * @brief 压入当前线程
 * @param L Lua 状态机指针
 * @return 1 表示线程为主线程，0 表示不是
 */
public func lua_pushthread_cj(L: CPointer<Unit>): Int32 {
    unsafe {
        lua_pushthread(L)
    }
}

// =============================================================================
// Get 函数（Lua → stack）
// =============================================================================

/**
 * @brief 从表中取值（键在栈顶，表在 idx）
 * @param L Lua 状态机指针
 * @param idx 表的索引
 */
public func lua_gettable_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_gettable(L, idx)
    }
}

/**
 * @brief 从表中按名称取值
 * @param L Lua 状态机指针
 * @param idx 表的索引
 * @param k 字段名
 */
public func lua_getfield_cj(L: CPointer<Unit>, idx: Int32, k: CString): Unit {
    unsafe {
        lua_getfield(L, idx, k)
    }
}

/**
 * @brief 原始表取值
 * @param L Lua 状态机指针
 * @param idx 表的索引
 */
public func lua_rawget_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_rawget(L, idx)
    }
}

/**
 * @brief 原始表按整数键取值
 * @param L Lua 状态机指针
 * @param idx 表的索引
 * @param n 整数键
 */
public func lua_rawgeti_cj(L: CPointer<Unit>, idx: Int32, n: Int32): Unit {
    unsafe {
        lua_rawgeti(L, idx, n)
    }
}

/**
 * @brief 创建空表
 * @param L Lua 状态机指针
 * @param narr 数组部分预分配大小
 * @param nrec 哈希部分预分配大小
 */
public func lua_createtable_cj(L: CPointer<Unit>, narr: Int32, nrec: Int32): Unit {
    unsafe {
        lua_createtable(L, narr, nrec)
    }
}

/**
 * @brief 分配并压入完整 userdata
 * @param L Lua 状态机指针
 * @param sz 大小（字节）
 * @return userdata 指针
 */
public func lua_newuserdata_cj(L: CPointer<Unit>, sz: UIntNative): CPointer<Unit> {
    unsafe {
        lua_newuserdata(L, sz)
    }
}

/**
 * @brief 获取元表
 * @param L Lua 状态机指针
 * @param objindex 对象索引
 * @return 1 表示有元表，0 表示没有
 */
public func lua_getmetatable_cj(L: CPointer<Unit>, objindex: Int32): Int32 {
    unsafe {
        lua_getmetatable(L, objindex)
    }
}

/**
 * @brief 获取环境表
 * @param L Lua 状态机指针
 * @param idx 索引
 */
public func lua_getfenv_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_getfenv(L, idx)
    }
}

// =============================================================================
// Set 函数（stack → Lua）
// =============================================================================

/**
 * @brief 设置表字段（键值在栈顶，表在 idx）
 * @param L Lua 状态机指针
 * @param idx 表的索引
 */
public func lua_settable_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_settable(L, idx)
    }
}

/**
 * @brief 按名称设置表字段
 * @param L Lua 状态机指针
 * @param idx 表的索引
 * @param k 字段名
 */
public func lua_setfield_cj(L: CPointer<Unit>, idx: Int32, k: CString): Unit {
    unsafe {
        lua_setfield(L, idx, k)
    }
}

/**
 * @brief 原始设置表字段
 * @param L Lua 状态机指针
 * @param idx 表的索引
 */
public func lua_rawset_cj(L: CPointer<Unit>, idx: Int32): Unit {
    unsafe {
        lua_rawset(L, idx)
    }
}

/**
 * @brief 原始按整数键设置表字段
 * @param L Lua 状态机指针
 * @param idx 表的索引
 * @param n 整数键
 */
public func lua_rawseti_cj(L: CPointer<Unit>, idx: Int32, n: Int32): Unit {
    unsafe {
        lua_rawseti(L, idx, n)
    }
}

/**
 * @brief 设置元表
 * @param L Lua 状态机指针
 * @param objindex 对象索引
 * @return 1 成功，0 失败
 */
public func lua_setmetatable_cj(L: CPointer<Unit>, objindex: Int32): Int32 {
    unsafe {
        lua_setmetatable(L, objindex)
    }
}

/**
 * @brief 设置环境表
 * @param L Lua 状态机指针
 * @param idx 索引
 * @return 1 成功，0 失败
 */
public func lua_setfenv_cj(L: CPointer<Unit>, idx: Int32): Int32 {
    unsafe {
        lua_setfenv(L, idx)
    }
}

// =============================================================================
// 加载与调用
// =============================================================================

/**
 * @brief 调用 Lua 函数
 * @param L Lua 状态机指针
 * @param nargs 参数个数
 * @param nresults 返回值个数（LUA_MULTRET 可变）
 */
public func lua_call_cj(L: CPointer<Unit>, nargs: Int32, nresults: Int32): Unit {
    unsafe {
        lua_call(L, nargs, nresults)
    }
}

/**
 * @brief 受保护调用 Lua 函数
 * @param L Lua 状态机指针
 * @param nargs 参数个数
 * @param nresults 返回值个数
 * @param errfunc 错误处理函数索引（0 表示无）
 * @return 状态码（LUA_OK 等）
 */
public func lua_pcall_cj(L: CPointer<Unit>, nargs: Int32, nresults: Int32, errfunc: Int32): Int32 {
    unsafe {
        lua_pcall(L, nargs, nresults, errfunc)
    }
}

/**
 * @brief 受保护调用 C 函数
 * @param L Lua 状态机指针
 * @param func C 函数
 * @param ud 用户数据
 * @return 状态码
 */
public func lua_cpcall_cj(L: CPointer<Unit>, `func`: CFunc<(CPointer<Unit>) -> Int32>, ud: CPointer<Unit>): Int32 {
    unsafe {
        lua_cpcall(L, `func`, ud)
    }
}

/**
 * @brief 加载 Lua 代码块
 * @param L Lua 状态机指针
 * @param reader 读取函数
 * @param dt 读取函数的用户数据
 * @param chunkname 代码块名称
 * @return 状态码
 */
public func lua_load_cj(L: CPointer<Unit>, reader: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<UIntNative>) -> CString>, dt: CPointer<Unit>, chunkname: CString): Int32 {
    unsafe {
        lua_load(L, reader, dt, chunkname)
    }
}

/**
 * @brief 转储 Lua 函数为字节码
 * @param L Lua 状态机指针
 * @param writer 写入函数
 * @param data 写入函数的用户数据
 * @return 状态码
 */
public func lua_dump_cj(L: CPointer<Unit>, writer: CFunc<(CPointer<Unit>, CPointer<Unit>, UIntNative, CPointer<Unit>) -> Int32>, data: CPointer<Unit>): Int32 {
    unsafe {
        lua_dump(L, writer, data)
    }
}

/**
 * @brief 加载 Lua 代码块（带模式控制，Lua 5.2+）
 * @param L Lua 状态机指针
 * @param reader 读取函数
 * @param dt 用户数据
 * @param chunkname 代码块名称
 * @param mode 模式（"b" 仅字节码，"t" 仅文本，"bt" 两者）
 * @return 状态码
 */
public func lua_loadx_cj(L: CPointer<Unit>, reader: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<UIntNative>) -> CString>, dt: CPointer<Unit>, chunkname: CString, mode: CString): Int32 {
    unsafe {
        lua_loadx(L, reader, dt, chunkname, mode)
    }
}

// =============================================================================
// 协程函数
// =============================================================================

/**
 * @brief 让出协程
 * @param L Lua 状态机指针
 * @param nresults 返回值个数
 * @return 状态码
 */
public func lua_yield_cj(L: CPointer<Unit>, nresults: Int32): Int32 {
    unsafe {
        lua_yield(L, nresults)
    }
}

/**
 * @brief 恢复协程
 * @param L Lua 状态机指针
 * @param narg 参数个数
 * @return 状态码
 */
public func lua_resume_cj(L: CPointer<Unit>, narg: Int32): Int32 {
    unsafe {
        lua_resume(L, narg)
    }
}

/**
 * @brief 获取线程状态
 * @param L Lua 状态机指针
 * @return 状态码
 */
public func lua_status_cj(L: CPointer<Unit>): Int32 {
    unsafe {
        lua_status(L)
    }
}

/**
 * @brief 检查协程是否可让出
 * @param L Lua 状态机指针
 * @return 1 可让出，0 不可让出
 */
public func lua_isyieldable_cj(L: CPointer<Unit>): Int32 {
    unsafe {
        lua_isyieldable(L)
    }
}

// =============================================================================
// GC 函数
// =============================================================================

/**
 * @brief 控制垃圾回收器
 * @param L Lua 状态机指针
 * @param what 操作码（GcOption 枚举值）
 * @param data 附加数据
 * @return 操作结果（依 what 不同而异）
 */
public func lua_gc_cj(L: CPointer<Unit>, what: Int32, data: Int32): Int32 {
    unsafe {
        lua_gc(L, what, data)
    }
}

// =============================================================================
// 杂项函数
// =============================================================================

/**
 * @brief 抛出错误（不返回）
 * @param L Lua 状态机指针
 * @return 不返回
 */
public func lua_error_cj(L: CPointer<Unit>): Int32 {
    unsafe {
        lua_error(L)
    }
}

/**
 * @brief 表遍历（用于 for 循环）
 * @param L Lua 状态机指针
 * @param idx 表的索引
 * @return 1 有更多元素，0 遍历结束
 */
public func lua_next_cj(L: CPointer<Unit>, idx: Int32): Int32 {
    unsafe {
        lua_next(L, idx)
    }
}

/**
 * @brief 连接栈顶 n 个值
 * @param L Lua 状态机指针
 * @param n 连接的值个数
 */
public func lua_concat_cj(L: CPointer<Unit>, n: Int32): Unit {
    unsafe {
        lua_concat(L, n)
    }
}

/**
 * @brief 获取内存分配函数
 * @param L Lua 状态机指针
 * @param ud 输出用户数据指针
 * @return 内存分配函数
 */
public func lua_getallocf_cj(L: CPointer<Unit>, ud: CPointer<CPointer<Unit>>): CFunc<(CPointer<Unit>, CPointer<Unit>, UIntNative, UIntNative) -> CPointer<Unit>> {
    unsafe {
        lua_getallocf(L, ud)
    }
}

/**
 * @brief 设置内存分配函数
 * @param L Lua 状态机指针
 * @param f 新的分配函数
 * @param ud 用户数据
 */
public func lua_setallocf_cj(L: CPointer<Unit>, f: CFunc<(CPointer<Unit>, CPointer<Unit>, UIntNative, UIntNative) -> CPointer<Unit>>, ud: CPointer<Unit>): Unit {
    unsafe {
        lua_setallocf(L, f, ud)
    }
}

/**
 * @brief 获取 Lua 版本号指针
 * @param L Lua 状态机指针（可为空）
 * @return 指向版本号的指针
 */
public func lua_version_cj(L: CPointer<Unit>): CPointer<Float64> {
    unsafe {
        lua_version(L)
    }
}

/**
 * @brief 复制栈元素
 * @param L Lua 状态机指针
 * @param fromidx 源索引
 * @param toidx 目标索引
 */
public func lua_copy_cj(L: CPointer<Unit>, fromidx: Int32, toidx: Int32): Unit {
    unsafe {
        lua_copy(L, fromidx, toidx)
    }
}

// =============================================================================
// Upvalue 操作
// =============================================================================

/**
 * @brief 获取 upvalue 的唯一标识
 * @param L Lua 状态机指针
 * @param idx 函数索引
 * @param n upvalue 编号（从 1 开始）
 * @return upvalue 标识指针
 */
public func lua_upvalueid_cj(L: CPointer<Unit>, idx: Int32, n: Int32): CPointer<Unit> {
    unsafe {
        lua_upvalueid(L, idx, n)
    }
}

/**
 * @brief 共享 upvalue
 * @param L Lua 状态机指针
 * @param idx1 第一个函数索引
 * @param n1 第一个 upvalue 编号
 * @param idx2 第二个函数索引
 * @param n2 第二个 upvalue 编号
 */
public func lua_upvaluejoin_cj(L: CPointer<Unit>, idx1: Int32, n1: Int32, idx2: Int32, n2: Int32): Unit {
    unsafe {
        lua_upvaluejoin(L, idx1, n1, idx2, n2)
    }
}

// =============================================================================
// 辅助库函数
// =============================================================================

/**
 * @brief 创建新的 Lua 状态机（使用默认内存分配器）
 * @return 新的 lua_State 指针
 */
public func luaL_newstate_cj(): CPointer<Unit> {
    unsafe {
        luaL_newstate()
    }
}

/**
 * @brief 打开所有标准库
 * @param L Lua 状态机指针
 */
public func luaL_openlibs_cj(L: CPointer<Unit>): Unit {
    unsafe {
        luaL_openlibs(L)
    }
}

/**
 * @brief 从文件加载 Lua 代码块
 * @param L Lua 状态机指针
 * @param filename 文件名
 * @return 状态码
 */
public func luaL_loadfile_cj(L: CPointer<Unit>, filename: CString): Int32 {
    unsafe {
        luaL_loadfile(L, filename)
    }
}

/**
 * @brief 从缓冲区加载 Lua 代码块
 * @param L Lua 状态机指针
 * @param buff 缓冲区指针
 * @param sz 缓冲区大小
 * @param name 代码块名称
 * @return 状态码
 */
public func luaL_loadbuffer_cj(L: CPointer<Unit>, buff: CString, sz: UIntNative, name: CString): Int32 {
    unsafe {
        luaL_loadbuffer(L, buff, sz, name)
    }
}

/**
 * @brief 从字符串加载 Lua 代码块
 * @param L Lua 状态机指针
 * @param s Lua 代码字符串
 * @return 状态码
 */
public func luaL_loadstring_cj(L: CPointer<Unit>, s: CString): Int32 {
    unsafe {
        luaL_loadstring(L, s)
    }
}

/**
 * @brief 从文件加载 Lua 代码块（带模式控制）
 * @param L Lua 状态机指针
 * @param filename 文件名
 * @param mode 模式（"b"/"t"/"bt"）
 * @return 状态码
 */
public func luaL_loadfilex_cj(L: CPointer<Unit>, filename: CString, mode: CString): Int32 {
    unsafe {
        luaL_loadfilex(L, filename, mode)
    }
}

/**
 * @brief 从缓冲区加载 Lua 代码块（带模式控制）
 * @param L Lua 状态机指针
 * @param buff 缓冲区指针
 * @param sz 缓冲区大小
 * @param name 代码块名称
 * @param mode 模式
 * @return 状态码
 */
public func luaL_loadbufferx_cj(L: CPointer<Unit>, buff: CString, sz: UIntNative, name: CString, mode: CString): Int32 {
    unsafe {
        luaL_loadbufferx(L, buff, sz, name, mode)
    }
}

/**
 * @brief 检查参数是否为字符串并返回
 * @param L Lua 状态机指针
 * @param numArg 参数位置
 * @param l 输出字符串长度
 * @return C 字符串指针
 */
public func luaL_checklstring_cj(L: CPointer<Unit>, numArg: Int32, l: CPointer<UIntNative>): CString {
    unsafe {
        luaL_checklstring(L, numArg, l)
    }
}

/**
 * @brief 可选字符串参数
 * @param L Lua 状态机指针
 * @param numArg 参数位置
 * @param def 默认值
 * @param l 输出字符串长度
 * @return C 字符串指针
 */
public func luaL_optlstring_cj(L: CPointer<Unit>, numArg: Int32, def: CString, l: CPointer<UIntNative>): CString {
    unsafe {
        luaL_optlstring(L, numArg, def, l)
    }
}

/**
 * @brief 检查参数是否为数值并返回
 * @param L Lua 状态机指针
 * @param numArg 参数位置
 * @return 数值
 */
public func luaL_checknumber_cj(L: CPointer<Unit>, numArg: Int32): Float64 {
    unsafe {
        luaL_checknumber(L, numArg)
    }
}

/**
 * @brief 可选数值参数
 * @param L Lua 状态机指针
 * @param nArg 参数位置
 * @param def 默认值
 * @return 数值
 */
public func luaL_optnumber_cj(L: CPointer<Unit>, nArg: Int32, def: Float64): Float64 {
    unsafe {
        luaL_optnumber(L, nArg, def)
    }
}

/**
 * @brief 检查参数是否为整数并返回
 * @param L Lua 状态机指针
 * @param numArg 参数位置
 * @return 整数值
 */
public func luaL_checkinteger_cj(L: CPointer<Unit>, numArg: Int32): Int64 {
    unsafe {
        luaL_checkinteger(L, numArg)
    }
}

/**
 * @brief 可选整数参数
 * @param L Lua 状态机指针
 * @param nArg 参数位置
 * @param def 默认值
 * @return 整数值
 */
public func luaL_optinteger_cj(L: CPointer<Unit>, nArg: Int32, def: Int64): Int64 {
    unsafe {
        luaL_optinteger(L, nArg, def)
    }
}

/**
 * @brief 确保栈空间
 * @param L Lua 状态机指针
 * @param sz 需要的额外空间
 * @param msg 错误消息
 */
public func luaL_checkstack_cj(L: CPointer<Unit>, sz: Int32, msg: CString): Unit {
    unsafe {
        luaL_checkstack(L, sz, msg)
    }
}

/**
 * @brief 检查参数类型
 * @param L Lua 状态机指针
 * @param narg 参数位置
 * @param t 期望的类型码
 */
public func luaL_checktype_cj(L: CPointer<Unit>, narg: Int32, t: Int32): Unit {
    unsafe {
        luaL_checktype(L, narg, t)
    }
}

/**
 * @brief 检查参数存在（任意类型）
 * @param L Lua 状态机指针
 * @param narg 参数位置
 */
public func luaL_checkany_cj(L: CPointer<Unit>, narg: Int32): Unit {
    unsafe {
        luaL_checkany(L, narg)
    }
}

/**
 * @brief 创建或获取元表
 * @param L Lua 状态机指针
 * @param tname 类型名称
 * @return 1 表示新创建，0 表示已存在
 */
public func luaL_newmetatable_cj(L: CPointer<Unit>, tname: CString): Int32 {
    unsafe {
        luaL_newmetatable(L, tname)
    }
}

/**
 * @brief 检查参数是否为指定类型的 userdata
 * @param L Lua 状态机指针
 * @param ud 参数位置
 * @param tname 类型名称
 * @return userdata 指针
 */
public func luaL_checkudata_cj(L: CPointer<Unit>, ud: Int32, tname: CString): CPointer<Unit> {
    unsafe {
        luaL_checkudata(L, ud, tname)
    }
}

/**
 * @brief 创建引用
 * @param L Lua 状态机指针
 * @param t 表索引
 * @return 引用编号
 */
public func luaL_ref_cj(L: CPointer<Unit>, t: Int32): Int32 {
    unsafe {
        luaL_ref(L, t)
    }
}

/**
 * @brief 释放引用
 * @param L Lua 状态机指针
 * @param t 表索引
 * @param ref 引用编号
 */
public func luaL_unref_cj(L: CPointer<Unit>, t: Int32, ref: Int32): Unit {
    unsafe {
        luaL_unref(L, t, ref)
    }
}

/**
 * @brief 生成追踪回溯
 * @param L Lua 状态机指针
 * @param L1 目标线程
 * @param msg 消息前缀
 * @param level 起始层级
 */
public func luaL_traceback_cj(L: CPointer<Unit>, L1: CPointer<Unit>, msg: CString, level: Int32): Unit {
    unsafe {
        luaL_traceback(L, L1, msg, level)
    }
}

/**
 * @brief 设置函数库
 * @param L Lua 状态机指针
 * @param l 函数列表指针
 * @param nup 共享 upvalue 数量
 */
public func luaL_setfuncs_cj(L: CPointer<Unit>, l: CPointer<Unit>, nup: Int32): Unit {
    unsafe {
        luaL_setfuncs(L, l, nup)
    }
}

/**
 * @brief 设置元表
 * @param L Lua 状态机指针
 * @param tname 类型名称
 */
public func luaL_setmetatable_cj(L: CPointer<Unit>, tname: CString): Unit {
    unsafe {
        luaL_setmetatable(L, tname)
    }
}

// =============================================================================
// Debug API
// =============================================================================

/**
 * @brief 获取调用栈信息
 * @param L Lua 状态机指针
 * @param level 层级
 * @param ar Debug 激活记录指针
 * @return 1 成功，0 失败
 */
public func lua_getstack_cj(L: CPointer<Unit>, level: Int32, ar: CPointer<Unit>): Int32 {
    unsafe {
        lua_getstack(L, level, ar)
    }
}

/**
 * @brief 获取调试信息
 * @param L Lua 状态机指针
 * @param what 查询选项字符串
 * @param ar Debug 激活记录指针
 * @return 1 成功，0 失败
 */
public func lua_getinfo_cj(L: CPointer<Unit>, what: CString, ar: CPointer<Unit>): Int32 {
    unsafe {
        lua_getinfo(L, what, ar)
    }
}

/**
 * @brief 获取局部变量信息
 * @param L Lua 状态机指针
 * @param ar Debug 激活记录指针
 * @param n 局部变量编号
 * @return 变量名
 */
public func lua_getlocal_cj(L: CPointer<Unit>, ar: CPointer<Unit>, n: Int32): CString {
    unsafe {
        lua_getlocal(L, ar, n)
    }
}

/**
 * @brief 设置局部变量
 * @param L Lua 状态机指针
 * @param ar Debug 激活记录指针
 * @param n 局部变量编号
 * @return 变量名
 */
public func lua_setlocal_cj(L: CPointer<Unit>, ar: CPointer<Unit>, n: Int32): CString {
    unsafe {
        lua_setlocal(L, ar, n)
    }
}

/**
 * @brief 获取 upvalue 名称
 * @param L Lua 状态机指针
 * @param funcindex 函数索引
 * @param n upvalue 编号
 * @return upvalue 名称
 */
public func lua_getupvalue_cj(L: CPointer<Unit>, funcindex: Int32, n: Int32): CString {
    unsafe {
        lua_getupvalue(L, funcindex, n)
    }
}

/**
 * @brief 设置 upvalue
 * @param L Lua 状态机指针
 * @param funcindex 函数索引
 * @param n upvalue 编号
 * @return upvalue 名称
 */
public func lua_setupvalue_cj(L: CPointer<Unit>, funcindex: Int32, n: Int32): CString {
    unsafe {
        lua_setupvalue(L, funcindex, n)
    }
}

/**
 * @brief 设置钩子函数
 * @param L Lua 状态机指针
 * @param func 钩子函数
 * @param mask 事件掩码
 * @param count 计数触发间隔
 * @return 1 成功，0 失败
 */
public func lua_sethook_cj(L: CPointer<Unit>, `func`: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Unit>, mask: Int32, count: Int32): Int32 {
    unsafe {
        lua_sethook(L, `func`, mask, count)
    }
}

/**
 * @brief 获取当前钩子函数
 * @param L Lua 状态机指针
 * @return 钩子函数
 */
public func lua_gethook_cj(L: CPointer<Unit>): CFunc<(CPointer<Unit>, CPointer<Unit>) -> Unit> {
    unsafe {
        lua_gethook(L)
    }
}

/**
 * @brief 获取当前钩子掩码
 * @param L Lua 状态机指针
 * @return 钩子掩码
 */
public func lua_gethookmask_cj(L: CPointer<Unit>): Int32 {
    unsafe {
        lua_gethookmask(L)
    }
}

/**
 * @brief 获取当前钩子计数
 * @param L Lua 状态机指针
 * @return 钩子计数
 */
public func lua_gethookcount_cj(L: CPointer<Unit>): Int32 {
    unsafe {
        lua_gethookcount(L)
    }
}

// =============================================================================
// 标准库打开函数
// =============================================================================

/** @brief 打开基础库 */
public func luaopen_base_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_base(L) }
}

/** @brief 打开数学库 */
public func luaopen_math_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_math(L) }
}

/** @brief 打开字符串库 */
public func luaopen_string_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_string(L) }
}

/** @brief 打开表库 */
public func luaopen_table_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_table(L) }
}

/** @brief 打开 I/O 库 */
public func luaopen_io_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_io(L) }
}

/** @brief 打开 OS 库 */
public func luaopen_os_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_os(L) }
}

/** @brief 打开包管理库 */
public func luaopen_package_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_package(L) }
}

/** @brief 打开调试库 */
public func luaopen_debug_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_debug(L) }
}

/** @brief 打开位操作库 */
public func luaopen_bit_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_bit(L) }
}

/** @brief 打开 JIT 控制库 */
public func luaopen_jit_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_jit(L) }
}

/** @brief 打开 FFI 库 */
public func luaopen_ffi_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_ffi(L) }
}

/** @brief 打开字符串缓冲区库 */
public func luaopen_string_buffer_cj(L: CPointer<Unit>): Int32 {
    unsafe { luaopen_string_buffer(L) }
}

// =============================================================================
// LuaJIT 扩展 API
// =============================================================================

/**
 * @brief 控制 JIT 引擎
 * @param L Lua 状态机指针
 * @param idx 函数索引（仅 LUAJIT_MODE_FUNC/ALLFUNC/ALLSUBFUNC 需要）
 * @param mode 模式（JitMode 枚举 | JitModeFlag 标志）
 * @return 成功返回 0，失败返回 -1
 */
public func luaJIT_setmode_cj(L: CPointer<Unit>, idx: Int32, mode: Int32): Int32 {
    unsafe {
        luaJIT_setmode(L, idx, mode)
    }
}

/**
 * @brief 启动低开销性能分析
 * @param L Lua 状态机指针
 * @param mode 分析模式字符串（"l"/"f"/"2" 等）
 * @param cb 回调函数
 * @param data 用户数据
 */
public func luaJIT_profile_start_cj(L: CPointer<Unit>, mode: CString, cb: CFunc<(CPointer<Unit>, CPointer<Unit>, Int32, Int32) -> Unit>, data: CPointer<Unit>): Unit {
    unsafe {
        luaJIT_profile_start(L, mode, cb, data)
    }
}

/**
 * @brief 停止性能分析
 * @param L Lua 状态机指针
 */
public func luaJIT_profile_stop_cj(L: CPointer<Unit>): Unit {
    unsafe {
        luaJIT_profile_stop(L)
    }
}

/**
 * @brief 转储当前栈信息
 * @param L Lua 状态机指针
 * @param fmt 格式字符串
 * @param depth 栈深度
 * @param len 输出长度指针
 * @return 栈信息字符串
 */
public func luaJIT_profile_dumpstack_cj(L: CPointer<Unit>, fmt: CString, depth: Int32, len: CPointer<UIntNative>): CString {
    unsafe {
        luaJIT_profile_dumpstack(L, fmt, depth, len)
    }
}
