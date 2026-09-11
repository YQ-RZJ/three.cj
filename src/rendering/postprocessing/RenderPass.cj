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
 * @file[zh-cn] BgfxRenderPass 场景渲染 pass
 * @brief[zh-cn] 场景渲染 pass —— 把场景/相机渲染到 composer 的 readBuffer
 * @explain[zh-cn] 持有 scene + camera。render() 流程：
 *         1. bgfx_set_view_frame_buffer(viewId=0, readBuffer)：把主 view 输出指向 readBuffer
 *         2. bgfx_set_view_clear(0, COLOR|DEPTH, clearColor, 1.0, 0)
 *         3. renderer.render(scene, camera)：经 ThreeRenderer.render 委托 backend
 *         needsSwap=true（pass 后 composer 交换 buffer，下一 pass 从此读）。
 *         注意：本引擎 ThreeRenderer.render 内部委托到渲染线程，因此本 pass 的 render 仅设置
 *         view 0 的 frame buffer + clear，真正的场景绘制由 renderer.render(scene, camera) 完成。
 *
 * @file[en] BgfxRenderPass scene rendering pass
 * @brief[en] Scene rendering pass - renders the scene/camera into the composer's readBuffer
 * @explain[en] Holds scene + camera. render() flow:
 *         1. bgfx_set_view_frame_buffer(viewId=0, readBuffer): points the main view output to readBuffer
 *         2. bgfx_set_view_clear(0, COLOR|DEPTH, clearColor, 1.0, 0)
 *         3. renderer.render(scene, camera): delegated to the backend via ThreeRenderer.render
 *         needsSwap=true (composer swaps the buffer after this pass; the next pass reads from it).
 *         Note: ThreeRenderer.render internally delegates to the render thread, so this pass's render
 *         only sets view 0's frame buffer + clear; the actual scene drawing is done by renderer.render.
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.materials.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.utils.log.Logger
import three.rendering.types.*

/**
 * @brief[zh-cn] 场景渲染 pass
 * @brief[en] Scene rendering pass
 * @explain[zh-cn] 把 scene/camera 渲染到 composer 的 readBuffer。
 * @explain[en] Renders the scene/camera into the composer's readBuffer.
 */
public class RenderPass <: Pass {
    /**
     * @brief[zh-cn] 待渲染场景
     * @brief[en] Scene to render
     */
    public let scene: Scene

    /**
     * @brief[zh-cn] 待渲染相机
     * @brief[en] Camera to render with
     */
    public let camera: Camera

    /**
     * @brief[zh-cn] override material（可选）
     * @brief[en] Override material (optional)
     */
    public var overrideMaterial: Option<Material> = Option<Material>.None

    /**
     * @brief[zh-cn] clear color（可选）
     * @brief[en] Clear color (optional)
     */
    public var clearColor: Option<UInt32> = None

    /**
     * @brief[zh-cn] clear alpha（可选）
     * @brief[en] Clear alpha (optional)
     */
    public var clearAlpha: Option<Float64> = None

    /**
     * @brief[zh-cn] 是否清深度
     * @brief[en] Whether to clear the depth buffer
     */
    public var clearDepth: Bool = false

    /**
     * @brief[zh-cn] 构造 RenderPass
     * @brief[en] Constructs RenderPass
     * @param[zh-cn] scene 场景
     * @param[zh-cn] camera 相机
     * @param[en] scene Scene
     * @param[en] camera Camera
     */
    public init(scene: Scene, camera: Camera) {
        super()
        this.scene = scene
        this.camera = camera
        // RenderPass 默认 clear=true（每帧清 readBuffer）
        this.clear = true
        // 关键：RenderPass 不交换 buffer。
        // 场景画进 readBuffer 后保持 readBuffer=场景结果，下一 pass 从 readBuffer 采样场景。
        // 若设 needsSwap=true，swap 后 readBuffer 变成空 buffer → 后续 pass 从空 buffer 采样 → 全黑。
        this.needsSwap = false
    }

    /**
     * @brief[zh-cn] 渲染场景到 readBuffer
     * @brief[en] Renders the scene into the readBuffer
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（本 pass 不用）
     * @param[zh-cn] readBuffer 读 buffer（本 pass 的渲染目标）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (unused by this pass)
     * @param[en] readBuffer Read buffer (render target of this pass)
     * @param[en] deltaTime Frame delta time
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        // 1. 把主 view 0 的输出 frame buffer 指向 readBuffer（经渲染线程序列化）
        let clearColVal: UInt32 = match (this.clearColor) {
            case Some(c) => c
            case None => renderer.clearColor
        }
        renderer.setViewFrameBuffer(renderer.viewId, readBuffer)

        // 2. 设置 view 0 的 clear（颜色 + 深度）
        let clearFlags: UInt16 = BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH  // CLEAR_COLOR | CLEAR_DEPTH
        renderer.setViewClear(renderer.viewId, clearFlags, clearColVal, depth: 1.0f32, stencil: 0u8)

        // 3. 调 renderer.render 把场景绘制到 readBuffer
        //    renderer.render 内部走 _execBgfx 排队到渲染线程，
        //    view 0 frame buffer 已设为 readBuffer，场景输出写入 readBuffer。
        //    注意：不能把 renderer.render 放进 execBgfx 闭包，否则 _execBgfx 嵌套死锁。
        renderer.render(this.scene, this.camera)
    }
}
