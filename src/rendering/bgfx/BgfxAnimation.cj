/**
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
     */
    private var callback: Option<AnimationCallback> = None
    /**
     * @brief[zh-cn] 是否正在运行
     */
    private var running: Bool = false
    /**
     * @brief[zh-cn] 动画帧 ID
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
