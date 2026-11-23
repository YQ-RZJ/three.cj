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
 * @file[zh-cn] renderers_buffer_glattribute GLBufferAttribute / InstancedBufferAttribute
 * 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.buffer 的 GLBufferAttribute 与
 * InstancedBufferAttribute 绑定为 Lua 类型
 * @explain[zh-cn] - GLBufferAttribute：name / kind / itemSize / elementSize / count /
 *   normalized / version 可读写，setNeedsUpdate / getNeedsUpdate / setType / setItemSize /
 *   setCount；buffer 属性为 GPU 句柄，Lua 侧以整数索引读写（getter 经 Handle.idx 取值，
 *   setter 经 Handle.vertexBuffer(idx) 还原），构造默认使用无效句柄（Lua 无 handle 通道）。
 * - InstancedBufferAttribute：继承 BufferAttribute，附加 meshPerAttribute 属性与 copy；
 *   基类成员由 _installBufferAttributeMembers 重复登记。
 *
 * @file[en] renderers_buffer_glattribute  Lua bindings of GLBufferAttribute /
 * InstancedBufferAttribute (three.script.prebind)
 * @brief[en] Binds three.renderers.buffer's GLBufferAttribute and InstancedBufferAttribute
 * as Lua types
 * @explain[en] - GLBufferAttribute: name / kind / itemSize / elementSize / count / normalized /
 *   version are read-write, plus setNeedsUpdate / getNeedsUpdate / setType / setItemSize /
 *   setCount; the buffer property is a GPU handle, exposed to Lua as an integer index (the
 *   getter goes through Handle.idx, the setter restores it via Handle.vertexBuffer(idx)), and
 *   the constructor starts from an invalid handle (Lua has no raw handle channel);
 * - InstancedBufferAttribute: extends BufferAttribute with the meshPerAttribute property and
 *   copy; the base members are re-registered by _installBufferAttributeMembers.
 */
package three.script.prebind

import three.renderers.buffer.GLBufferAttribute
import three.renderers.buffer.InstancedBufferAttribute
import three.renderers.common.GfxVertexBufferHandle
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 GLBufferAttribute 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.GLBufferAttribute）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GLBufferAttribute
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.buffer.GLBufferAttribute)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGLBufferAttribute(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.GLBufferAttribute")
    // ===== 构造（Lua 无原始句柄通道：以无效句柄起步，buffer 属性按整数索引读写） =====
    b.constructor { args =>
        GLBufferAttribute(
            GfxVertexBufferHandle.INVALID,
            kind: prebindInt(args, 0),
            itemSize: prebindInt(args, 1),
            elementSize: prebindInt(args, 2),
            count: prebindInt(args, 3),
            normalized: prebindBool(args, 4))
    }
    // ===== 属性 =====
    b.property("buffer",
        getter: Some({ ref => LuaValue.of(Int64(ref.cast<GLBufferAttribute>().buffer.idx)) }),
        setter: Some({ ref, v =>
            ref.cast<GLBufferAttribute>().buffer = GfxVertexBufferHandle(UInt16(v.intValue()))
        }))
    b.property("name",
        getter: Some({ ref => LuaValue.of(ref.cast<GLBufferAttribute>().name) }),
        setter: Some({ ref, v => ref.cast<GLBufferAttribute>().name = v.stringValue() }))
    b.property("kind",
        getter: Some({ ref => LuaValue.of(ref.cast<GLBufferAttribute>().kind) }),
        setter: Some({ ref, v => ref.cast<GLBufferAttribute>().kind = v.intValue() }))
    b.property("itemSize",
        getter: Some({ ref => LuaValue.of(ref.cast<GLBufferAttribute>().itemSize) }),
        setter: Some({ ref, v => ref.cast<GLBufferAttribute>().itemSize = v.intValue() }))
    b.property("elementSize",
        getter: Some({ ref => LuaValue.of(ref.cast<GLBufferAttribute>().elementSize) }),
        setter: Some({ ref, v => ref.cast<GLBufferAttribute>().elementSize = v.intValue() }))
    b.property("count",
        getter: Some({ ref => LuaValue.of(ref.cast<GLBufferAttribute>().count) }),
        setter: Some({ ref, v => ref.cast<GLBufferAttribute>().count = v.intValue() }))
    b.property("normalized",
        getter: Some({ ref => LuaValue.of(ref.cast<GLBufferAttribute>().normalized) }),
        setter: Some({ ref, v => ref.cast<GLBufferAttribute>().normalized = v.boolValue() }))
    b.property("version",
        getter: Some({ ref => LuaValue.of(ref.cast<GLBufferAttribute>().version) }),
        setter: Some({ ref, v => ref.cast<GLBufferAttribute>().version = v.intValue() }))
    // ===== 上传标记与配置 =====
    b.method("setNeedsUpdate") { ref, args =>
        ref.cast<GLBufferAttribute>().setNeedsUpdate(prebindBool(args, 0))
        Array<LuaValue>()
    }
    b.method("getNeedsUpdate") { ref, _ =>
        [LuaValue.of(ref.cast<GLBufferAttribute>().getNeedsUpdate())]
    }
    b.method("setType") { ref, args =>
        ref.cast<GLBufferAttribute>().setType(prebindInt(args, 0), prebindInt(args, 1))
        [LuaValue.Object(ref.id)]
    }
    b.method("setItemSize") { ref, args =>
        ref.cast<GLBufferAttribute>().setItemSize(prebindInt(args, 0))
        [LuaValue.Object(ref.id)]
    }
    b.method("setCount") { ref, args =>
        ref.cast<GLBufferAttribute>().setCount(prebindInt(args, 0))
        [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 InstancedBufferAttribute 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.buffer.InstancedBufferAttribute）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of InstancedBufferAttribute
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.buffer.InstancedBufferAttribute)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installInstancedBufferAttribute(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.buffer.InstancedBufferAttribute")
    b.constructor { args =>
        if (args.size >= 2 && !args[0].isNil) {
            InstancedBufferAttribute(prebindFloatArray(vm, args, 0), prebindInt(args, 1),
                normalized: prebindBool(args, 2),
                meshPerAttribute: prebindInt(args, 3, default: 1))
        } else {
            InstancedBufferAttribute()
        }
    }
    // ===== BufferAttribute 基类成员 =====
    _installBufferAttributeMembers(b, vm)
    // ===== 实例化附加成员 =====
    b.property("meshPerAttribute",
        getter: Some({ ref => LuaValue.of(ref.cast<InstancedBufferAttribute>().meshPerAttribute) }),
        setter: Some({ ref, v => ref.cast<InstancedBufferAttribute>().meshPerAttribute = v.intValue() }))
    b.method("copy") { ref, args =>
        ref.cast<InstancedBufferAttribute>().copy(prebindAs<InstancedBufferAttribute>(args, 0))
        [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
