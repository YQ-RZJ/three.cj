/**
 * @file[zh-cn] BgfxXRDepthSensing XR 深度感知
 * @brief[zh-cn] 对照 WebXRDepthSensing.js，提供深度感知数据
 * @explain[zh-cn] 对照源码: three.js/src/renderers/webxr/WebXRDepthSensing.js
 * WebXRDepthSensing 管理 XR 深度纹理和深度网格。
 * bgfx 版本使用 TextureHandle 替代 WebGL 纹理。
 *
 * @file[en] BgfxXRDepthSensing XR depth sensing
 * @brief[en] Provides depth sensing data, corresponding to WebXRDepthSensing.js
 * @explain[en] Reference source: three.js/src/renderers/webxr/WebXRDepthSensing.js
 * WebXRDepthSensing manages XR depth textures and depth meshes.
 * bgfx version uses TextureHandle instead of WebGL textures.
 *
 * @package three.rendering.bgfxxr
 */
package three.rendering.bgfxxr

import bgfx4cj.bgfx.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.geometry.PlaneGeometry
import three.rendering.materials.ShaderMaterial
import three.scene.entity.Mesh
import std.collection.*
import three.core.thread.bgfxCallMtx


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
 * bgfx 版本使用 TextureHandle 替代 WebGL 纹理。
 *
 * @brief[en] XR depth sensing
 * @explain[en] Corresponding to WebXRDepthSensing, manages XR depth textures and depth meshes.
 * bgfx version uses TextureHandle instead of WebGL textures.
 */
public class BgfxXRDepthSensing {
    /**
     * @brief[zh-cn] 深度纹理句柄
     *
     * @brief[en] Depth texture handle
     */
    private var _texture: TextureHandle
    /**
     * @brief[zh-cn] 深度网格（PlaneGeometry + occlusion ShaderMaterial，对照 JS WebXRDepthSensing.mesh）
     *
     * @brief[en] Depth mesh (PlaneGeometry + occlusion ShaderMaterial, corresponding to JS WebXRDepthSensing.mesh)
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

    public init() {
        this._texture = TextureHandle()
        this._mesh = None
    }

    /**
     * @brief[zh-cn] 获取深度纹理
     * @return[zh-cn] 深度纹理句柄
     *
     * @brief[en] Get depth texture
     * @return[en] Depth texture handle
     */
    public func getTexture(): TextureHandle {
        return _texture
    }

    /**
     * @brief[zh-cn] 设置深度纹理
     * @param[zh-cn] texture 深度纹理句柄
     *
     * @brief[en] Set depth texture
     * @param[en] texture Depth texture handle
     */
    public func setTexture(texture: TextureHandle): Unit {
        this._texture = texture
    }

    /**
     * @brief[zh-cn] 获取深度网格
     * @explain[zh-cn] 对照 JS: WebXRDepthSensing.getMesh(cameraXR) — 用 PlaneGeometry(20,20) + occlusion ShaderMaterial 构建，
     * uniform depthColor/depthWidth/depthHeight 来自 XR 深度纹理与相机 viewport。
     * 仓颉侧不依赖 cameraXR 参数：depthWidth/depthHeight 已由 update() 填充到本实例字段，
     * depthColor 绑定到 _texture（TextureHandle）由渲染器在着色器 uniform 阶段处理。
     * @return[zh-cn] 深度可视化网格（首次调用惰性创建，后续返回缓存）
     *
     * @brief[en] Get depth mesh
     * @explain[en] Corresponding to JS: WebXRDepthSensing.getMesh(cameraXR) — builds with PlaneGeometry(20,20) + occlusion ShaderMaterial,
     * uniform depthColor/depthWidth/depthHeight from XR depth texture and camera viewport.
     * Cangjie side does not depend on cameraXR parameter: depthWidth/depthHeight are populated by update(),
     * depthColor binds to _texture (TextureHandle) handled by renderer at shader uniform stage.
     * @return[en] Depth visualization mesh (lazily created on first call, cached subsequently)
     */
    public func getMesh(): Option<Mesh> {
        if (_texture.idx != 0xFFFFu16) {
            match (_mesh) {
                case None =>
                    let uniforms = HashMap<String, Any>()
                    uniforms.add("depthWidth", this.depthWidth)
                    uniforms.add("depthHeight", this.depthHeight)
                    let material = ShaderMaterial(_occlusion_vertex, _occlusion_fragment, uniforms: uniforms)
                    let mesh = Mesh(geometry: PlaneGeometry(width: 20.0, height: 20.0), material: material)
                    this._mesh = Some(mesh)
                case Some(_) => ()
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
     * @brief[en] Dispose resources
     */
    public func dispose(): Unit {
        if (_texture.idx != 0xFFFFu16) {
            bgfxCallMtx.lock()
            try {
                bgfx_destroy_texture_cj(_texture)
            } finally {
                bgfxCallMtx.unlock()
            }
            _texture = TextureHandle()
        }
        _mesh = None
        _available = false
    }
}
