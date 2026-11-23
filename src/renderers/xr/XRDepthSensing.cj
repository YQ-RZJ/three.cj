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
 * @file[zh-cn] XRDepthSensing XR 深度感知
 * @brief[zh-cn] 对照 WebXRDepthSensing.js，提供深度感知数据
 * WebXRDepthSensing 管理 XR 深度纹理和深度网格。
 * bgfx 版本使用 GfxTextureHandle 替代 WebGL 纹理。
 *
 * @file[en] XRDepthSensing XR depth sensing
 * @brief[en] Provides depth sensing data, corresponding to WebXRDepthSensing.js
 * WebXRDepthSensing manages XR depth textures and depth meshes.
 * bgfx version uses GfxTextureHandle instead of WebGL textures.
 *
 * @package three.renderers.xr
 */
package three.renderers.xr

import three.utils.safe.IReleasable
import three.renderers._gfx.GfxTextureHandle
import three.renderers.ThreeRenderer
import three.renderers.buffer.*
import three.renderers.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.renderers.rendertarget.*
import three.core.event.*
import three.renderers.geometry.PlaneGeometry
import three.renderers.materials.ShaderMaterial
import three.scene.entity.Mesh
import std.collection.*
import three.utils.log.*
import three.utils.log.macros.*


// 深度遮挡可视化着色器：顶点直接输出 position，片段按 gl_FragCoord 采样 sampler2DArray 深度纹理写 gl_FragDepth。
// 仓颉多行字符串用 #"..."#（raw 多行字符串），对照 ShaderChunk/*.cj 既有语法。
private const _occlusion_vertex = #"
void main() {

	gl_Position = vec4( position, 1.0 );

}

"#

private const _occlusion_fragment = #"
uniform sampler2DArray depthColor;
uniform float depthWidth;
uniform float depthHeight;

void main() {

	vec2 coord = vec2( gl_FragCoord.x / depthWidth, gl_FragCoord.y / depthHeight );

	if ( coord.x >= 1.0 ) {

		gl_FragDepth = texture( depthColor, vec3( coord.x - 1.0, coord.y, 1 ) ).r;

	} else {

		gl_FragDepth = texture( depthColor, vec3( coord.x, coord.y, 0 ) ).r;

	}

}

"#

/**
 * @brief[zh-cn] XR 深度感知
 * @explain[zh-cn] 对照 WebXRDepthSensing，管理 XR 深度纹理和深度网格。
 * bgfx 版本使用 GfxTextureHandle 替代 WebGL 纹理。
 *
 * @brief[en] XR depth sensing
 * @explain[en] Corresponding to WebXRDepthSensing, manages XR depth textures and depth meshes.
 * bgfx version uses GfxTextureHandle instead of WebGL textures.
 */
public class XRDepthSensing <: IReleasable {
    /**
     * @brief[zh-cn] 深度纹理句柄
     *
     * @brief[en] Depth texture handle
     */
    private var _texture: GfxTextureHandle
    /**
     * @brief[zh-cn] 深度网格（PlaneGeometry + occlusion ShaderMaterial）
     *
     * @brief[en] Depth mesh (PlaneGeometry + occlusion ShaderMaterial)
     */
    private var _mesh: Option<Mesh>
    /**
     * @brief[zh-cn] 深度近值
     *
     * @brief[en] Depth near value
     */
    private var depthNear: Float64 = 0.0
    /**
     * @brief[zh-cn] 深度远值
     *
     * @brief[en] Depth far value
     */
    private var depthFar: Float64 = 0.0
    /**
     * @brief[zh-cn] 深度宽度
     *
     * @brief[en] Depth width
     */
    private var depthWidth: Int64 = 0
    /**
     * @brief[zh-cn] 深度高度
     *
     * @brief[en] Depth height
     */
    private var depthHeight: Int64 = 0
    /**
     * @brief[zh-cn] 是否可用
     *
     * @brief[en] Whether available
     */
    private var _available: Bool = false
    /**
     * @brief[zh-cn] 关联的渲染器（深度纹理经其销毁通道释放）
     *
     * @brief[en] Associated renderer (the depth texture is released through its destroy channel)
     */
    private var _renderer: Option<ThreeRenderer> = None

    public init() {
        this._texture = GfxTextureHandle.INVALID
        this._mesh = None
    }

    /**
     * @brief[zh-cn] 获取深度纹理
     * @return[zh-cn] 深度纹理句柄
     *
     * @brief[en] Get depth texture
     * @return[en] Depth texture handle
     */
    /**
     * @brief[zh-cn] 深度纹理句柄索引（只读裸值；画面内调试打印用途）
     *
     * @brief[en] Depth texture handle index (read-only plain value; for on-screen debug printing)
     */
    public func getTextureIdx(): UInt16 {
        return this._texture.idx
    }

    protected func getTexture(): GfxTextureHandle {
        return _texture
    }

    /**
     * @brief[zh-cn] 设置深度纹理
     * @param[zh-cn] texture 深度纹理句柄
     *
     * @brief[en] Set depth texture
     * @param[en] texture Depth texture handle
     */
    protected func setTexture(texture: GfxTextureHandle): Unit {
        this._texture = texture
    }

    /**
     * @brief[zh-cn] 绑定渲染器（深度纹理销毁经其下发到后端）
     * @param[zh-cn] renderer 渲染器实例
     * @return[zh-cn] 自身（链式调用）
     *
     * @brief[en] Binds the renderer (depth texture destruction is issued to the backend through it)
     * @param[en] renderer Renderer instance
     * @return[en] Self (for chaining)
     */
    public func bindRenderer(renderer: ThreeRenderer): XRDepthSensing {
        this._renderer = Some(renderer)
        return this
    }

    /**
     * @brief[zh-cn] 获取深度网格
     * @explain[zh-cn] 用 PlaneGeometry(20,20) + occlusion ShaderMaterial 构建，
     * uniform depthColor/depthWidth/depthHeight 来自 XR 深度纹理与相机 viewport。
     * 仓颉侧不依赖 cameraXR 参数：depthWidth/depthHeight 已由 update() 填充到本实例字段，
     * depthColor 绑定到 _texture（GfxTextureHandle）由渲染器在着色器 uniform 阶段处理。
     * @return[zh-cn] 深度可视化网格（首次调用惰性创建，后续返回缓存）
     *
     * @brief[en] Get depth mesh
     * @explain[en] Corresponding to JS: WebXRDepthSensing.getMesh(cameraXR) — builds with PlaneGeometry(20,20) + occlusion ShaderMaterial,
     * uniform depthColor/depthWidth/depthHeight from XR depth texture and camera viewport.
     * Cangjie side does not depend on cameraXR parameter: depthWidth/depthHeight are populated by update(),
     * depthColor binds to _texture (GfxTextureHandle) handled by renderer at shader uniform stage.
     * @return[en] Depth visualization mesh (lazily created on first call, cached subsequently)
     */
    public func getMesh(): Option<Mesh> {
        if (_texture.isValid) {
            if (let Some(_) <- _mesh) {
                ()
            } else {
                let uniforms = HashMap<String, Any>()
                uniforms.add("depthWidth", this.depthWidth)
                uniforms.add("depthHeight", this.depthHeight)
                let material = ShaderMaterial(_occlusion_vertex, _occlusion_fragment, uniforms: uniforms)
                let mesh = Mesh(geometry: PlaneGeometry(width: 20.0, height: 20.0), material: material)
                this._mesh = Some(mesh)
            }
        }
        return _mesh
    }

    /**
     * @brief[zh-cn] 深度感知是否可用
     * @return[zh-cn] 是否可用
     *
     * @brief[en] Whether depth sensing is available
     * @return[en] Whether available
     */
    public func isAvailable(): Bool {
        return _available
    }

    /**
     * @brief[zh-cn] 更新深度数据
     * @explain[zh-cn] 对照 WebXRDepthSensing.update()
     * @param[zh-cn] depthNear 深度近值
     * depthFar 深度远值
     * width 深度宽度
     * height 深度高度
     *
     * @brief[en] Update depth data
     * @explain[en] Corresponding to WebXRDepthSensing.update()
     * @param[en] depthNear Depth near value
     * depthFar Depth far value
     * width Depth width
     * height Depth height
     */
    public func update(depthNear: Float64, depthFar: Float64, width: Int64, height: Int64): Unit {
        this.depthNear = depthNear
        this.depthFar = depthFar
        this.depthWidth = width
        this.depthHeight = height
        this._available = true
    }

    /**
     * @brief[zh-cn] 重置深度数据
     *
     * @brief[en] Reset depth data
     */
    public func reset(): Unit {
        this._available = false
        this.depthNear = 0.0
        this.depthFar = 0.0
        this.depthWidth = 0
        this.depthHeight = 0
    }

    /**
     * @brief[zh-cn] 释放资源
     *
     * @brief[en] Release resources
     */
    public func release(): Bool {
        if (_texture.isValid) {
            if (let Some(r) <- this._renderer) {
                r.backend.destroyTexture(_texture)
            } else {
                @LogWarn(["XRDepthSensing.release: no renderer bound (call bindRenderer); skip GPU texture destroy"])
            }
            _texture = GfxTextureHandle.INVALID
        }
        _mesh = None
        _available = false
        return true
    }

    /**
     * @brief[zh-cn] 资源有效性：句柄有效且标记可用时为 true
     *
     * @brief[en] Resource validity: true when the handle is valid and marked available
     */
    public prop releasable: Bool {
        get() { _texture.isValid && _available }
    }
}
