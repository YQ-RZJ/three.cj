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
 * @file[zh-cn] BgfxFXAAPass FXAA 后处理 pass
 * @brief[zh-cn] FXAA 后处理 pass —— 喂 fxaa shader 的 ShaderPass 子类
 * @explain[zh-cn] 直接继承 ShaderPass，shaderName = "fxaa"（ShaderLibs.cj 已注册）。
 *         构造时 textureID = "tDiffuse"。
 *         render 完全复用父类 ShaderPass.render（取 shader + 编译 + 绑 readBuffer + submit），
 *         仅 override bindExtraUniforms 在 submit 前设置 u_resolution.xy = (1/width, 1/height)。
 *         needsSwap=true（pass 后 composer 交换 buffer，下一 pass 从此读）。
 *
 * @file[en] BgfxFXAAPass FXAA post-processing pass
 * @brief[en] FXAA post-processing pass - a ShaderPass subclass feeding the fxaa shader
 * @explain[en] Directly extends ShaderPass with shaderName = "fxaa" (registered in ShaderLibs.cj).
 *         Uses textureID = "tDiffuse" at construction.
 *         render fully reuses the parent ShaderPass.render (fetch shader + compile + bind readBuffer + submit),
 *         only overriding bindExtraUniforms to set u_resolution.xy = (1/width, 1/height) before submit.
 *         needsSwap=true (composer swaps the buffer after this pass; the next pass reads from it).
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*

/**
 * @brief[zh-cn] FXAA 后处理 pass
 * @explain[zh-cn] 喂 ShaderLibs 已注册的 "fxaa" 全屏 shader，复用父类 ShaderPass.render。
 *
 * @brief[en] FXAA post-processing pass
 * @explain[en] Feeds the registered "fxaa" full-screen shader in ShaderLibs and reuses the parent ShaderPass.render.
 */
public class FXAAPass <: ShaderPass {
    /**
     * @brief[zh-cn] 构造 FXAAPass
     * @explain[zh-cn] 全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。
     *
     * @brief[en] Constructs FXAAPass
     * @explain[en] The full-screen quad is held as a singleton by EffectComposer and injected via setQuad (base class quad field).
     */
    public init() {
        super("fxaa", textureID: "tDiffuse")
        // FXAAPass 默认 needsSwap=true
        this.needsSwap = true
        // 终结器兜底：GC 回收时自动执行 dispose()（函数值捕获 this，非 open 类构造器允许）
        this._finalizerFallback = Some({ => let _ = this.release() })
    }

    /**
     * @brief[zh-cn] 在父类 render 的 submit 前绑定额外 uniform：u_resolution.xy = 1/width, 1/height
     * @explain[zh-cn] 每帧在 execBgfx 闭包内调用（bgfx uniform 需每次 submit 前重新 set）。
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] uniforms 父类已创建 tDiffuse sampler 的 uniform 注册表（复用同一实例）
     *
     * @brief[en] Binds the extra uniform before the parent render's submit: u_resolution.xy = 1/width, 1/height
     * @explain[en] Called every frame inside the execBgfx closure (bgfx uniforms must be re-set before each submit).
     * @param[en] renderer The renderer
     * @param[en] uniforms The uniform registry where the parent has created the tDiffuse sampler (reused instance)
     */
    public override func bindExtraUniforms(renderer: ThreeRenderer, uniforms: BgfxUniforms): Unit {
        let rw = renderer.width
        let rh = renderer.height
        let invW: Float32 = if (rw > 0) { 1.0f32 / Float32(rw) } else { 0.0f32 }
        let invH: Float32 = if (rh > 0) { 1.0f32 / Float32(rh) } else { 0.0f32 }
        // 句柄按名缓存（首次创建后复用，省去每帧 createUniform 的全局锁 + 字符串哈希）
        let uRes = this._cachedUniform("u_resolution", UniformType.Vec4.value())
        // 复用基类上传缓冲槽位（原实现每帧新建 BgfxMemory + 数组字面量）
        this._setVec2Uniform(renderer, uRes, 0, Float64(invW), Float64(invH))
    }
}
