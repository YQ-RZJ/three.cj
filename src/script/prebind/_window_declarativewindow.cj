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
 * @file[zh-cn] window_declarativewindow 声明式窗口门面的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.Window（声明式门面）绑定为 Lua 类型 three.window.Window
 * @explain[zh-cn] 绑定构造（title/width/height/可选 config）、链式声明（renderWith / ui / onInit /
 * onCtxtInit / onFrame / onResize / onClose / onDestroy）、生命周期（show / wait / close / run /
 * release）与状态查询（started / isCloseRequested / width / height / getEngine）。
 * 适配约定：
 * - Cangjie 构造要求 build 闭包；Lua 侧创建时内部传空实现，声明逻辑由 Lua 门面
 *   （resources/lua/three/window.lua）在 new 之后调用声明函数完成，语义等价；
 * - 所有声明方法接收 Lua 函数并返回自身（可链式）；可多次声明（按序执行）；
 * - release() 会同时释放本对象持有的全部 Lua 函数引用。
 * @attention[zh-cn] 声明回调在窗口泵线程执行（ui 体必须在 ImGui NewFrame..Render 之间执行，
 * 这是唯一正确时机）。Lua 侧应在主线程阻塞于 wait()/run()，由泵线程独占 Lua 状态；
 * 不要在另一线程并发操作同一 LuaVM。
 * 跳过成员及原因：
 * - 构造的 build 参数：见上方适配约定（由 Lua 门面等价实现）。
 *
 * @file[en] window_declarativewindow  Lua binding of the declarative window facade (three.script.prebind)
 * @brief[en] Binds three.window.Window (the declarative facade) as the Lua type three.window.Window
 * @explain[en] Binds construction (title/width/height/optional config), chained declarations
 * (renderWith / ui / onInit / onCtxtInit / onFrame / onResize / onClose / onDestroy), the lifecycle
 * (show / wait / close / run / release) and state queries (started / isCloseRequested / width /
 * height / getEngine).
 * Adaptation rules:
 * - the Cangjie constructor requires a build closure; creation from Lua passes an empty
 *   implementation and the Lua facade (resources/lua/three/window.lua) invokes the declaration
 *   function after new, which is semantically equivalent;
 * - every declaration method takes a Lua function and returns itself (chainable); multiple
 *   declarations run in order;
 * - release() also releases every Lua function reference held by this object.
 * @attention[en] Declaration callbacks run on the window pump thread (the ui body must run between
 * ImGui NewFrame..Render, the only correct timing). On the Lua side, block the main thread in
 * wait()/run() so the pump thread owns the Lua state; never touch the same LuaVM concurrently
 * from another thread.
 * Skipped members and reasons:
 * - the constructor's build parameter: see the adaptation rule above (implemented equivalently by
 *   the Lua facade).
 */
package three.script.prebind

import std.collection.*
import three.window.{Window, WindowConfig}
import three.renderers.ThreeRenderer
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 声明式窗口持有的 Lua 回调引用（键 = 对象 id）
 *
 * @brief[en] Lua callback references held by declarative windows (key = object id)
 */
private let _prebindDeclWindowCallbacks: HashMap<Int64, ArrayList<LuaCallback>> = HashMap<Int64, ArrayList<LuaCallback>>()

/**
 * @brief[zh-cn] 记录一个由声明式窗口持有的 Lua 回调
 * @param[zh-cn] id 对象注册表 id
 * @param[zh-cn] cb 回调
 *
 * @brief[en] Records a Lua callback owned by a declarative window
 * @param[en] id The object registry id
 * @param[en] cb The callback
 */
private func _prebindDeclWindowOwn(id: Int64, cb: LuaCallback): Unit {
    match (_prebindDeclWindowCallbacks.get(id)) {
        case Some(list) => list.add(cb)
        case None =>
            let list = ArrayList<LuaCallback>()
            list.add(cb)
            _prebindDeclWindowCallbacks.add(id, list)
    }
}

/**
 * @brief[zh-cn] 释放声明式窗口持有的全部 Lua 回调
 * @param[zh-cn] id 对象注册表 id
 *
 * @brief[en] Releases every Lua callback owned by a declarative window
 * @param[en] id The object registry id
 */
private func _prebindDeclWindowRelease(id: Int64): Unit {
    if (let Some(list) <- _prebindDeclWindowCallbacks.remove(id)) {
        for (cb in list) {
            cb.release()
        }
    }
}

/**
 * @brief[zh-cn] 安装声明式窗口 Window 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.Window）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the declarative Window
 * @param[en] vm The target virtual machine (class table installed at three.window.Window)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installDeclarativeWindow(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.Window")
    // ===== 构造：title, width, height, [config] =====
    b.constructor {
        args =>
            let title = prebindStr(args, 0)
            let w = Int32(prebindInt(args, 1))
            let h = Int32(prebindInt(args, 2))
            let cfg = if (args.size >= 4 && args[3].isObject) {
                prebindAsValue<WindowConfig>(args[3])
            } else {
                WindowConfig()
            }
            Window(title: title, width: w, height: h, config: cfg, build: {_ =>})
    }
    // ===== 声明式构建（链式，返回自身） =====
    b.method("renderWith") {
        ref, args =>
            ref.cast<Window>().renderWith(prebindAs<ThreeRenderer>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("ui") {
        ref, args =>
            match (prebindOptCallback(vm, args, 0)) {
                case Some(cb) =>
                    _prebindDeclWindowOwn(ref.id, cb)
                    ref.cast<Window>().ui({
                        => try {
                            let _ = cb.call()
                        } catch (_) {}
                    })
                case None => ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("onInit") {
        ref, args =>
            match (prebindOptCallback(vm, args, 0)) {
                case Some(cb) =>
                    _prebindDeclWindowOwn(ref.id, cb)
                    ref.cast<Window>().onInit({
                        => try {
                            let _ = cb.call()
                        } catch (_) {}
                    })
                case None => ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("onCtxtInit") {
        ref, args =>
            match (prebindOptCallback(vm, args, 0)) {
                case Some(cb) =>
                    _prebindDeclWindowOwn(ref.id, cb)
                    ref.cast<Window>().onCtxtInit({
                        => try {
                            let _ = cb.call()
                        } catch (_) {}
                    })
                case None => ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("onFrame") {
        ref, args =>
            match (prebindOptCallback(vm, args, 0)) {
                case Some(cb) =>
                    _prebindDeclWindowOwn(ref.id, cb)
                    ref.cast<Window>().onFrame({
                        dt: Float64 => try {
                            let _ = cb.call(args: [LuaValue.of(dt)])
                        } catch (_) {}
                    })
                case None => ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("onResize") {
        ref, args =>
            match (prebindOptCallback(vm, args, 0)) {
                case Some(cb) =>
                    _prebindDeclWindowOwn(ref.id, cb)
                    ref.cast<Window>().onResize({
                        w: Int32, h: Int32 => try {
                            let _ = cb.call(args: [LuaValue.of(Int64(w)), LuaValue.of(Int64(h))])
                        } catch (_) {}
                    })
                case None => ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("onClose") {
        ref, args =>
            match (prebindOptCallback(vm, args, 0)) {
                case Some(cb) =>
                    _prebindDeclWindowOwn(ref.id, cb)
                    ref.cast<Window>().onClose({
                        => try {
                            let _ = cb.call()
                        } catch (_) {}
                    })
                case None => ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("onDestroy") {
        ref, args =>
            match (prebindOptCallback(vm, args, 0)) {
                case Some(cb) =>
                    _prebindDeclWindowOwn(ref.id, cb)
                    ref.cast<Window>().onDestroy({
                        => try {
                            let _ = cb.call()
                        } catch (_) {}
                    })
                case None => ()
            }
            [LuaValue.Object(ref.id)]
    }
    // ===== 生命周期 =====
    b.method("show") {ref, _ => [LuaValue.of(ref.cast<Window>().show())]}
    b.method("wait") {
        ref, _ =>
            ref.cast<Window>().wait()
            []
    }
    b.method("close") {
        ref, _ =>
            ref.cast<Window>().close()
            []
    }
    b.method("run") {
        ref, _ =>
            ref.cast<Window>().run()
            []
    }
    b.method("release") {
        ref, _ =>
            _prebindDeclWindowRelease(ref.id)
            [LuaValue.of(ref.cast<Window>().release())]
    }
    // ===== 状态查询 =====
    b.property("started", getter: Some({ref => LuaValue.of(ref.cast<Window>().started)}))
    b.property("isCloseRequested", getter: Some({ref => LuaValue.of(ref.cast<Window>().isCloseRequested)}))
    b.property("width", getter: Some({ref => LuaValue.of(Int64(ref.cast<Window>().width))}))
    b.property("height", getter: Some({ref => LuaValue.of(Int64(ref.cast<Window>().height))}))
    b.method("getEngine") {
        ref, _ => [prebindRegister(ref.cast<Window>().getEngine(), "three.window.WindowEngine")]
    }
    b.install(vm)
}
