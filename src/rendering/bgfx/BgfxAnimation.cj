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
 * @file[zh-cn] bgfx 动画管理
 * @brief[zh-cn] 替代 WebGLAnimation，管理动画循环
 * @explain[zh-cn] 对照源码: three.js/src/renderers/webgl/WebGLAnimation.js。WebGLAnimation 负责管理 requestAnimationFrame 循环。bgfx 版本提供类似的动画循环接口。
 *
 * @file[en] bgfx Animation Manager
 * @brief[en] Replace WebGLAnimation, manage animation loop
 * @explain[en] Mirrors three.js/src/renderers/webgl/WebGLAnimation.js. WebGLAnimation manages the requestAnimationFrame loop. The bgfx version provides a similar animation loop interface.
 */
package three.rendering.bgfx

/**
 * @brief[zh-cn] 动画回调类型
 *
 * @brief[en] Animation callback type
 */
public type AnimationCallback = () -> Unit

/**
 * @brief[zh-cn] bgfx 动画管理
 * @explain[zh-cn] 对照 WebGLAnimation，管理动画循环。提供启动/停止动画循环的接口。
 *
 * @brief[en] bgfx animation manager
 * @explain[en] Mirrors WebGLAnimation, managing the animation loop. Provides start/stop animation loop interfaces.
 */
public class BgfxAnimation {
    /**
     * @brief[zh-cn] 动画回调
     *
     * @brief[en] Animation callback
     */
    private var callback: Option<AnimationCallback> = None
    /**
     * @brief[zh-cn] 是否正在运行
     *
     * @brief[en] Whether the animation is running
     */
    private var running: Bool = false
    /**
     * @brief[zh-cn] 动画帧 ID
     *
     * @brief[en] Animation frame ID
     */
    private var animationFrameId: Int64 = 0

    public init() {}

    /**
     * @brief[zh-cn] 设置动画回调
     * @param[zh-cn] cb 动画回调函数
     *
     * @brief[en] Set animation callback
     * @param[en] cb Animation callback function
     */
    public func setCallback(cb: AnimationCallback): Unit {
        callback = cb
    }

    /**
     * @brief[zh-cn] 启动动画循环
     * @explain[zh-cn] 对照 WebGLAnimation.start()
     *
     * @brief[en] Start animation loop
     * @explain[en] Mirrors WebGLAnimation.start()
     */
    public func start(): Unit {
        if (!running) {
            running = true
            // bgfx 的动画循环由外部驱动（如窗口消息循环）
            // 此处仅标记为运行状态
        }
    }

    /**
     * @brief[zh-cn] 停止动画循环
     * @explain[zh-cn] 对照 WebGLAnimation.stop()
     *
     * @brief[en] Stop animation loop
     * @explain[en] Mirrors WebGLAnimation.stop()
     */
    public func stop(): Unit {
        running = false
        animationFrameId = 0
    }

    /**
     * @brief[zh-cn] 是否正在运行
     * @return[zh-cn] 是否正在运行
     *
     * @brief[en] Check if animation is running
     * @return[en] Whether the animation is running
     */
    public func isRunning(): Bool {
        return running
    }

    /**
     * @brief[zh-cn] 执行一帧动画
     * @explain[zh-cn] 在外部循环中调用此方法驱动动画
     *
     * @brief[en] Execute one animation frame
     * @explain[en] Call this method in the external loop to drive animation
     */
    public func tick(): Unit {
        if (running) {
            match (callback) {
                case Some(cb) => cb()
                case None => ()
            }
        }
    }
}
