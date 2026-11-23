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
 * @file[zh-cn] renderers_buffer_attribute 缓冲属性族（BufferAttribute 及 3 个子类）的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.buffer 的 BufferAttribute / Float32BufferAttribute /
 * Uint16BufferAttribute / Uint32BufferAttribute 绑定为 Lua 类型
 * @explain[zh-cn] 四个类共用同一套成员，由 _installBufferAttributeMembers 统一登记到各自的
 * metatable（绑定层无 __index 继承链，子类需重复登记基类成员）。
 * - 构造：无参，或 array + itemSize [+ normalized]；
 * - 属性：kind / name / array / itemSize / normalized / usage / gpuType / version 可读写；
 *   updateRanges 与 onUploadCallback 为嵌套容器 / 闭包，不绑定；
 * - 方法：markNeedsUpdate / setUsage / addUpdateRange / clearUpdateRanges / copy / copyAt /
 *   copyArray / applyMatrix3 / applyMatrix4 / applyNormalMatrix / transformDirection / set /
 *   getComponent / setComponent / getX~getW / setX~setW / setXY / setXYZ / setXYZW /
 *   onUpload / clone / dispose。
 * array 走「Lua 表 ↔ Float64 数组」通道（prebindFloatArray / LuaValue.of(Array<Float64>)）。
 * onUpload(callback: () -> Unit) 的闭包参数按项目约定不暴露给 Lua。
 *
 * @file[en] renderers_buffer_attribute  Lua bindings of the buffer attribute family
 * (BufferAttribute and its three subclasses) (three.script.prebind)
 * @brief[en] Binds three.renderers.buffer's BufferAttribute / Float32BufferAttribute /
 * Uint16BufferAttribute / Uint32BufferAttribute as Lua types
 * @explain[en] The four classes share one member set, registered by
 * _installBufferAttributeMembers on each own metatable (the binding layer has no __index
 * inheritance chain, so subclasses repeat the base members).
 * - Constructors: parameterless, or array + itemSize [+ normalized];
 * - Properties: kind / name / array / itemSize / normalized / usage / gpuType / version are
 *   read-write; updateRanges and onUploadCallback are a nested container / a closure and are
 *   not bound;
 * - Methods: markNeedsUpdate / setUsage / addUpdateRange / clearUpdateRanges / copy / copyAt /
 *   copyArray / applyMatrix3 / applyMatrix4 / applyNormalMatrix / transformDirection / set /
 *   getComponent / setComponent / getX..getW / setX..setW / setXY / setXYZ / setXYZW /
 *   onUpload / clone / dispose.
 * array uses the "Lua table ↔ Float64 array" channel (prebindFloatArray /
 * LuaValue.of(Array<Float64>)). onUpload(callback: () -> Unit) takes a closure, which the
 * project convention keeps away from Lua.
 */
package three.script.prebind

import three.renderers.buffer.BufferAttribute
import three.renderers.buffer.Float32BufferAttribute
import three.renderers.buffer.Uint16BufferAttribute
import three.renderers.buffer.Uint32BufferAttribute
import three.core.math.Matrix3
import three.core.math.Matrix4
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 登记 BufferAttribute 家族共有成员（属性 + 读写 + 变换 + 克隆）
 * @param[zh-cn] b 类绑定器（基类或子类）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Registers the members shared by the BufferAttribute family
 * (properties + accessors + transforms + clone)
 * @param[en] b The class binder (base class or subclass)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _installBufferAttributeMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 属性 =====
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<BufferAttribute>().kind)}),
        setter: Some({ref, v => ref.cast<BufferAttribute>().kind = v.stringValue()}))
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<BufferAttribute>().name)}),
        setter: Some({ref, v => ref.cast<BufferAttribute>().name = v.stringValue()}))
    b.property("array", getter: Some({ref => LuaValue.of(ref.cast<BufferAttribute>().array)}),
        setter: Some({ref, v => ref.cast<BufferAttribute>().array = prebindFloatArray(vm, [v], 0)}))
    b.property("itemSize", getter: Some({ref => LuaValue.of(ref.cast<BufferAttribute>().itemSize)}),
        setter: Some({ref, v => ref.cast<BufferAttribute>().itemSize = v.intValue()}))
    b.property("count", getter: Some({ref => LuaValue.of(ref.cast<BufferAttribute>().count)}),
        setter: Some({ref, v => ref.cast<BufferAttribute>().count = v.intValue()}))
    b.property("normalized", getter: Some({ref => LuaValue.of(ref.cast<BufferAttribute>().normalized)}),
        setter: Some({ref, v => ref.cast<BufferAttribute>().normalized = v.boolValue()}))
    b.property("usage", getter: Some({ref => LuaValue.of(ref.cast<BufferAttribute>().usage)}),
        setter: Some({ref, v => ref.cast<BufferAttribute>().usage = v.intValue()}))
    b.property("gpuType", getter: Some({ref => LuaValue.of(ref.cast<BufferAttribute>().gpuType)}),
        setter: Some({ref, v => ref.cast<BufferAttribute>().gpuType = v.intValue()}))
    b.property("version", getter: Some({ref => LuaValue.of(ref.cast<BufferAttribute>().version)}),
        setter: Some({ref, v => ref.cast<BufferAttribute>().version = v.intValue()}))
    // ===== 上传标记与使用模式 =====
    b.method("markNeedsUpdate") {
        ref, _ =>
            ref.cast<BufferAttribute>().markNeedsUpdate()
            [LuaValue.Object(ref.id)]
    }
    b.method("setUsage") {
        ref, args =>
            ref.cast<BufferAttribute>().setUsage(prebindInt(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addUpdateRange") {
        ref, args =>
            ref.cast<BufferAttribute>().addUpdateRange(prebindInt(args, 0), prebindInt(args, 1))
            Array<LuaValue>()
    }
    b.method("clearUpdateRanges") {
        ref, _ =>
            ref.cast<BufferAttribute>().clearUpdateRanges()
            Array<LuaValue>()
    }
    // ===== 拷贝（返回 BufferAttribute 的方法回传自身 id） =====
    b.method("copy") {
        ref, args =>
            ref.cast<BufferAttribute>().copy(prebindAs<BufferAttribute>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("copyAt") {
        ref, args =>
            ref
                .cast<BufferAttribute>()
                .copyAt(prebindInt(args, 0), prebindAs<BufferAttribute>(args, 1), prebindInt(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("copyArray") {
        ref, args =>
            ref.cast<BufferAttribute>().copyArray(prebindFloatArray(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 矩阵变换 =====
    b.method("applyMatrix3") {
        ref, args =>
            ref.cast<BufferAttribute>().applyMatrix3(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<BufferAttribute>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyNormalMatrix") {
        ref, args =>
            ref.cast<BufferAttribute>().applyNormalMatrix(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("transformDirection") {
        ref, args =>
            ref.cast<BufferAttribute>().transformDirection(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 批量写入 =====
    b.method("set") {
        ref, args =>
            ref.cast<BufferAttribute>().set(prebindFloatArray(vm, args, 0), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 分量读写 =====
    b.method("getComponent") {
        ref, args => [LuaValue.of(ref.cast<BufferAttribute>().getComponent(prebindInt(args, 0), prebindInt(args, 1)))]
    }
    b.method("setComponent") {
        ref, args =>
            ref.cast<BufferAttribute>().setComponent(prebindInt(args, 0), prebindInt(args, 1), prebindNum(args, 2))
            Array<LuaValue>()
    }
    b.method("getX") {ref, args => [LuaValue.of(ref.cast<BufferAttribute>().getX(prebindInt(args, 0)))]}
    b.method("setX") {
        ref, args =>
            ref.cast<BufferAttribute>().setX(prebindInt(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getY") {ref, args => [LuaValue.of(ref.cast<BufferAttribute>().getY(prebindInt(args, 0)))]}
    b.method("setY") {
        ref, args =>
            ref.cast<BufferAttribute>().setY(prebindInt(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getZ") {ref, args => [LuaValue.of(ref.cast<BufferAttribute>().getZ(prebindInt(args, 0)))]}
    b.method("setZ") {
        ref, args =>
            ref.cast<BufferAttribute>().setZ(prebindInt(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getW") {ref, args => [LuaValue.of(ref.cast<BufferAttribute>().getW(prebindInt(args, 0)))]}
    b.method("setW") {
        ref, args =>
            ref.cast<BufferAttribute>().setW(prebindInt(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("setXY") {
        ref, args =>
            ref.cast<BufferAttribute>().setXY(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("setXYZ") {
        ref, args =>
            ref
                .cast<BufferAttribute>()
                .setXYZ(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3))
            [LuaValue.Object(ref.id)]
    }
    b.method("setXYZW") {
        ref, args =>
            ref
                .cast<BufferAttribute>()
                .setXYZW(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4))
            [LuaValue.Object(ref.id)]
    }
    // ===== 克隆与释放 =====
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<BufferAttribute>().clone(), "three.renderers.buffer.BufferAttribute")]
    }
    b.method("dispose") {
        ref, _ =>
            ref.cast<BufferAttribute>().dispose()
            Array<LuaValue>()
    }
}

/**
 * @brief[zh-cn] 安装 BufferAttribute 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.BufferAttribute）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BufferAttribute
 * @param[en] vm The target virtual machine (class table installed at three.renderers.buffer.BufferAttribute)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBufferAttribute(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.BufferAttribute")
    b.constructor {
        args => if (args.size >= 2 && !args[0].isNil && !args[1].isNil) {
            BufferAttribute(prebindFloatArray(vm, args, 0), prebindInt(args, 1), normalized: prebindBool(args, 2))
        } else {
            BufferAttribute()
        }
    }
    _installBufferAttributeMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Float32BufferAttribute 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.Float32BufferAttribute）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Float32BufferAttribute
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.buffer.Float32BufferAttribute)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFloat32BufferAttribute(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.Float32BufferAttribute")
    b.constructor {
        args => Float32BufferAttribute(prebindFloatArray(vm, args, 0), prebindInt(args, 1),
            normalized: prebindBool(args, 2))
    }
    _installBufferAttributeMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Uint16BufferAttribute 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.Uint16BufferAttribute）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Uint16BufferAttribute
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.buffer.Uint16BufferAttribute)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUint16BufferAttribute(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.Uint16BufferAttribute")
    b.constructor {
        args => Uint16BufferAttribute(prebindFloatArray(vm, args, 0), prebindInt(args, 1),
            normalized: prebindBool(args, 2))
    }
    _installBufferAttributeMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Uint32BufferAttribute 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.Uint32BufferAttribute）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Uint32BufferAttribute
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.buffer.Uint32BufferAttribute)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUint32BufferAttribute(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.Uint32BufferAttribute")
    b.constructor {
        args => Uint32BufferAttribute(prebindFloatArray(vm, args, 0), prebindInt(args, 1),
            normalized: prebindBool(args, 2))
    }
    _installBufferAttributeMembers(b, vm)
    b.install(vm)
}
