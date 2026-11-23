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
 * @file[zh-cn] window_inputevent 输入事件数据类的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 KeyEvent / MouseMotionEvent / MouseButtonEvent / MouseWheelEvent /
 * WindowEvent / TouchEvent 绑定为 Lua 类型
 * @explain[zh-cn] 六个事件类均为纯数据类：构造参数齐全（按位置传参，缺省取类型默认值），
 * 全部字段以可读写属性暴露。字段语义与 Cangjie 一致（数值字段按 Float64/Int64 呈现）。
 * 跳过成员及原因：
 * - InputListener：Cangjie 侧 open 基类，且当前窗口引擎未提供注册入口
 *   （WindowEngine 无 addInputListener/removeInputListener），绑定后在 Lua 侧无法被调用，
 *   故不绑定；确需事件回调请使用 WindowEngine 的 bindOnXxx 与 InputEngine 轮询接口。
 *
 * @file[en] window_inputevent  Lua binding of the input event data classes (three.script.prebind)
 * @brief[en] Binds KeyEvent / MouseMotionEvent / MouseButtonEvent / MouseWheelEvent /
 * WindowEvent / TouchEvent as Lua types
 * @explain[en] All six are plain data classes: constructors take every field positionally
 * (type defaults apply when omitted), and every field is exposed as a read-write property.
 * Field semantics match Cangjie (numeric fields appear as Float64/Int64).
 * Skipped members and reasons:
 * - InputListener: an open base class on the Cangjie side, and the current window engine has no
 *   registration entry point (WindowEngine has no addInputListener/removeInputListener), so a
 *   bound listener could never be invoked from Lua. Use WindowEngine's bindOnXxx callbacks and the
 *   InputEngine polling APIs instead.
 */
package three.script.prebind

import three.window.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 KeyEvent 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.KeyEvent）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of KeyEvent
 * @param[en] vm The target virtual machine (class table installed at three.window.KeyEvent)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installKeyEvent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.KeyEvent")
    b.constructor {
        args => KeyEvent(scancode: UInt32(prebindInt(args, 0) & 0xFFFFFFFF), key: UInt32(prebindInt(args, 1) & 0xFFFFFFFF),
            mod: UInt16(prebindInt(args, 2) & 0xFFFF), down: prebindBool(args, 3), repeat: prebindBool(args, 4))
    }
    b.property("scancode", getter: Some({ref => LuaValue.of(Int64(ref.cast<KeyEvent>().scancode))}), setter: Some({
        ref, v => ref.cast<KeyEvent>().scancode = UInt32(v.intValue() & 0xFFFFFFFF)
    }))
    b.property("key", getter: Some({ref => LuaValue.of(Int64(ref.cast<KeyEvent>().key))}), setter: Some({
        ref, v => ref.cast<KeyEvent>().key = UInt32(v.intValue() & 0xFFFFFFFF)
    }))
    b.property("mod", getter: Some({ref => LuaValue.of(Int64(ref.cast<KeyEvent>().mod))}),
        setter: Some({ref, v => ref.cast<KeyEvent>().mod = UInt16(v.intValue() & 0xFFFF)}))
    b.property("down", getter: Some({ref => LuaValue.of(ref.cast<KeyEvent>().down)}),
        setter: Some({ref, v => ref.cast<KeyEvent>().down = v.boolValue()}))
    b.property("repeat", getter: Some({ref => LuaValue.of(ref.cast<KeyEvent>().repeat)}),
        setter: Some({ref, v => ref.cast<KeyEvent>().repeat = v.boolValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 MouseMotionEvent 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.MouseMotionEvent）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MouseMotionEvent
 * @param[en] vm The target virtual machine (class table installed at three.window.MouseMotionEvent)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMouseMotionEvent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.MouseMotionEvent")
    b.constructor {
        args => MouseMotionEvent(x: Float32(prebindNum(args, 0)), y: Float32(prebindNum(args, 1)),
            dx: Float32(prebindNum(args, 2)), dy: Float32(prebindNum(args, 3)))
    }
    b.property("x", getter: Some({ref => LuaValue.of(Float64(ref.cast<MouseMotionEvent>().x))}),
        setter: Some({ref, v => ref.cast<MouseMotionEvent>().x = Float32(v.numberValue())}))
    b.property("y", getter: Some({ref => LuaValue.of(Float64(ref.cast<MouseMotionEvent>().y))}),
        setter: Some({ref, v => ref.cast<MouseMotionEvent>().y = Float32(v.numberValue())}))
    b.property("dx", getter: Some({ref => LuaValue.of(Float64(ref.cast<MouseMotionEvent>().dx))}),
        setter: Some({ref, v => ref.cast<MouseMotionEvent>().dx = Float32(v.numberValue())}))
    b.property("dy", getter: Some({ref => LuaValue.of(Float64(ref.cast<MouseMotionEvent>().dy))}),
        setter: Some({ref, v => ref.cast<MouseMotionEvent>().dy = Float32(v.numberValue())}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 MouseButtonEvent 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.MouseButtonEvent）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MouseButtonEvent
 * @param[en] vm The target virtual machine (class table installed at three.window.MouseButtonEvent)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMouseButtonEvent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.MouseButtonEvent")
    b.constructor {
        args => MouseButtonEvent(button: UInt8(prebindInt(args, 0) & 0xFF), down: prebindBool(args, 1),
            clicks: UInt8(prebindInt(args, 2) & 0xFF), x: Float32(prebindNum(args, 3)), y: Float32(prebindNum(args, 4)))
    }
    b.property("button", getter: Some({ref => LuaValue.of(Int64(ref.cast<MouseButtonEvent>().button))}),
        setter: Some({
            ref, v => ref.cast<MouseButtonEvent>().button = UInt8(v.intValue() & 0xFF)
        }))
    b.property("down", getter: Some({ref => LuaValue.of(ref.cast<MouseButtonEvent>().down)}),
        setter: Some({ref, v => ref.cast<MouseButtonEvent>().down = v.boolValue()}))
    b.property("clicks", getter: Some({ref => LuaValue.of(Int64(ref.cast<MouseButtonEvent>().clicks))}),
        setter: Some({
            ref, v => ref.cast<MouseButtonEvent>().clicks = UInt8(v.intValue() & 0xFF)
        }))
    b.property("x", getter: Some({ref => LuaValue.of(Float64(ref.cast<MouseButtonEvent>().x))}),
        setter: Some({ref, v => ref.cast<MouseButtonEvent>().x = Float32(v.numberValue())}))
    b.property("y", getter: Some({ref => LuaValue.of(Float64(ref.cast<MouseButtonEvent>().y))}),
        setter: Some({ref, v => ref.cast<MouseButtonEvent>().y = Float32(v.numberValue())}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 MouseWheelEvent 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.MouseWheelEvent）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MouseWheelEvent
 * @param[en] vm The target virtual machine (class table installed at three.window.MouseWheelEvent)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMouseWheelEvent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.MouseWheelEvent")
    b.constructor {
        args => MouseWheelEvent(x: Float32(prebindNum(args, 0)), y: Float32(prebindNum(args, 1)))
    }
    b.property("x", getter: Some({ref => LuaValue.of(Float64(ref.cast<MouseWheelEvent>().x))}),
        setter: Some({ref, v => ref.cast<MouseWheelEvent>().x = Float32(v.numberValue())}))
    b.property("y", getter: Some({ref => LuaValue.of(Float64(ref.cast<MouseWheelEvent>().y))}),
        setter: Some({ref, v => ref.cast<MouseWheelEvent>().y = Float32(v.numberValue())}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 WindowEvent 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.WindowEvent）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of WindowEvent
 * @param[en] vm The target virtual machine (class table installed at three.window.WindowEvent)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installWindowEvent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.WindowEvent")
    b.constructor {
        args => WindowEvent(`type`: UInt32(prebindInt(args, 0) & 0xFFFFFFFF), data1: Int32(prebindInt(args, 1)),
            data2: Int32(prebindInt(args, 2)))
    }
    b.property("type", getter: Some({ref => LuaValue.of(Int64(ref.cast<WindowEvent>().`type`))}), setter: Some({
        ref, v => ref.cast<WindowEvent>().`type` = UInt32(v.intValue() & 0xFFFFFFFF)
    }))
    b.property("data1", getter: Some({ref => LuaValue.of(Int64(ref.cast<WindowEvent>().data1))}),
        setter: Some({ref, v => ref.cast<WindowEvent>().data1 = Int32(v.intValue())}))
    b.property("data2", getter: Some({ref => LuaValue.of(Int64(ref.cast<WindowEvent>().data2))}),
        setter: Some({ref, v => ref.cast<WindowEvent>().data2 = Int32(v.intValue())}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 TouchEvent 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.TouchEvent）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TouchEvent
 * @param[en] vm The target virtual machine (class table installed at three.window.TouchEvent)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTouchEvent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.TouchEvent")
    b.constructor {
        args => TouchEvent(fingerID: prebindInt(args, 0), x: Float32(prebindNum(args, 1)),
            y: Float32(prebindNum(args, 2)), dx: Float32(prebindNum(args, 3)), dy: Float32(prebindNum(args, 4)),
            pressure: Float32(prebindNum(args, 5)))
    }
    b.property("fingerID", getter: Some({ref => LuaValue.of(ref.cast<TouchEvent>().fingerID)}),
        setter: Some({ref, v => ref.cast<TouchEvent>().fingerID = v.intValue()}))
    b.property("x", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchEvent>().x))}),
        setter: Some({ref, v => ref.cast<TouchEvent>().x = Float32(v.numberValue())}))
    b.property("y", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchEvent>().y))}),
        setter: Some({ref, v => ref.cast<TouchEvent>().y = Float32(v.numberValue())}))
    b.property("dx", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchEvent>().dx))}),
        setter: Some({ref, v => ref.cast<TouchEvent>().dx = Float32(v.numberValue())}))
    b.property("dy", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchEvent>().dy))}),
        setter: Some({ref, v => ref.cast<TouchEvent>().dy = Float32(v.numberValue())}))
    b.property("pressure", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchEvent>().pressure))}),
        setter: Some({
            ref, v => ref.cast<TouchEvent>().pressure = Float32(v.numberValue())
        }))
    b.install(vm)
}
