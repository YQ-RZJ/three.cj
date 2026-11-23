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
 * @file[zh-cn] renderers_buffer_interleaved 交错缓冲族（InterleavedBuffer / UpdateRange /
 * InterleavedBufferAttribute / InstancedInterleavedBuffer）的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.buffer 的交错缓冲相关 4 个类绑定为 Lua 类型
 * @explain[zh-cn] - UpdateRange：start / count 两个可读写字段 + 两种构造（无参 / start+count）；
 * - InterleavedBuffer：array / stride / count / usage / version 可读写，uuid 只读；
 *   markNeedsUpdate / setUsage / addUpdateRange / clearUpdateRanges / copy / copyAt / set；
 *   updateRanges（嵌套容器）与 onUploadCallback（闭包）不绑定；
 * - InterleavedBufferAttribute：name / data / itemSize / offset / normalized 可读写 +
 *   count() / array() / setNeedsUpdate / 矩阵变换 / 分量读写 / clone；
 * - InstancedInterleavedBuffer：meshPerAttribute 属性 + copy / clone。
 * array 走「Lua 表 ↔ Float64 数组」通道。
 *
 * @file[en] renderers_buffer_interleaved  Lua bindings of the interleaved buffer family
 * (InterleavedBuffer / UpdateRange / InterleavedBufferAttribute / InstancedInterleavedBuffer)
 * (three.script.prebind)
 * @brief[en] Binds the four interleaved-buffer classes of three.renderers.buffer as Lua types
 * @explain[en] - UpdateRange: the start / count fields plus two constructors (parameterless /
 *   start+count);
 * - InterleavedBuffer: array / stride / count / usage / version are read-write, uuid is
 *   read-only; markNeedsUpdate / setUsage / addUpdateRange / clearUpdateRanges / copy / copyAt /
 *   set; updateRanges (nested container) and onUploadCallback (closure) are not bound;
 * - InterleavedBufferAttribute: name / data / itemSize / offset / normalized are read-write plus
 *   count() / array() / setNeedsUpdate / matrix transforms / component accessors / clone;
 * - InstancedInterleavedBuffer: the meshPerAttribute property plus copy / clone.
 * array uses the "Lua table ↔ Float64 array" channel.
 */
package three.script.prebind

import three.renderers.buffer.InterleavedBuffer
import three.renderers.buffer.InterleavedBufferAttribute
import three.renderers.buffer.InstancedInterleavedBuffer
import three.renderers.buffer.UpdateRange
import three.core.math.Matrix3
import three.core.math.Matrix4
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 UpdateRange 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.UpdateRange）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UpdateRange
 * @param[en] vm The target virtual machine (class table installed at three.renderers.buffer.UpdateRange)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUpdateRange(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.UpdateRange")
    b.constructor {
        args => if (args.size >= 2) {
            UpdateRange(prebindInt(args, 0), prebindInt(args, 1))
        } else {
            UpdateRange()
        }
    }
    b.property("start", getter: Some({ref => LuaValue.of(ref.cast<UpdateRange>().start)}),
        setter: Some({ref, v => ref.cast<UpdateRange>().start = v.intValue()}))
    b.property("count", getter: Some({ref => LuaValue.of(ref.cast<UpdateRange>().count)}),
        setter: Some({ref, v => ref.cast<UpdateRange>().count = v.intValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 登记 InterleavedBuffer 共有成员（属性 + 上传标记 + 拷贝）
 * @param[zh-cn] b 类绑定器（基类或 InstancedInterleavedBuffer）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Registers the members shared by InterleavedBuffer
 * (properties + upload marking + copies)
 * @param[en] b The class binder (base class or InstancedInterleavedBuffer)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _installInterleavedBufferMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    b.property("array", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBuffer>().array)}),
        setter: Some({ref, v => ref.cast<InterleavedBuffer>().array = prebindFloatArray(vm, [v], 0)}))
    b.property("stride", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBuffer>().stride)}),
        setter: Some({ref, v => ref.cast<InterleavedBuffer>().stride = v.intValue()}))
    b.property("count", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBuffer>().count)}),
        setter: Some({ref, v => ref.cast<InterleavedBuffer>().count = v.intValue()}))
    b.property("usage", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBuffer>().usage)}),
        setter: Some({ref, v => ref.cast<InterleavedBuffer>().usage = v.intValue()}))
    b.property("version", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBuffer>().version)}),
        setter: Some({ref, v => ref.cast<InterleavedBuffer>().version = v.intValue()}))
    b.property("uuid", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBuffer>().uuid)}))
    b.method("markNeedsUpdate") {
        ref, _ =>
            ref.cast<InterleavedBuffer>().markNeedsUpdate()
            [LuaValue.Object(ref.id)]
    }
    b.method("setUsage") {
        ref, args =>
            ref.cast<InterleavedBuffer>().setUsage(prebindInt(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addUpdateRange") {
        ref, args =>
            ref.cast<InterleavedBuffer>().addUpdateRange(prebindInt(args, 0), prebindInt(args, 1))
            Array<LuaValue>()
    }
    b.method("clearUpdateRanges") {
        ref, _ =>
            ref.cast<InterleavedBuffer>().clearUpdateRanges()
            Array<LuaValue>()
    }
    b.method("copy") {
        ref, args =>
            ref.cast<InterleavedBuffer>().copy(prebindAs<InterleavedBuffer>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("copyAt") {
        ref, args =>
            ref
                .cast<InterleavedBuffer>()
                .copyAt(prebindInt(args, 0), prebindAs<InterleavedBuffer>(args, 1), prebindInt(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("set") {
        ref, args =>
            ref.cast<InterleavedBuffer>().set(prebindFloatArray(vm, args, 0), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
}

/**
 * @brief[zh-cn] 安装 InterleavedBuffer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.InterleavedBuffer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of InterleavedBuffer
 * @param[en] vm The target virtual machine (class table installed at three.renderers.buffer.InterleavedBuffer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installInterleavedBuffer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.InterleavedBuffer")
    b.constructor {
        args => if (args.size >= 2 && !args[0].isNil) {
            InterleavedBuffer(prebindFloatArray(vm, args, 0), prebindInt(args, 1))
        } else {
            InterleavedBuffer()
        }
    }
    _installInterleavedBufferMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 InstancedInterleavedBuffer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.InstancedInterleavedBuffer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of InstancedInterleavedBuffer
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.buffer.InstancedInterleavedBuffer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installInstancedInterleavedBuffer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.InstancedInterleavedBuffer")
    b.constructor {
        args => if (args.size >= 2 && !args[0].isNil) {
            InstancedInterleavedBuffer(prebindFloatArray(vm, args, 0), prebindInt(args, 1),
                meshPerAttribute: prebindInt(args, 2, default: 1))
        } else {
            InstancedInterleavedBuffer()
        }
    }
    _installInterleavedBufferMembers(b, vm)
    b.property("meshPerAttribute",
        getter: Some({ref => LuaValue.of(ref.cast<InstancedInterleavedBuffer>().meshPerAttribute)}),
        setter: Some({ref, v => ref.cast<InstancedInterleavedBuffer>().meshPerAttribute = v.intValue()}))
    b.method("copy") {
        ref, args =>
            ref.cast<InstancedInterleavedBuffer>().copy(prebindAs<InstancedInterleavedBuffer>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<InstancedInterleavedBuffer>().clone(),
            "three.renderers.buffer.InstancedInterleavedBuffer")]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 InterleavedBufferAttribute 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.InterleavedBufferAttribute）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of InterleavedBufferAttribute
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.buffer.InterleavedBufferAttribute)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installInterleavedBufferAttribute(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.InterleavedBufferAttribute")
    // ===== 构造：无参，或 interleavedBuffer + itemSize + offset [+ normalized] =====
    b.constructor {
        args => if (args.size >= 3 && args[0].isObject) {
            InterleavedBufferAttribute(prebindAs<InterleavedBuffer>(args, 0), prebindInt(args, 1), prebindInt(args, 2),
                normalized: prebindBool(args, 3))
        } else {
            InterleavedBufferAttribute()
        }
    }
    // ===== 属性 =====
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBufferAttribute>().name)}),
        setter: Some({ref, v => ref.cast<InterleavedBufferAttribute>().name = v.stringValue()}))
    b.property("data", getter: Some({
        ref => prebindRegister(ref.cast<InterleavedBufferAttribute>().data, "three.renderers.buffer.InterleavedBuffer")
    }), setter: Some({
        ref, v => ref.cast<InterleavedBufferAttribute>().data = LuaObjectRegistry.getAs<InterleavedBuffer>(v.objectId())
    }))
    b.property("itemSize", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBufferAttribute>().itemSize)}),
        setter: Some({ref, v => ref.cast<InterleavedBufferAttribute>().itemSize = v.intValue()}))
    b.property("offset", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBufferAttribute>().offset)}),
        setter: Some({ref, v => ref.cast<InterleavedBufferAttribute>().offset = v.intValue()}))
    b.property("normalized", getter: Some({ref => LuaValue.of(ref.cast<InterleavedBufferAttribute>().normalized)}),
        setter: Some({ref, v => ref.cast<InterleavedBufferAttribute>().normalized = v.boolValue()}))
    // ===== 查询 =====
    b.method("count") {
        ref, _ => [LuaValue.of(ref.cast<InterleavedBufferAttribute>().count())]
    }
    b.method("array") {
        ref, _ => [LuaValue.of(ref.cast<InterleavedBufferAttribute>().array())]
    }
    b.method("setNeedsUpdate") {
        ref, args =>
            ref.cast<InterleavedBufferAttribute>().setNeedsUpdate(prebindBool(args, 0))
            Array<LuaValue>()
    }
    // ===== 矩阵变换 =====
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<InterleavedBufferAttribute>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyNormalMatrix") {
        ref, args =>
            ref.cast<InterleavedBufferAttribute>().applyNormalMatrix(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("transformDirection") {
        ref, args =>
            ref.cast<InterleavedBufferAttribute>().transformDirection(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 分量读写 =====
    b.method("getComponent") {
        ref, args => [LuaValue.of(
            ref.cast<InterleavedBufferAttribute>().getComponent(prebindInt(args, 0), prebindInt(args, 1)))]
    }
    b.method("setComponent") {
        ref, args =>
            ref
                .cast<InterleavedBufferAttribute>()
                .setComponent(prebindInt(args, 0), prebindInt(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("getX") {
        ref, args => [LuaValue.of(ref.cast<InterleavedBufferAttribute>().getX(prebindInt(args, 0)))]
    }
    b.method("setX") {
        ref, args =>
            ref.cast<InterleavedBufferAttribute>().setX(prebindInt(args, 0), prebindNum(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("getY") {
        ref, args => [LuaValue.of(ref.cast<InterleavedBufferAttribute>().getY(prebindInt(args, 0)))]
    }
    b.method("setY") {
        ref, args =>
            ref.cast<InterleavedBufferAttribute>().setY(prebindInt(args, 0), prebindNum(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("getZ") {
        ref, args => [LuaValue.of(ref.cast<InterleavedBufferAttribute>().getZ(prebindInt(args, 0)))]
    }
    b.method("setZ") {
        ref, args =>
            ref.cast<InterleavedBufferAttribute>().setZ(prebindInt(args, 0), prebindNum(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("getW") {
        ref, args => [LuaValue.of(ref.cast<InterleavedBufferAttribute>().getW(prebindInt(args, 0)))]
    }
    b.method("setW") {
        ref, args =>
            ref.cast<InterleavedBufferAttribute>().setW(prebindInt(args, 0), prebindNum(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("setXY") {
        ref, args =>
            ref.cast<InterleavedBufferAttribute>().setXY(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("setXYZ") {
        ref, args =>
            ref
                .cast<InterleavedBufferAttribute>()
                .setXYZ(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3))
            [LuaValue.Object(ref.id)]
    }
    b.method("setXYZW") {
        ref, args =>
            ref
                .cast<InterleavedBufferAttribute>()
                .setXYZW(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<InterleavedBufferAttribute>().clone(),
            "three.renderers.buffer.InterleavedBufferAttribute")]
    }
    b.install(vm)
}
