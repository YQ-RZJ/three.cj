/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] LuaClassBinder 引擎类绑定引擎（three.script.binding 子包）
 * @brief[zh-cn] 将仓颉类绑定为 Lua 类型：构造、实例方法、实例属性、静态方法
 * @explain[zh-cn] 在 LuaBinder（自由函数）之上提供"对象级"绑定能力：
 * - defineClass：声明绑定类，install 到目标 VM；
 * - constructor / method / staticMethod / property 四类注册；
 * - 每个类在 Lua 注册表持有具名 metatable（键 = 绑定类名）；
 * - 对象以 full userdata 承载注册表 id（见 LuaObjectRegistry），__gc 清理条目；
 * - metatable.__index = 分派函数：先属性 getter，再回退类方法闭包；
 *   __newindex = 分派函数：属性 setter；非属性写失败。
 * - CFunc 回调不允许捕获变量：每个方法/静态/构造分配全局唯一 handle id，
 *   C 闭包 upvalue 携带该 id，分派时按 id 查全局注册表取回调。
 * @example[zh-cn] 绑定 Vector3 的核心操作
 * let vb = LuaClassBinder.defineClass(vm, "three.core.math.Vector3")
 * vb.constructor { args -> Vector3(args[0].numberValue(), args[1].numberValue(), args[2].numberValue()) }
 * vb.method("set") { (ref, args) ->
 *     let v = ref.as<Vector3>()
 *     v.set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
 *     [LuaValue.Object(ref.id)]     // 链式返回自身
 * }
 * vb.property("x", ...)
 * vb.install(vm)
 *
 * @file[en] LuaClassBinder  Engine class binding engine (three.script.binding sub-package)
 * @brief[en] Binds Cangjie classes as Lua types: constructors, instance methods,
 *            instance properties and static methods
 * @explain[en] Provides "object-level" binding on top of LuaBinder (free functions):
 * - defineClass: declares a bound class, then install() writes it into a target VM;
 * - four registration kinds: constructor / method / staticMethod / property;
 * - every class holds a named metatable in the Lua registry (key = bound class name);
 * - objects are full userdata carrying the registry id (see LuaObjectRegistry);
 *   __gc clears the registry entry;
 * - metatable.__index dispatches property getters first, then falls back to method
 *   closures; __newindex dispatches property setters.
 * - C closures cannot capture: every method/static/ctor gets a globally unique
 *   handle id; the closure's upvalue carries it and dispatch looks up global tables.
 * @example[en] Binding core operations of Vector3
 * let vb = LuaClassBinder.defineClass(vm, "three.core.math.Vector3")
 * vb.constructor { args -> Vector3(args[0].numberValue(), args[1].numberValue(), args[2].numberValue()) }
 * vb.method("set") { (ref, args) ->
 *     let v = ref.as<Vector3>()
 *     v.set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
 *     [LuaValue.Object(ref.id)]
 * }
 * vb.property("x", ...)
 * vb.install(vm)
 */
package three.script.binding

import std.collection.*
import luajit4cj.luajit.*
import three.script.vm.*

// =============================================================================
// 类型别名
// =============================================================================

/**
 * @brief[zh-cn] 实例方法回调签名
 * @explain[zh-cn] ref 携带对象 id 与真实对象（ref.as<T>()），args 为请求参数（不含 self）。
 *
 * @brief[en] Instance method callback signature
 * @explain[en] ref carries the object id and the real object (ref.as<T>()); args are the
 * request arguments (excluding self).
 */
public type LuaMethodFn = (LuaObjectRef, Array<LuaValue>) -> Array<LuaValue>

/**
 * @brief[zh-cn] 静态方法回调签名
 * @explain[zh-cn] args 为全部请求参数。
 *
 * @brief[en] Static method callback signature
 * @explain[en] args are all request arguments.
 */
public type LuaStaticFn = (Array<LuaValue>) -> Array<LuaValue>

/**
 * @brief[zh-cn] 构造回调签名
 * @explain[zh-cn] 由 Lua 参数创建仓颉对象。
 *
 * @brief[en] Constructor callback signature
 * @explain[en] Creates a Cangjie object from Lua arguments.
 */
public type LuaCtorFn = (Array<LuaValue>) -> Any

/**
 * @brief[zh-cn] 属性 getter 回调签名
 * @explain[zh-cn] 由对象引用取值。
 *
 * @brief[en] Property getter callback signature
 * @explain[en] Reads a value from an object reference.
 */
public type LuaGetterFn = (LuaObjectRef) -> LuaValue

/**
 * @brief[zh-cn] 属性 setter 回调签名
 * @explain[zh-cn] 向对象引用写值。
 *
 * @brief[en] Property setter callback signature
 * @explain[en] Writes a value to an object reference.
 */
public type LuaSetterFn = (LuaObjectRef, LuaValue) -> Unit

// =============================================================================
// 元数据记录（分派按 handle id 查表取回调）
// =============================================================================

private class MethodMeta {
    var clsId: Int64
    var clsName: String
    var name: String
    var fn: LuaMethodFn

    init(clsId: Int64, clsName: String, name: String, fn: LuaMethodFn) {
        this.clsId = clsId
        this.clsName = clsName
        this.name = name
        this.fn = fn
    }
}

private class StaticMeta {
    var clsId: Int64
    var clsName: String
    var name: String
    var fn: LuaStaticFn

    init(clsId: Int64, clsName: String, name: String, fn: LuaStaticFn) {
        this.clsId = clsId
        this.clsName = clsName
        this.name = name
        this.fn = fn
    }
}

private class CtorMeta {
    var clsId: Int64
    var clsName: String
    var fn: LuaCtorFn

    init(clsId: Int64, clsName: String, fn: LuaCtorFn) {
        this.clsId = clsId
        this.clsName = clsName
        this.fn = fn
    }
}

/** 类元数据（保留：属性表与类名；方法经 handle id 查全局） */
private class ClassMeta {
    var id: Int64
    var name: String
    var hasCtor: Bool = false
    var propGetters: HashMap<String, LuaGetterFn> = HashMap()
    var propSetters: HashMap<String, LuaSetterFn> = HashMap()

    init(id: Int64, name: String) {
        this.id = id
        this.name = name
    }
}

// =============================================================================
// 全局注册表
// =============================================================================

private var _nextClassId: Int64 = 1
private var _classes: HashMap<Int64, ClassMeta> = HashMap()
private var _classByName: HashMap<String, Int64> = HashMap()

private var _nextMethodId: Int64 = 1
private var _methods: HashMap<Int64, MethodMeta> = HashMap()

private var _nextStaticId: Int64 = 1
private var _statics: HashMap<Int64, StaticMeta> = HashMap()

private var _nextCtorId: Int64 = 1
private var _ctors: HashMap<Int64, CtorMeta> = HashMap()

/// upvalue 索引 1（lua_upvalueindex(1) = LUA_GLOBALSINDEX - 1）
private let _UPV1: Int32 = -10003

// =============================================================================
// C 字符串工具（binding 包私有；LuaBinder 沿用 unsafe LibC 惯例）
// =============================================================================

private func _cjStr(s: String): CString {
    unsafe { LibC.mallocCString(s) }
}

private func _cjFree(cs: CString): Unit {
    unsafe { LibC.free(cs) }
}

// =============================================================================
// LuaObjectRef：对象引用
// =============================================================================

/**
 * @brief[zh-cn] 引擎对象引用（方法/属性回调的 self）
 * @explain[zh-cn] 携带对象注册表 id；obj() 返回 Any，cast<T>() 返回强转后的真实对象。
 *
 * @brief[en] Engine object reference (self in method/property callbacks)
 * @explain[en] Carries the object registry id; obj() returns Any and cast<T>() returns
 * the cast real object.
 */
public class LuaObjectRef {
    private var _id: Int64

    internal init(id: Int64) {
        this._id = id
    }

    /**
     * @brief[zh-cn] 对象注册表 id
     *
     * @brief[en] The object registry id
     */
    public prop id: Int64 {
        get() { this._id }
    }

    /**
     * @brief[zh-cn] 取回真实对象（Any）
     * @return[zh-cn] 注册表保存的仓颉对象
     * @throws[zh-cn] Exception 对象已移除时抛出
     *
     * @brief[en] Fetches the real object (Any)
     * @return[en] The Cangjie object stored in the registry
     * @throws[en] Exception Thrown when the object has been removed
     */
    public func obj(): Any {
        return LuaObjectRegistry.get(this._id).getOrThrow()
    }

    /**
     * @brief[zh-cn] 取回真实对象并强转为 T
     * @throws[zh-cn] Exception 类型不匹配或对象缺失时抛出
     *
     * @brief[en] Fetches the real object and casts it to T
     * @throws[en] Exception Thrown when the type does not match or the object is missing
     */
    public func cast<T>(): T {
        return LuaObjectRegistry.getAs<T>(this._id)
    }
}

// =============================================================================
// LuaClassBinder：类绑定引擎（链式构建器）
// =============================================================================

/**
 * @brief[zh-cn] 仓颉类 → Lua 类型绑定引擎
 * @explain[zh-cn] 链式注册构造/方法/静态方法/属性，最后 install(targetVm) 写入 Lua。
 *
 * @brief[en] Cangjie class → Lua type binding engine
 * @explain[en] Fluent registration of constructors/methods/static methods/properties,
 * finally install(targetVm) writes the class into Lua.
 */
public class LuaClassBinder {
    private var _meta: ClassMeta

    private init(meta: ClassMeta) {
        this._meta = meta
    }

    /**
     * @brief[zh-cn] 声明绑定类（同名类只允许一次）
     * @param[zh-cn] vm 目标虚拟机（触发对象桥接安装）
     * @param[zh-cn] name 绑定类名（同时作为注册表 metatable 键，如 "three.core.math.Vector3"）
     * @return[zh-cn] 类绑定器（链式注册）
     * @throws[zh-cn] Exception 同名类重复注册时抛出
     *
     * @brief[en] Declares a bound class (a name may be used only once)
     * @param[en] vm The target virtual machine (triggers object-bridge installation)
     * @param[en] name The bound class name (also the registry metatable key, e.g. "three.core.math.Vector3")
     * @return[en] The class binder for fluent registration
     * @throws[en] Exception Thrown when the class name is already registered
     */
    public static func defineClass(vm: LuaVM, name: String): LuaClassBinder {
        LuaObjectRegistry.installBridge()
        if (_classByName.contains(name)) {
            throw Exception("LuaClassBinder: duplicate class name: ${name}")
        }
        let id = _nextClassId
        _nextClassId += 1
        let meta = ClassMeta(id, name)
        _classes[id] = meta
        _classByName[name] = id
        return LuaClassBinder(meta)
    }

    /**
     * @brief[zh-cn] 注册构造回调（生成 Lua 侧类表.new）
     * @param[zh-cn] fn 由 Lua 参数创建仓颉对象的回调
     * @return[zh-cn] 当前绑定器
     *
     * @brief[en] Registers the constructor callback (creates Lua-side ClassTable.new)
     * @param[en] fn The callback creating a Cangjie object from Lua arguments
     * @return[en] The current binder
     */
    public func constructor(fn: LuaCtorFn): LuaClassBinder {
        let id = _nextCtorId
        _nextCtorId += 1
        _ctors[id] = CtorMeta(this._meta.id, this._meta.name, fn)
        this._meta.hasCtor = true
        return this
    }

    /**
     * @brief[zh-cn] 注册实例方法（metatable 上一等函数，经 __index 命中）
     * @param[zh-cn] name Lua 侧方法名
     * @param[zh-cn] fn 方法回调（self 经 LuaObjectRef 传入，args 不含 self）
     * @return[zh-cn] 当前绑定器
     *
     * @brief[en] Registers an instance method (a first-class function on the metatable, hit via __index)
     * @param[en] name The Lua-side method name
     * @param[en] fn The method callback (self is passed as LuaObjectRef; args exclude self)
     * @return[en] The current binder
     */
    public func method(name: String, fn: LuaMethodFn): LuaClassBinder {
        let id = _nextMethodId
        _nextMethodId += 1
        _methods[id] = MethodMeta(this._meta.id, this._meta.name, name, fn)
        return this
    }

    /**
     * @brief[zh-cn] 注册静态方法（挂在类命名空间表上）
     * @param[zh-cn] name Lua 侧方法名
     * @param[zh-cn] fn 静态回调（args 为全部请求参数）
     * @return[zh-cn] 当前绑定器
     *
     * @brief[en] Registers a static method (attached to the class namespace table)
     * @param[en] name The Lua-side method name
     * @param[en] fn The static callback (args are all request arguments)
     * @return[en] The current binder
     */
    public func staticMethod(name: String, fn: LuaStaticFn): LuaClassBinder {
        let id = _nextStaticId
        _nextStaticId += 1
        _statics[id] = StaticMeta(this._meta.id, this._meta.name, name, fn)
        return this
    }

    /**
     * @brief[zh-cn] 注册属性（经 __index/__newindex 分派，支持 obj.x 读写）
     * @param[zh-cn] name Lua 侧属性名
     * @param[zh-cn] getter 取值回调（可空；为空则该属性只读不可用）
     * @param[zh-cn] setter 写值回调（可空；为空则该属性只写不可用）
     * @return[zh-cn] 当前绑定器
     *
     * @brief[en] Registers a property (dispatched via __index/__newindex, supporting obj.x read/write)
     * @param[en] name The Lua-side property name
     * @param[en] getter The getter callback (optional; read unavailable when absent)
     * @param[en] setter The setter callback (optional; write unavailable when absent)
     * @return[en] The current binder
     */
    public func property(name: String, getter!: Option<LuaGetterFn> = None,
                         setter!: Option<LuaSetterFn> = None): LuaClassBinder {
        if (let Some(g) <- getter) {
            this._meta.propGetters[name] = g
        }
        if (let Some(s) <- setter) {
            this._meta.propSetters[name] = s
        }
        return this
    }

    // =========================================================================
    // install —— 将类写入目标 VM
    // =========================================================================

    /**
     * @brief[zh-cn] 将当前类安装到目标 VM
     * @explain[zh-cn] 执行动作：
     * 1. luaL_newmetatable(键=绑定类名) 创建/复用类型元表；
     * 2. 元表写入 __tostring、__index（属性+方法双查）、__newindex（属性写）、__gc；
     * 3. 实例方法闭包直接挂到元表（方法名 → C 闭包，upvalue=methodId）；
     * 4. 创建全局命名空间表 three.<pkg...>.<Class>，挂构造(new)与静态方法。
     * @param[zh-cn] vm 目标虚拟机
     *
     * @brief[en] Installs the current class into the target VM
     * @explain[en] Performs:
     * 1. luaL_newmetatable(key=class name) creates/reuses the type metatable;
     * 2. writes __tostring, __index (property+method lookup), __newindex (property write), __gc;
     * 3. attaches instance-method closures to the metatable (method name → C closure, upvalue=methodId);
     * 4. creates the global namespace table three.<pkg...>.<Class> with constructor (new) and statics.
     * @param[en] vm The target virtual machine
     */
    public func install(vm: LuaVM): Unit {
        let L = vm.handle()
        if (L.isNull()) { return }
        let clsId = this._meta.id

        // 1. metatable
        let csName = _cjStr(this._meta.name)
        luaL_newmetatable_cj(L, csName)
        _cjFree(csName)

        // 2. __tostring：classId 缓存于 upvalue
        lua_pushinteger_cj(L, clsId)
        let toCf: CFunc<(CPointer<Unit>) -> Int32> = { L2 => _dispatchToString(L2) }
        lua_pushcclosure_cj(L, toCf, 1)
        let csTs = _cjStr("__tostring")
        lua_setfield_cj(L, -2, csTs)
        _cjFree(csTs)

        // 3. __index
        lua_pushinteger_cj(L, clsId)
        let idxCf: CFunc<(CPointer<Unit>) -> Int32> = { L2 => _dispatchIndex(L2) }
        lua_pushcclosure_cj(L, idxCf, 1)
        let csIdx = _cjStr("__index")
        lua_setfield_cj(L, -2, csIdx)
        _cjFree(csIdx)

        // 4. __newindex
        lua_pushinteger_cj(L, clsId)
        let nidxCf: CFunc<(CPointer<Unit>) -> Int32> = { L2 => _dispatchNewIndex(L2) }
        lua_pushcclosure_cj(L, nidxCf, 1)
        let csNidx = _cjStr("__newindex")
        lua_setfield_cj(L, -2, csNidx)
        _cjFree(csNidx)

        // 5. __gc
        let gcCf: CFunc<(CPointer<Unit>) -> Int32> = { L2 => _dispatchGc(L2) }
        lua_pushcclosure_cj(L, gcCf, 0)
        let csGc = _cjStr("__gc")
        lua_setfield_cj(L, -2, csGc)
        _cjFree(csGc)

        // 6. 实例方法闭包挂到 metatable（栈顶 metatable 在 -1）
        for ((mId, m) in _methods) {
            if (m.clsId == clsId) {
                lua_pushinteger_cj(L, mId)
                let cf: CFunc<(CPointer<Unit>) -> Int32> = { L2 => _dispatchMethod(L2) }
                lua_pushcclosure_cj(L, cf, 1)
                let csM = _cjStr(m.name)
                lua_setfield_cj(L, -2, csM)
                _cjFree(csM)
                lua_settop_cj(L, 1)
            }
        }

        // 7. 清栈，构建类命名空间表（metatable 已由 luaL_newmetatable 挂到注册表）
        lua_settop_cj(L, 0)

        // 构建 three.<parts> 类表
        let ok = _buildNamespaceTable(L, this._meta.name)
        if (ok) {
            // 类表在栈顶；写 new / 静态方法 / __className
            if (this._meta.hasCtor) {
                let cId = _findCtorId(clsId)
                if (cId != 0) {
                    lua_pushinteger_cj(L, cId)
                    let cf: CFunc<(CPointer<Unit>) -> Int32> = { L2 => _dispatchCtor(L2) }
                    lua_pushcclosure_cj(L, cf, 1)
                    let csNew = _cjStr("new")
                    lua_setfield_cj(L, -2, csNew)
                    _cjFree(csNew)
                }
            }
            for ((sId, s) in _statics) {
                if (s.clsId == clsId) {
                    lua_pushinteger_cj(L, sId)
                    let cf: CFunc<(CPointer<Unit>) -> Int32> = { L2 => _dispatchStatic(L2) }
                    lua_pushcclosure_cj(L, cf, 1)
                    let csS = _cjStr(s.name)
                    lua_setfield_cj(L, -2, csS)
                    _cjFree(csS)
                }
            }
            let csCn = _cjStr("__className")
            lua_pushstring_cj(L, _cjStr(this._meta.name))
            lua_setfield_cj(L, -2, csCn)
            _cjFree(csCn)
            lua_settop_cj(L, 0)
        } else {
            lua_settop_cj(L, 0)
        }
    }

    // =========================================================================
    // C 分派函数（CFunc，无捕获 —— 全部经 upvalue handle id 查全局表）
    // =========================================================================

    /// 实例方法分派
    private static func _dispatchMethod(L: CPointer<Unit>): Int32 {
        let mId = lua_tointeger_cj(L, _UPV1)
        let m = _methods.get(mId)
        if (let Some(meta) <- m) {
            let selfId = LuaObjectRegistry._readId(L, 1)
            if (selfId == 0) {
                return _pushError(L, "method ${meta.clsName}.${meta.name}: bad self")
            }
            let nargs = lua_gettop_cj(L)
            let args = Array<LuaValue>(Int64(nargs - 1), { _ => LuaValue.Nil })
            for (i in 1..nargs) {
                args[Int64(i - 1)] = LuaVM.readValue(L, i + 1)
            }
            let ref = LuaObjectRef(selfId)
            return _runAndPush(L) { meta.fn(ref, args) }
        }
        return _pushError(L, "method handler not registered (id=${mId})")
    }

    /// 静态方法分派
    private static func _dispatchStatic(L: CPointer<Unit>): Int32 {
        let sId = lua_tointeger_cj(L, _UPV1)
        let s = _statics.get(sId)
        if (let Some(meta) <- s) {
            let nargs = lua_gettop_cj(L)
            let args = Array<LuaValue>(Int64(nargs), { _ => LuaValue.Nil })
            for (i in 0..nargs) {
                args[Int64(i)] = LuaVM.readValue(L, i + 1)
            }
            return _runAndPush(L) { meta.fn(args) }
        }
        return _pushError(L, "static handler not registered (id=${sId})")
    }

    /// 构造分派（类表.new）
    private static func _dispatchCtor(L: CPointer<Unit>): Int32 {
        let cId = lua_tointeger_cj(L, _UPV1)
        let c = _ctors.get(cId)
        if (let Some(meta) <- c) {
            let nargs = lua_gettop_cj(L)
            let args = Array<LuaValue>(Int64(nargs), { _ => LuaValue.Nil })
            for (i in 0..nargs) {
                args[Int64(i)] = LuaVM.readValue(L, i + 1)
            }
            try {
                let obj = meta.fn(args)
                let id = LuaObjectRegistry.register(obj, meta.clsName)
                LuaVM.pushValue(L, LuaValue.Object(id))
                return 1
            } catch (e: Exception) {
                return _pushError(L, "constructor ${meta.clsName}: ${e.message}")
            }
        }
        return _pushError(L, "ctor handler not registered (id=${cId})")
    }

    /// __index：属性 getter → 无则回退类方法（方法闭包挂在 metatable 上，rawget 命中）
    private static func _dispatchIndex(L: CPointer<Unit>): Int32 {
        let clsId = lua_tointeger_cj(L, _UPV1)
        let meta = _classes.get(clsId)
        let keyOpt = _readKeyString(L, 2)
        if (let Some(m) <- meta) {
            if (let Some(key) <- keyOpt) {
                if (m.propGetters.contains(key)) {
                    let g = m.propGetters.get(key).getOrThrow()
                    let selfId = LuaObjectRegistry._readId(L, 1)
                    if (selfId == 0) {
                        return _pushError(L, "getter ${m.name}.${key}: bad self")
                    }
                    let ref = LuaObjectRef(selfId)
                    try {
                        let v = g(ref)
                        LuaVM.pushValue(L, v)
                        return 1
                    } catch (e: Exception) {
                        return _pushError(L, "getter ${m.name}.${key}: ${e.message}")
                    }
                }
                // 方法回退：取 metatable，压 key 后 rawget → t[key]
                if (lua_getmetatable_cj(L, 1) != 0) {
                    let csKey = _cjStr(key)
                    lua_pushstring_cj(L, csKey)
                    _cjFree(csKey)
                    lua_rawget_cj(L, -2)
                    if (lua_type_cj(L, -1) != LUA_TNIL) {
                        return 1
                    }
                    lua_settop_cj(L, -2)
                }
                lua_pushnil_cj(L)
                return 1
            }
            lua_pushnil_cj(L)
            return 1
        }
        lua_pushnil_cj(L)
        return 1
    }

    /// __newindex：属性 setter；非属性写失败
    private static func _dispatchNewIndex(L: CPointer<Unit>): Int32 {
        let clsId = lua_tointeger_cj(L, _UPV1)
        let meta = _classes.get(clsId)
        let keyOpt = _readKeyString(L, 2)
        if (let Some(m) <- meta) {
            if (let Some(key) <- keyOpt) {
                if (m.propSetters.contains(key)) {
                    let s = m.propSetters.get(key).getOrThrow()
                    let selfId = LuaObjectRegistry._readId(L, 1)
                    if (selfId == 0) {
                        return _pushError(L, "setter ${m.name}.${key}: bad self")
                    }
                    let ref = LuaObjectRef(selfId)
                    let v = LuaVM.readValue(L, 3)
                    try {
                        s(ref, v)
                        return 0
                    } catch (e: Exception) {
                        return _pushError(L, "setter ${m.name}.${key}: ${e.message}")
                    }
                }
                return _pushError(L, "property ${m.name}.${key}: no setter bound")
            }
            return _pushError(L, "__newindex: non-string key on bound object")
        }
        return _pushError(L, "class not registered (id=${clsId})")
    }

    /// __gc：清理对象注册表条目
    private static func _dispatchGc(L: CPointer<Unit>): Int32 {
        let id = LuaObjectRegistry._readId(L, 1)
        if (id != 0) {
            LuaObjectRegistry.unregister(id)
        }
        return 0
    }

    /// __tostring
    private static func _dispatchToString(L: CPointer<Unit>): Int32 {
        let clsId = lua_tointeger_cj(L, _UPV1)
        let meta = _classes.get(clsId)
        let id = LuaObjectRegistry._readId(L, 1)
        let name = if (let Some(m) <- meta) { m.name } else { "unknown" }
        let msg = "(${name}:id=${id})"
        let cs = _cjStr(msg)
        lua_pushstring_cj(L, cs)
        _cjFree(cs)
        return 1
    }

    // =========================================================================
    // 构建辅助
    // =========================================================================

    /// 按 clsId 找 ctor handle id（首项命中）
    private static func _findCtorId(clsId: Int64): Int64 {
        for ((id, c) in _ctors) {
            if (c.clsId == clsId) {
                return id
            }
        }
        return 0
    }

    /**
     * @brief[zh-cn] 构建 three.<pkg...>.<Class> 命名空间表
     * @explain[zh-cn] name 形如 "three.core.math.Vector3"：确保 global.three 存在，
     * 从第二个分段起逐级创建包表（跳过首段 "three"），最后一段为类表并留在栈顶。
     * @return[zh-cn] 成功返回 true（类表在栈顶）；失败返回 false（已清栈）
     */
    private static func _buildNamespaceTable(L: CPointer<Unit>, name: String): Bool {
        let parts = name.split(".")
        if (parts.size < 2) { return false }

        // 确保 global.three 存在（栈底元素 = global.three）
        let cs3a = _cjStr("three")
        lua_getfield_cj(L, LUA_GLOBALSINDEX, cs3a)
        _cjFree(cs3a)
        if (lua_type_cj(L, -1) != LUA_TTABLE) {
            lua_settop_cj(L, 0)
            lua_createtable_cj(L, 0, 8)
            let cs3b = _cjStr("three")
            lua_setfield_cj(L, LUA_GLOBALSINDEX, cs3b)
            _cjFree(cs3b)
            let cs3c = _cjStr("three")
            lua_getfield_cj(L, LUA_GLOBALSINDEX, cs3c)
            _cjFree(cs3c)
        }
        let n = parts.size
        for (i in 1..n) {
            let part = parts[Int64(i)]
            let isLast = i == n - 1
            // 当前父表绝对索引：root(1) + 已经压入的子表数 (可能已含 i-1 层)
            // 若上一轮成功压入，父表应为绝对索引 i（因为栈 = root + (i-1) 层中间 + 正在处理的键）
            // 这里用相对索引 -1 更稳妥：getfield 前父表在栈顶
            let csPart = _cjStr(part)
            lua_getfield_cj(L, -1, csPart)
            _cjFree(csPart)
            if (lua_type_cj(L, -1) != LUA_TTABLE) {
                // 缺失：弹出 nil，新建表挂到父表（父表在 getfield 前是 -1，现为 -2）
                lua_settop_cj(L, -2)
                lua_createtable_cj(L, 0, 8)
                let csPart2 = _cjStr(part)
                lua_setfield_cj(L, -2, csPart2)
                _cjFree(csPart2)
                let csPart3 = _cjStr(part)
                lua_getfield_cj(L, -1, csPart3)
                _cjFree(csPart3)
            }
            if (isLast) {
                return true                    // 类表已在栈顶
            }
        }
        // 理论上不会走到（n>=2 时循环至少执行一次且最终 isLast=true）
        lua_settop_cj(L, 0)
        return false
    }

    // =========================================================================
    // 通用工具
    // =========================================================================

    /// 执行回调并压返回值（异常 → Lua 错误）
    private static func _runAndPush(L: CPointer<Unit>, body: () -> Array<LuaValue>): Int32 {
        try {
            let results = body()
            for (v in results) {
                LuaVM.pushValue(L, v)
            }
            return Int32(results.size)
        } catch (e: Exception) {
            return _pushError(L, e.message)
        }
    }

    /// 压错误消息并调用 lua_error（不返回）
    private static func _pushError(L: CPointer<Unit>, msg: String): Int32 {
        let cs = _cjStr(msg)
        lua_pushstring_cj(L, cs)
        _cjFree(cs)
        return lua_error_cj(L)
    }

    /// 读取栈索引 idx 处字符串键（非字符串返回 None）
    private static func _readKeyString(L: CPointer<Unit>, idx: Int32): Option<String> {
        if (lua_type_cj(L, idx) != LUA_TSTRING) {
            return None
        }
        let cs = lua_tolstring_cj(L, idx, CPointer<UIntNative>())
        if (cs.isNull()) { return None }
        return Some(unsafe { cs.toString() })
    }
}