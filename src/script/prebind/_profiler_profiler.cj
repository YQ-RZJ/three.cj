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
 * @file[zh-cn] profiler_profiler three.profiler 运行时门面的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 ProfZone / ProfFrame / ProfPlot / ProfMessage / ProfMemory / Gpu / Lock /
 * ProfFiber / ProfGpuZone / ProfLockZone / FiberScope / Sampling / ProfilerState 以及
 * TracyPlotFormat / TracyMessageSeverity 两个枚举绑定为 Lua 类型
 * @explain[zh-cn] 运行时门面为无条件侵入（直接调用即上报 Tracy），宏包不绑定（宏由编译期
 * 展开，不构成 Lua API）。
 * 指针参数适配：
 * - ProfMemory.alloc / free 的 CPointer 改为「整数块 id」：alloc(size, name) 分配真实内存
 *   并登记 id，返回 id>0；free(id, name) 查表上报并释放，返回是否命中；
 * - Lock.announce / announceShared 返回「锁上下文 id」；terminate / beforeLock /
 *   afterLock / afterUnlock / afterTryLock 均接受该 id（未知 id 视为空句柄，安全忽略）；
 * - Gpu.zoneBegin 的 srcloc 为地址值，按 Lua number 原样透传；
 * - ProfFrame.image 的参数是 CPointer，Lua 无法表达，**不绑定**。
 * 枚举 TracyPlotFormat（Number=0/Memory=1/Percentage=2/Watt=3）与 TracyMessageSeverity
 * （Trace=0/Debug=1/Info=2/Warning=3/Error=4/Fatal=5）以常量命名空间 + fromValue 暴露。
 * 作用域类（ProfZone / ProfGpuZone / ProfLockZone / FiberScope）均提供 close / isClosed，
 * 由 Lua 侧显式配对关闭。
 *
 * @file[en] profiler_profiler  Lua bindings of the three.profiler runtime facade
 * (three.script.prebind)
 * @brief[en] Binds ProfZone / ProfFrame / ProfPlot / ProfMessage / ProfMemory / Gpu / Lock /
 * ProfFiber / ProfGpuZone / ProfLockZone / FiberScope / Sampling / ProfilerState plus the
 * TracyPlotFormat / TracyMessageSeverity enums as Lua types
 * @explain[en] The runtime facade is unconditional (a direct call reports to Tracy); the macro
 * package is not bound (macros expand at compile time and are not a Lua API).
 * Pointer adaptation:
 * - ProfMemory.alloc / free take an integer block id instead of CPointer: alloc(size, name)
 *   allocates real memory, registers an id and returns id>0; free(id, name) looks it up,
 *   reports and frees it, returning whether it was found;
 * - Lock.announce / announceShared return a lock-context id; terminate / beforeLock /
 *   afterLock / afterUnlock / afterTryLock accept that id (an unknown id behaves like a null
 *   handle and is safely ignored);
 * - Gpu.zoneBegin's srcloc is an address value passed through as a Lua number;
 * - ProfFrame.image takes a CPointer that Lua cannot express, so it is **not bound**.
 * The enums TracyPlotFormat (Number=0/Memory=1/Percentage=2/Watt=3) and
 * TracyMessageSeverity (Trace=0/Debug=1/Info=2/Warning=3/Error=4/Fatal=5) are exposed as
 * constant namespaces plus fromValue.
 * Scope classes (ProfZone / ProfGpuZone / ProfLockZone / FiberScope) all provide close /
 * isClosed, paired explicitly from Lua.
 */
package three.script.prebind

import three.profiler.*
import three._vendor.tracy4cj.tracy.{TracyPlotFormat, TracyMessageSeverity}
import three.script.vm.*
import three.script.binding.*
import std.collection.*

// =============================================================================
// 指针 → 整数句柄适配（内存块 / 锁上下文）
// =============================================================================

/// 内存块登记表：id → 原生指针
private var _profMemBlocks: HashMap<Int64, CPointer<Unit>> = HashMap()
/// 下一个内存块 id
private var _profNextMemId: Int64 = 1
/// 锁上下文登记表：id → 原生句柄
private var _profLocks: HashMap<Int64, CPointer<Unit>> = HashMap()
/// 下一个锁上下文 id
private var _profNextLockId: Int64 = 1

/// 按 id 取内存块指针
private func _profMemGet(id: Int64): Option<CPointer<Unit>> {
    if (_profMemBlocks.contains(id)) {
        return Some(_profMemBlocks.get(id).getOrThrow())
    }
    return None
}

/// 按 id 取锁上下文句柄
private func _profLockGet(id: Int64): Option<CPointer<Unit>> {
    if (_profLocks.contains(id)) {
        return Some(_profLocks.get(id).getOrThrow())
    }
    return None
}

/**
 * @brief[zh-cn] 安装 TracyPlotFormat 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TracyPlotFormat (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTracyPlotFormat(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.TracyPlotFormat")
    b.staticMethod("Number") {_ => [LuaValue.of(Int64(TracyPlotFormat.Number.value()))]}
    b.staticMethod("Memory") {_ => [LuaValue.of(Int64(TracyPlotFormat.Memory.value()))]}
    b.staticMethod("Percentage") {_ => [LuaValue.of(Int64(TracyPlotFormat.Percentage.value()))]}
    b.staticMethod("Watt") {_ => [LuaValue.of(Int64(TracyPlotFormat.Watt.value()))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(Int64(TracyPlotFormat.fromValue(Int32(prebindInt(args, 0))).value()))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 TracyMessageSeverity 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TracyMessageSeverity (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTracyMessageSeverity(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.TracyMessageSeverity")
    b.staticMethod("Trace") {_ => [LuaValue.of(Int64(TracyMessageSeverity.Trace.value()))]}
    b.staticMethod("Debug") {_ => [LuaValue.of(Int64(TracyMessageSeverity.Debug.value()))]}
    b.staticMethod("Info") {_ => [LuaValue.of(Int64(TracyMessageSeverity.Info.value()))]}
    b.staticMethod("Warning") {_ => [LuaValue.of(Int64(TracyMessageSeverity.Warning.value()))]}
    b.staticMethod("Error") {_ => [LuaValue.of(Int64(TracyMessageSeverity.Error.value()))]}
    b.staticMethod("Fatal") {_ => [LuaValue.of(Int64(TracyMessageSeverity.Fatal.value()))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(Int64(TracyMessageSeverity.fromValue(Int32(prebindInt(args, 0))).value()))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ProfZone 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.profiler.ProfZone）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] 五种构造重载按参数类型/数量分派：
 * (name,file,line,function) / (name,color,file,line) / (name,color,file,line,function) /
 * (key,name,color,file,line) / (key,name,color,file,line,function)。
 *
 * @brief[en] Installs the Lua binding of ProfZone
 * @param[en] vm The target virtual machine (class table installed at three.profiler.ProfZone)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] The five constructor overloads are dispatched by argument type/count:
 * (name,file,line,function) / (name,color,file,line) / (name,color,file,line,function) /
 * (key,name,color,file,line) / (key,name,color,file,line,function).
 */
public func installProfZone(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.ProfZone")
    b.constructor {
        args =>
            let n = args.size
            if (n >= 5 && !args[0].isString) {
                // key 形式
                if (n >= 6) {
                    ProfZone(prebindInt(args, 0), prebindStr(args, 1), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                        prebindStr(args, 3), UInt32(prebindInt(args, 4) & 0xFFFFFFFF), prebindStr(args, 5))
                } else {
                    ProfZone(prebindInt(args, 0), prebindStr(args, 1), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                        prebindStr(args, 3), UInt32(prebindInt(args, 4) & 0xFFFFFFFF))
                }
            } else if (n >= 5) {
                ProfZone(prebindStr(args, 0), UInt32(prebindInt(args, 1) & 0xFFFFFFFF), prebindStr(args, 2),
                    UInt32(prebindInt(args, 3) & 0xFFFFFFFF), prebindStr(args, 4))
            } else if (n >= 4 && args[1].isNumber) {
                ProfZone(prebindStr(args, 0), UInt32(prebindInt(args, 1) & 0xFFFFFFFF), prebindStr(args, 2),
                    UInt32(prebindInt(args, 3) & 0xFFFFFFFF))
            } else {
                ProfZone(prebindStr(args, 0), prebindStr(args, 1), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                    prebindStr(args, 3))
            }
    }
    b.property("active", getter: Some({ref => LuaValue.of(ref.cast<ProfZone>().active)}))
    b.method("text") {
        ref, args =>
            ref.cast<ProfZone>().text(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.method("value") {
        ref, args =>
            ref.cast<ProfZone>().value(UInt64(prebindInt(args, 0)))
            Array<LuaValue>()
    }
    b.method("color") {
        ref, args =>
            ref.cast<ProfZone>().color(UInt32(prebindInt(args, 0) & 0xFFFFFFFF))
            Array<LuaValue>()
    }
    b.method("rename") {
        ref, args =>
            ref.cast<ProfZone>().rename(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.method("isClosed") {
        ref, _ => [LuaValue.of(ref.cast<ProfZone>().isClosed())]
    }
    b.method("close") {
        ref, _ =>
            ref.cast<ProfZone>().close()
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ProfFrame 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] image 的参数为 CPointer，Lua 无法表达，不绑定。
 *
 * @brief[en] Installs the Lua binding of ProfFrame
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] image takes a CPointer that Lua cannot express, so it is not bound.
 */
public func installProfFrame(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.ProfFrame")
    b.staticMethod("mark") {
        args =>
            if (args.size >= 1 && !args[0].isNil) {
                ProfFrame.mark(prebindStr(args, 0))
            } else {
                ProfFrame.mark()
            }
            Array<LuaValue>()
    }
    b.staticMethod("start") {
        args =>
            ProfFrame.start(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("finish") {
        args =>
            ProfFrame.finish(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ProfPlot 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ProfPlot
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installProfPlot(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.ProfPlot")
    b.staticMethod("config") {
        args =>
            ProfPlot.config(prebindStr(args, 0), TracyPlotFormat.fromValue(Int32(prebindInt(args, 1))),
                prebindBool(args, 2), prebindBool(args, 3), UInt32(prebindInt(args, 4, default: 0xFFFFFFFF) & 0xFFFFFFFF))
            Array<LuaValue>()
    }
    b.staticMethod("point") {
        args =>
            ProfPlot.point(prebindStr(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.staticMethod("pointF32") {
        args =>
            ProfPlot.pointF32(prebindStr(args, 0), Float32(prebindNum(args, 1)))
            Array<LuaValue>()
    }
    b.staticMethod("pointI64") {
        args =>
            ProfPlot.pointI64(prebindStr(args, 0), prebindInt(args, 1))
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ProfMessage 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ProfMessage
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installProfMessage(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.ProfMessage")
    b.staticMethod("log") {
        args =>
            ProfMessage.log(prebindStr(args, 0), TracyMessageSeverity.fromValue(Int32(prebindInt(args, 1, default: 2))))
            Array<LuaValue>()
    }
    b.staticMethod("logTrace") {
        args =>
            ProfMessage.logTrace(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("logDebug") {
        args =>
            ProfMessage.logDebug(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("logInfo") {
        args =>
            ProfMessage.logInfo(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("logWarning") {
        args =>
            ProfMessage.logWarning(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("logError") {
        args =>
            ProfMessage.logError(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("logFatal") {
        args =>
            ProfMessage.logFatal(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("appInfo") {
        args =>
            ProfMessage.appInfo(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ProfMemory 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] alloc(size, name) 分配真实内存并登记 id；free(id, name) 命中时上报并释放
 * 返回 true，未命中返回 false；discard(name) 按名清零整池。
 *
 * @brief[en] Installs the Lua binding of ProfMemory
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] alloc(size, name) allocates real memory and registers an id; free(id, name)
 * reports and frees it on a hit (returns true) and returns false otherwise; discard(name)
 * zeroes the whole named pool.
 */
public func installProfMemory(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.ProfMemory")
    b.staticMethod("alloc") {
        args =>
            let size = prebindInt(args, 0, default: 1)
            let count = if (size > 0) {
                size
            } else {
                1
            }
            let p = unsafe { LibC.malloc<UInt8>(count: count) }
            var id: Int64 = 0
            if (!unsafe { p.isNull() }) {
                id = _profNextMemId
                _profNextMemId += 1
                _profMemBlocks.add(id, CPointer<Unit>(p))
                ProfMemory.alloc(CPointer<Unit>(p), UIntNative(count), prebindStr(args, 1))
            }
            [LuaValue.of(id)]
    }
    b.staticMethod("free") {
        args =>
            let id = prebindInt(args, 0)
            match (_profMemGet(id)) {
                case Some(p) =>
                    ProfMemory.free(p, prebindStr(args, 1))
                    _profMemBlocks.remove(id)
                    unsafe { LibC.free(CPointer<UInt8>(p)) }
                    [LuaValue.Boolean(true)]
                case None => [LuaValue.Boolean(false)]
            }
    }
    b.staticMethod("discard") {
        args =>
            ProfMemory.discard(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Gpu 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] zoneBegin 的 srcloc 为地址值（Lua number）；常规用法建议使用
 * ProfGpuZone 作用域类。
 *
 * @brief[en] Installs the Lua binding of Gpu
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] zoneBegin's srcloc is an address value (Lua number); the ProfGpuZone scope
 * class is the usual alternative.
 */
public func installGpu(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.Gpu")
    b.staticMethod("newContext") {
        args =>
            Gpu.newContext(prebindInt(args, 0), Float32(prebindNum(args, 1)), UInt8(prebindInt(args, 2) & 0xFF),
                UInt8(prebindInt(args, 3) & 0xFF), UInt8(prebindInt(args, 4) & 0xFF))
            Array<LuaValue>()
    }
    b.staticMethod("zoneBegin") {
        args =>
            Gpu.zoneBegin(UInt64(prebindInt(args, 0)), UInt16(prebindInt(args, 1) & 0xFFFF),
                UInt8(prebindInt(args, 2) & 0xFF))
            Array<LuaValue>()
    }
    b.staticMethod("zoneEnd") {
        args =>
            Gpu.zoneEnd(UInt16(prebindInt(args, 0) & 0xFFFF), UInt8(prebindInt(args, 1) & 0xFF))
            Array<LuaValue>()
    }
    b.staticMethod("time") {
        args =>
            Gpu.time(prebindInt(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF), UInt8(prebindInt(args, 2) & 0xFF))
            Array<LuaValue>()
    }
    b.staticMethod("contextName") {
        args =>
            Gpu.contextName(UInt8(prebindInt(args, 0) & 0xFF), prebindStr(args, 1))
            Array<LuaValue>()
    }
    b.staticMethod("calibration") {
        args =>
            Gpu.calibration(prebindInt(args, 0), prebindInt(args, 1), UInt8(prebindInt(args, 2) & 0xFF))
            Array<LuaValue>()
    }
    b.staticMethod("timeSync") {
        args =>
            Gpu.timeSync(prebindInt(args, 0), UInt8(prebindInt(args, 1) & 0xFF))
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Lock 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] announce / announceShared 返回锁上下文 id（>0），其余方法接受该 id；
 * 未知 id 等价于空句柄（安全忽略）。
 *
 * @brief[en] Installs the Lua binding of Lock
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] announce / announceShared return a lock-context id (>0) that the other methods
 * accept; an unknown id behaves like a null handle (safely ignored).
 */
public func installLock(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.Lock")
    b.staticMethod("announce") {
        args =>
            let p = Lock.announce(prebindStr(args, 0), prebindStr(args, 1), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                prebindStr(args, 3))
            var id: Int64 = 0
            if (!p.isNull()) {
                id = _profNextLockId
                _profNextLockId += 1
                _profLocks.add(id, p)
            }
            [LuaValue.of(id)]
    }
    b.staticMethod("announceShared") {
        args =>
            let p = Lock.announceShared(prebindStr(args, 0), prebindStr(args, 1), UInt32(prebindInt(args, 2) & 0xFFFFFFFF),
                prebindStr(args, 3))
            var id: Int64 = 0
            if (!p.isNull()) {
                id = _profNextLockId
                _profNextLockId += 1
                _profLocks.add(id, p)
            }
            [LuaValue.of(id)]
    }
    b.staticMethod("terminate") {
        args =>
            let id = prebindInt(args, 0)
            if (let Some(p) <- _profLockGet(id)) {
                Lock.terminate(p)
                _profLocks.remove(id)
            }
            Array<LuaValue>()
    }
    b.staticMethod("terminateShared") {
        args =>
            let id = prebindInt(args, 0)
            if (let Some(p) <- _profLockGet(id)) {
                Lock.terminateShared(p)
                _profLocks.remove(id)
            }
            Array<LuaValue>()
    }
    b.staticMethod("beforeLock") {
        args => if (let Some(p) <- _profLockGet(prebindInt(args, 0))) {
            [LuaValue.of(Lock.beforeLock(p))]
        } else {
            [LuaValue.Boolean(true)]
        }
    }
    b.staticMethod("afterLock") {
        args =>
            if (let Some(p) <- _profLockGet(prebindInt(args, 0))) {
                Lock.afterLock(p)
            }
            Array<LuaValue>()
    }
    b.staticMethod("afterUnlock") {
        args =>
            if (let Some(p) <- _profLockGet(prebindInt(args, 0))) {
                Lock.afterUnlock(p)
            }
            Array<LuaValue>()
    }
    b.staticMethod("afterTryLock") {
        args =>
            if (let Some(p) <- _profLockGet(prebindInt(args, 0))) {
                Lock.afterTryLock(p, prebindBool(args, 1))
            }
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ProfFiber 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ProfFiber
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installProfFiber(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.ProfFiber")
    b.staticMethod("enter") {
        args =>
            ProfFiber.enter(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("leave") {
        _ =>
            ProfFiber.leave()
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ProfGpuZone 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ProfGpuZone
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installProfGpuZone(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.ProfGpuZone")
    b.constructor {
        args => ProfGpuZone(prebindStr(args, 0), UInt8(prebindInt(args, 1) & 0xFF), prebindStr(args, 2),
            UInt32(prebindInt(args, 3) & 0xFFFFFFFF))
    }
    b.property("query", getter: Some({ref => LuaValue.of(Int64(ref.cast<ProfGpuZone>().query))}))
    b.property("ctx", getter: Some({ref => LuaValue.of(Int64(ref.cast<ProfGpuZone>().ctx))}))
    b.method("close") {
        ref, _ =>
            ref.cast<ProfGpuZone>().close()
            Array<LuaValue>()
    }
    b.method("isClosed") {
        ref, _ => [LuaValue.of(ref.cast<ProfGpuZone>().isClosed())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ProfLockZone 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ProfLockZone
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installProfLockZone(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.ProfLockZone")
    b.constructor {
        args => ProfLockZone(prebindStr(args, 0), prebindStr(args, 1), UInt32(prebindInt(args, 2) & 0xFFFFFFFF))
    }
    b.method("close") {
        ref, _ =>
            ref.cast<ProfLockZone>().close()
            Array<LuaValue>()
    }
    b.method("isClosed") {
        ref, _ => [LuaValue.of(ref.cast<ProfLockZone>().isClosed())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 FiberScope 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FiberScope
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFiberScope(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.FiberScope")
    b.constructor {
        args => FiberScope(prebindStr(args, 0))
    }
    b.method("close") {
        ref, _ =>
            ref.cast<FiberScope>().close()
            Array<LuaValue>()
    }
    b.method("isClosed") {
        ref, _ => [LuaValue.of(ref.cast<FiberScope>().isClosed())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Sampling 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Sampling
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSampling(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.Sampling")
    b.staticMethod("start") {
        _ => [LuaValue.of(Sampling.start())]
    }
    b.staticMethod("stop") {
        _ =>
            Sampling.stop()
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ProfilerState 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ProfilerState
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installProfilerState(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.profiler.ProfilerState")
    b.staticMethod("isConnected") {
        _ => [LuaValue.of(ProfilerState.isConnected())]
    }
    b.staticMethod("now") {
        _ => [LuaValue.of(ProfilerState.now())]
    }
    b.staticMethod("threadName") {
        args =>
            ProfilerState.threadName(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.install(vm)
}
