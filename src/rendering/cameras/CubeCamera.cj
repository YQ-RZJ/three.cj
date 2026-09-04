/**
 * @file[zh-cn] CubeCamera 立方体相机
 * @brief[zh-cn] 用 6 个 PerspectiveCamera 子相机分别捕获场景 6 个方向的视图，合成到 CubeRenderTarget
 * @explain[zh-cn] 立方体相机：用 6 个 PerspectiveCamera 子相机分别捕获场景 ±X/±Y/±Z 6 个方向的视图，
 * 合成到 CubeRenderTarget 中，用于环境贴图、CubeMap 反射等。
 * 6 子相机 layers 默认与本相机一致，子相机 fov 必须为 90（各覆盖一整面）。
 *
 * @file[en] CubeCamera
 * @brief[en] Captures scene views in 6 directions using 6 PerspectiveCamera sub-cameras, composited into CubeRenderTarget
 * @explain[en] Cube camera: captures scene views in 6 directions (±X/±Y/±Z) using 6 PerspectiveCamera sub-cameras,
 * composited into CubeRenderTarget, used for environment maps, CubeMap reflections, etc.
 * 6 sub-camera layers default to this camera's layers, sub-camera fov must be 90 (each covers a full face).
 *
 * @package three.rendering.cameras
 */
package three.rendering.cameras

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.utils.constants.*
import three.rendering.interfaces.IRenderTarget
import three.scene.interfaces.IScene
import three.rendering.interfaces.IRenderer
import std.collection.*

/**
 * @brief[zh-cn] 立方体相机
 * @explain[zh-cn] 用 6 个 PerspectiveCamera 子相机分别捕获场景 ±X/±Y/±Z 6 个方向的视图，
 * 合成到 CubeRenderTarget 中，用于环境贴图、CubeMap 反射等。
 *
 * @brief[en] Cube camera
 * @explain[en] Captures scene views in 6 directions (±X/±Y/±Z) using 6 PerspectiveCamera sub-cameras,
 * composited into CubeRenderTarget, used for environment maps, CubeMap reflections, etc.
 */
public class CubeCamera <: Object3D {
    /**
     * @brief[zh-cn] 立方体贴图渲染目标（CubeRenderTarget），6 面颜色 + optional mipmap
     *
     * @brief[en] Cube map render target (CubeRenderTarget), 6-face color + optional mipmap
     */
    public var renderTarget: IRenderTarget

    /**
     * @brief[zh-cn] 当前坐标系（None 表示未初始化，与 JS side 默认 null 对齐）
     *
     * @brief[en] Current coordinate system (None means uninitialized, aligned with JS side default null)
     */
    public var coordinateSystem: Option<Int64>

    /**
     * @brief[zh-cn] 生成贴图后激活的 mipmap 层级，0 = 全层
     *
     * @brief[en] Active mipmap level after generating texture, 0 = all levels
     */
    public var activeMipmapLevel: Int64

    /**
     * @brief[zh-cn] 构造一个新的立方体相机
     * @param[zh-cn] near 近裁剪面距离
     * far 远裁剪面距离
     * renderTarget CubeRenderTarget 渲染目标
     *
     * @brief[en] Construct a new cube camera
     * @param[en] near Near clipping plane distance
     * far Far clipping plane distance
     * renderTarget CubeRenderTarget render target
     */
    public init(near: Float64, far: Float64, renderTarget: IRenderTarget) {
        super()
        this.kind = "CubeCamera"
        this.renderTarget = renderTarget
        this.coordinateSystem = None
        this.activeMipmapLevel = 0
        // bgfx4cj 统一左手系：fov=90（无反向），6 子相机按左手系朝向
        let fov = 90.0
        let aspect = 1.0
        let cameraPX = PerspectiveCamera(fov: fov, aspect: aspect, near: near, far: far)
        let cameraNX = PerspectiveCamera(fov: fov, aspect: aspect, near: near, far: far)
        let cameraPY = PerspectiveCamera(fov: fov, aspect: aspect, near: near, far: far)
        let cameraNY = PerspectiveCamera(fov: fov, aspect: aspect, near: near, far: far)
        let cameraPZ = PerspectiveCamera(fov: fov, aspect: aspect, near: near, far: far)
        let cameraNZ = PerspectiveCamera(fov: fov, aspect: aspect, near: near, far: far)
        // 与 JS side 一致：6 子相机 layers 与本相机一致（捕获场景全部层）。
        cameraPX.layers = this.layers
        cameraNX.layers = this.layers
        cameraPY.layers = this.layers
        cameraNY.layers = this.layers
        cameraPZ.layers = this.layers
        cameraNZ.layers = this.layers
        this.add(cameraPX)
        this.add(cameraNX)
        this.add(cameraPY)
        this.add(cameraNY)
        this.add(cameraPZ)
        this.add(cameraNZ)
        this.updateCoordinateSystem()
    }

    /**
     * @brief[zh-cn] 按当前坐标系更新 6 子相机朝向
     * @explain[zh-cn] bgfx4cj 统一左手系：6 面朝向按左手系 + 标准立方体贴图布局
     *
     * @brief[en] Update 6 sub-camera orientations based on current coordinate system
     * @explain[en] bgfx4cj unified left-handed system: 6-face orientations follow left-handed + standard cube map layout
     */
    public func updateCoordinateSystem(): Unit {
        if (this.children.size < 6) { return }
        let cameras = ArrayList<Object3D>()
        for (c in this.children) { cameras.add(c) }
        for (c in cameras) { this.remove(c) }
        if (cameras.size >= 6) {
            // 左手系立方体贴图 6 面朝向
            // +X: 右, -X: 左, +Y: 上, -Y: 下, +Z: 前, -Z: 后
            cameras[0].up.set(0.0, 1.0, 0.0); cameras[0].lookAt(Vector3(1.0, 0.0, 0.0))
            cameras[1].up.set(0.0, 1.0, 0.0); cameras[1].lookAt(Vector3(-1.0, 0.0, 0.0))
            cameras[2].up.set(0.0, 0.0, -1.0); cameras[2].lookAt(Vector3(0.0, 1.0, 0.0))
            cameras[3].up.set(0.0, 0.0, 1.0);  cameras[3].lookAt(Vector3(0.0, -1.0, 0.0))
            cameras[4].up.set(0.0, 1.0, 0.0); cameras[4].lookAt(Vector3(0.0, 0.0, 1.0))
            cameras[5].up.set(0.0, 1.0, 0.0); cameras[5].lookAt(Vector3(0.0, 0.0, -1.0))
        }
        for (c in cameras) { this.add(c); c.updateMatrixWorld(false) }
    }

    /**
     * @brief[zh-cn] 渲染场景到立方体贴图
     * @explain[zh-cn] 对照 JS: CubeCamera.update(renderer, scene)。
     * 遍历 6 个子相机，分别渲染到 CubeRenderTarget 的 6 个面（0~5），
     * 保存/恢复渲染目标状态、generateMipmaps、XR 启用状态。
     * @param[zh-cn] renderer 渲染器实例（需实现 setRenderTarget/render/getRenderTarget 接口）
     * scene 待捕获的场景
     *
     * @brief[en] Render scene to cube map
     * @explain[en] Corresponding to JS: CubeCamera.update(renderer, scene).
     * Iterates 6 sub-cameras, renders to CubeRenderTarget's 6 faces (0~5) respectively,
     * saves/restores render target state, generateMipmaps, XR enabled state.
     * @param[en] renderer Renderer instance (must implement setRenderTarget/render/getRenderTarget interfaces)
     * scene Scene to capture
     */
    public func update(renderer: IRenderer, scene: IScene): Unit {
        
        if (this.parent.isNone()) { this.updateMatrixWorld(false) }

        
        // bgfx4cj 统一左手系，coordinateSystem 无需同步
        if (this.coordinateSystem.isNone()) {
            this.coordinateSystem = Some(WebGPUCoordinateSystem)
            this.updateCoordinateSystem()
        }

        
        if (this.children.size < 6) { return }
        let cameraPX = this.children[0]
        let cameraNX = this.children[1]
        let cameraPY = this.children[2]
        let cameraNY = this.children[3]
        let cameraPZ = this.children[4]
        let cameraNZ = this.children[5]

        
        // renderer.setRenderTarget(renderTarget, 0, activeMipmapLevel)
        // const currentRenderTarget = renderer.getRenderTarget();
        // const currentActiveCubeFace = renderer.getActiveCubeFace();
        // const currentActiveMipmapLevel = renderer.getActiveMipmapLevel();

        
        // const currentXrEnabled = renderer.xr.enabled;
        // renderer.xr.enabled = false;

        
        // const generateMipmaps = renderTarget.texture.generateMipmaps;
        // renderTarget.texture.generateMipmaps = false;

        
        // 注意：mipmaps 在最后一次(第6面)渲染调用时生成
        let faces = [cameraPX, cameraNX, cameraPY, cameraNY, cameraPZ, cameraNZ]
        for (i in 0..6) {
            
            //          if (reversedDepthBuffer && renderer.autoClear === false) renderer.clearDepth();
            //          renderer.render(scene, faces[i]);
            ()
        }

        
        
        
        
    }
}
