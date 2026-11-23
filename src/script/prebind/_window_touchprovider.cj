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
 * @file[zh-cn] window_touchprovider 触摸点与触摸提供者的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 TouchPoint 与 TouchProvider 绑定为 Lua 类型
 * @explain[zh-cn] TouchPoint：无参与全参构造 + 6 个可读写字段（fingerID/x/y/dx/dy/pressure）。
 * TouchProvider：无参构造、触摸查询（getTouchCount/getTouch/getTouchByID）、边沿列表
 * （getTouchesBegan 返回 TouchPoint 数组，getTouchesEnded 返回 fingerID 数组）与基类能力。
 * Option<TouchPoint> 返回值 None → nil。
 *
 * @file[en] window_touchprovider  Lua binding of the touch point and touch provider (three.script.prebind)
 * @brief[en] Binds TouchPoint and TouchProvider as Lua types
 * @explain[en] TouchPoint: no-arg and full-argument constructors plus six read-write fields
 * (fingerID/x/y/dx/dy/pressure). TouchProvider: no-arg constructor, touch queries
 * (getTouchCount/getTouch/getTouchByID), edge lists (getTouchesBegan returns a TouchPoint array,
 * getTouchesEnded returns a fingerID array) and the base-class capabilities.
 * Option<TouchPoint> returns None → nil.
 */
package three.script.prebind

import std.collection.ArrayList
import three.window.{TouchPoint, TouchProvider}
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 TouchPoint 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.TouchPoint）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TouchPoint
 * @param[en] vm The target virtual machine (class table installed at three.window.TouchPoint)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTouchPoint(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.TouchPoint")
    b.constructor {
        args => if (args.isEmpty()) {
            TouchPoint()
        } else {
            TouchPoint(fingerID: prebindInt(args, 0), x: Float32(prebindNum(args, 1)), y: Float32(prebindNum(args, 2)),
                dx: Float32(prebindNum(args, 3)), dy: Float32(prebindNum(args, 4)),
                pressure: Float32(prebindNum(args, 5)))
        }
    }
    b.property("fingerID", getter: Some({ref => LuaValue.of(ref.cast<TouchPoint>().fingerID)}),
        setter: Some({ref, v => ref.cast<TouchPoint>().fingerID = v.intValue()}))
    b.property("x", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchPoint>().x))}),
        setter: Some({ref, v => ref.cast<TouchPoint>().x = Float32(v.numberValue())}))
    b.property("y", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchPoint>().y))}),
        setter: Some({ref, v => ref.cast<TouchPoint>().y = Float32(v.numberValue())}))
    b.property("dx", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchPoint>().dx))}),
        setter: Some({ref, v => ref.cast<TouchPoint>().dx = Float32(v.numberValue())}))
    b.property("dy", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchPoint>().dy))}),
        setter: Some({ref, v => ref.cast<TouchPoint>().dy = Float32(v.numberValue())}))
    b.property("pressure", getter: Some({ref => LuaValue.of(Float64(ref.cast<TouchPoint>().pressure))}),
        setter: Some({
            ref, v => ref.cast<TouchPoint>().pressure = Float32(v.numberValue())
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 TouchProvider 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.TouchProvider）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TouchProvider
 * @param[en] vm The target virtual machine (class table installed at three.window.TouchProvider)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTouchProvider(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.TouchProvider")
    b.constructor {_ => TouchProvider()}
    b.method("getTouchCount") {
        ref, _ => [LuaValue.of(ref.cast<TouchProvider>().getTouchCount())]
    }
    b.method("getTouch") {
        ref, args => match (ref.cast<TouchProvider>().getTouch(prebindInt(args, 0))) {
            case Some(t) => [prebindRegister(t, "three.window.TouchPoint")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getTouchByID") {
        ref, args => match (ref.cast<TouchProvider>().getTouchByID(prebindInt(args, 0))) {
            case Some(t) => [prebindRegister(t, "three.window.TouchPoint")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getTouchesBegan") {
        ref, _ =>
            let items = ref.cast<TouchProvider>().getTouchesBegan()
            let n = items.size
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = prebindRegister(items[i], "three.window.TouchPoint")
            }
            [LuaValue.Array(out)]
    }
    b.method("getTouchesEnded") {
        ref, _ => [prebindI64ListToLua(ref.cast<TouchProvider>().getTouchesEnded())]
    }
    b.method("getWindow") {
        ref, _ => match (ref.cast<TouchProvider>().getWindow()) {
            case Some(w) => [prebindRegister(w, "three.window.WindowEngine")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("isBound") {ref, _ => [LuaValue.of(ref.cast<TouchProvider>().isBound())]}
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<TouchProvider>().release())]}
    b.install(vm)
}
