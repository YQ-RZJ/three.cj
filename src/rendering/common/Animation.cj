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
 * @file[zh-cn] 动画
 * @brief[zh-cn] 渲染通用动画类，管理动画回调与帧更新
 * @explain[zh-cn] 
 * Animation 封装了动画循环的回调机制，对应 Three.js 渲染器中的 Animation 调度模块。
 * 通过 setAnimationLoop 注册回调函数，由渲染器每帧调用 update 驱动动画。
 *
 * @file[en] Animation
 * @brief[en] Rendering common animation class, managing animation callbacks and frame updates
 * @explain[en] 
 * Animation encapsulates the callback mechanism for animation loops, corresponding to the Animation scheduling module in the Three.js renderer.
 * Register a callback via setAnimationLoop, and the renderer calls update each frame to drive the animation.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 渲染通用动画类，管理动画回调与帧更新
 * @explain[zh-cn] 
 * 封装动画 ID、回调函数以及 start/stop/update 生命周期方法，
 * 由 Renderer 每帧调用 update(delta) 驱动用户回调。
 *
 * @brief[en] Rendering common animation class, managing animation callbacks and frame updates
 * @explain[en] 
 * Encapsulates animation ID, callback function, and start/stop/update lifecycle methods.
 * The Renderer calls update(delta) each frame to drive the user callback.
 */
public open class Animation {
    /**
     * @brief[zh-cn] 动画标识符
     *
     * @brief[en] Animation identifier
     */
    public var id: Int64

    /**
     * @brief[zh-cn] 动画回调函数，参数为帧间隔时间（秒）
     *
     * @brief[en] Animation callback function, parameter is frame delta time (seconds)
     */
    public var callback: (Float64) -> Unit

    /**
     * @brief[zh-cn] 构造默认动画实例
     *
     * @brief[en] Constructs a default animation instance
     */
    public init() { this.id = 0; this.callback = { _ => } }

    /**
     * @brief[zh-cn] 启动动画
     *
     * @brief[en] Starts the animation
     */
    public func start(): Unit { }

    /**
     * @brief[zh-cn] 停止动画
     *
     * @brief[en] Stops the animation
     */
    public func stop(): Unit { }

    /**
     * @brief[zh-cn] 每帧更新动画，调用回调函数
     * @param[zh-cn] delta 帧间隔时间（秒）
     *
     * @brief[en] Updates the animation each frame, invoking the callback
     * @param[en] delta Frame delta time (seconds)
     */
    public func update(delta: Float64): Unit { this.callback(delta) }

    /**
     * @brief[zh-cn] 设置动画循环回调函数
     * @param[zh-cn] cb 动画回调函数
     *
     * @brief[en] Sets the animation loop callback function
     * @param[en] cb Animation callback function
     */
    public func setAnimationLoop(cb: (Float64) -> Unit): Unit { this.callback = cb }
}
