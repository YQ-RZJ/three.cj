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
 * @file[zh-cn] XRManager XR 管理器
 * @brief[zh-cn] 基于 OpenXR 的 XR 管理器，替代 Three.js 的 WebXRManager
 * @explain[zh-cn] 管理 XR 会话、视图矩阵、控制器跟踪。
 * 对照源码: three.js/src/renderers/webxr/WebXRManager.js
 *
 * @file[en] XRManager XR manager
 * @brief[en] OpenXR-based XR manager, replacing Three.js WebXRManager
 * @explain[en] Manages XR sessions, view matrices, and controller tracking.
 * Reference source: three.js/src/renderers/webxr/WebXRManager.js
 *
 * @package three.rendering.xr
 */
package three.rendering.xr

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.cameras.*
import three.scene.scenegraph.*
import three.rendering.*
import three.rendering.common.*
import three.rendering.textures.*
import std.collection.*

/**
 * @brief[zh-cn] XR 会话状态
 *
 * @brief[en] XR session state
 */
public enum XRSessionState {
    None | Creating | Active | Ending
}

/**
 * @brief[zh-cn] 参考空间类型
 *
 * @brief[en] Reference space type
 */
public enum XRReferenceSpaceType {
    LocalFloor | Local | Bounded | Unbounded
}

/**
 * @brief[zh-cn] XRManager — 管理 XR 会话、视图矩阵、控制器跟踪
 *
 * @brief[en] XRManager — manages XR sessions, view matrices, and controller tracking
 */
public class XRManager <: EventDispatcher {
    /**
     * @brief[zh-cn] bgfx 渲染器实例
     *
     * @brief[en] bgfx renderer instance
     */
    private var renderer: ThreeRenderer
    /**
     * @brief[zh-cn] XR 会话状态
     *
     * @brief[en] XR session state
     */
    private var sessionState: XRSessionState
    /**
     * @brief[zh-cn] 参考空间类型
     *
     * @brief[en] Reference space type
     */
    private var referenceSpaceType: XRReferenceSpaceType
    /**
     * @brief[zh-cn] 帧缓冲缩放因子
     *
     * @brief[en] Framebuffer scale factor
     */
    private var framebufferScaleFactor: Float64
    /**
     * @brief[zh-cn] 注视点渲染级别
     *
     * @brief[en] Foveated rendering level
     */
    private var foveationVal: Float64
    /**
     * @brief[zh-cn] 是否启用 XR
     *
     * @brief[en] Whether XR is enabled
     */
    private var enabled: Bool
    /**
     * @brief[zh-cn] 是否正在呈现 XR
     *
     * @brief[en] Whether XR is currently presenting
     */
    private var presenting: Bool
    /**
     * @brief[zh-cn] 左眼相机
     *
     * @brief[en] Left eye camera
     */
    private var cameraL: PerspectiveCamera
    /**
     * @brief[zh-cn] 右眼相机
     *
     * @brief[en] Right eye camera
     */
    private var cameraR: PerspectiveCamera
    /**
     * @brief[zh-cn] XR 组合相机（左右眼）
     *
     * @brief[en] XR combined camera (left/right eyes)
     */
    private var cameraXR: ArrayCamera
    /**
     * @brief[zh-cn] XR 控制器列表
     *
     * @brief[en] XR controller list
     */
    private var controllers: ArrayList<XRController>
    /**
     * @brief[zh-cn] XR 渲染目标
     *
     * @brief[en] XR render target
     */
    private var xrTarget: XRRenderTarget
    /**
     * @brief[zh-cn] 是否自动更新相机
     *
     * @brief[en] Whether to update cameras automatically
     */
    private var cameraAutoUpdate: Bool

    /**
     * @brief[zh-cn] 构造 XR 管理器
     * @param[zh-cn] renderer bgfx 渲染器实例
     *
     * @brief[en] Construct XR manager
     * @param[en] renderer Bgfx renderer instance
     */
    public init(renderer: ThreeRenderer) {
        super()
        this.renderer = renderer
        this.sessionState = XRSessionState.None
        this.referenceSpaceType = XRReferenceSpaceType.LocalFloor
        this.framebufferScaleFactor = 1.0
        this.foveationVal = 1.0
        this.enabled = false
        this.presenting = false
        this.cameraAutoUpdate = true
        this.cameraL = PerspectiveCamera()
        this.cameraR = PerspectiveCamera()
        
        // 双相机加入 ArrayCamera.cameras，渲染器按 cameraXR 遍历左右眼各渲半屏。
        this.cameraXR = ArrayCamera()
        this.cameraXR.cameras.add(this.cameraL)
        this.cameraXR.cameras.add(this.cameraR)
        this.controllers = ArrayList<XRController>()
        this.xrTarget = XRRenderTarget(0, 0)
    }

    /**
     * @brief[zh-cn] 请求 XR 会话
     * @param[zh-cn] mode 会话模式（如 "immersive-vr"）
     *
     * @brief[en] Request XR session
     * @param[en] mode Session mode (e.g. "immersive-vr")
     */
    public func requestSession(mode: String): Unit {
        match (this.sessionState) {
            case XRSessionState.Active => return
            case _ => ()
        }
        this.sessionState = XRSessionState.Creating
        this.sessionState = XRSessionState.Active
        this.presenting = true
        this.dispatchEvent(Event("sessionstart"))
    }

    /**
     * @brief[zh-cn] 结束 XR 会话
     *
     * @brief[en] End XR session
     */
    public func endSession(): Unit {
        match (this.sessionState) {
            case XRSessionState.Active =>
                this.sessionState = XRSessionState.Ending
                this.presenting = false
                this.sessionState = XRSessionState.None
                this.dispatchEvent(Event("sessionend"))
            case _ => ()
        }
    }

    /**
     * @brief[zh-cn] 设置参考空间类型
     * @param[zh-cn] `type` 参考空间类型
     *
     * @brief[en] Set reference space type
     * @param[en] `type` Reference space type
     */
    public func setReferenceSpaceType(`type`: XRReferenceSpaceType): Unit {
        if (this.presenting) { return }
        this.referenceSpaceType = `type`
    }

    /**
     * @brief[zh-cn] 获取参考空间类型
     * @return[zh-cn] 参考空间类型
     *
     * @brief[en] Get reference space type
     * @return[en] Reference space type
     */
    public func getReferenceSpaceType(): XRReferenceSpaceType {
        return this.referenceSpaceType
    }

    /**
     * @brief[zh-cn] 设置帧缓冲缩放因子
     * @param[zh-cn] factor 缩放因子
     *
     * @brief[en] Set framebuffer scale factor
     * @param[en] factor Scale factor
     */
    public func setFramebufferScaleFactor(factor: Float64): Unit {
        if (this.presenting) { return }
        this.framebufferScaleFactor = factor
    }

    /**
     * @brief[zh-cn] 设置注视点渲染级别
     * @param[zh-cn] value 注视点级别
     *
     * @brief[en] Set foveation level
     * @param[en] value Foveation level
     */
    public func setFoveation(value: Float64): Unit {
        this.foveationVal = value
    }

    /**
     * @brief[zh-cn] 获取注视点渲染级别
     * @return[zh-cn] 注视点级别
     *
     * @brief[en] Get foveation level
     * @return[en] Foveation level
     */
    public func getFoveation(): Float64 {
        return this.foveationVal
    }

    /**
     * @brief[zh-cn] 获取 XR 相机（左右眼组合）
     * @return[zh-cn] 数组相机
     *
     * @brief[en] Get XR camera (left-right eye combination)
     * @return[en] Array camera
     */
    public func getCamera(): ArrayCamera {
        return this.cameraXR
    }

    /**
     * @brief[zh-cn] 获取指定索引控制器的目标射线空间
     * @param[zh-cn] index 控制器索引
     * @return[zh-cn] 控制器空间
     *
     * @brief[en] Get target ray space of controller at given index
     * @param[en] index Controller index
     * @return[en] Controller space
     */
    public func getController(index: Int64): XRControllerSpace {
        while (index >= this.controllers.size) {
            this.controllers.add(XRController())
        }
        return this.controllers[index].getTargetRaySpace()
    }

    /**
     * @brief[zh-cn] 获取指定索引控制器的握持空间
     * @param[zh-cn] index 控制器索引
     * @return[zh-cn] 控制器空间
     *
     * @brief[en] Get grip space of controller at given index
     * @param[en] index Controller index
     * @return[en] Controller space
     */
    public func getControllerGrip(index: Int64): XRControllerSpace {
        while (index >= this.controllers.size) {
            this.controllers.add(XRController())
        }
        return this.controllers[index].getGripSpace()
    }

    /**
     * @brief[zh-cn] 获取指定索引控制器的手部空间
     * @param[zh-cn] index 控制器索引
     * @return[zh-cn] 控制器空间
     *
     * @brief[en] Get hand space of controller at given index
     * @param[en] index Controller index
     * @return[en] Controller space
     */
    public func getHand(index: Int64): XRControllerSpace {
        while (index >= this.controllers.size) {
            this.controllers.add(XRController())
        }
        return this.controllers[index].getHandSpace()
    }

    /**
     * @brief[zh-cn] 更新相机（左右眼投影矩阵与位姿）
     * @explain[zh-cn] 对照 JS: WebXRManager.updateCamera。
     * 左右眼继承主相机位姿，再沿本地 X 轴做 IPD 偏移。
     * @param[zh-cn] camera 主透视相机
     *
     * @brief[en] Update camera (left-right eye projection matrix and pose)
     * @explain[en] Corresponding to JS: WebXRManager.updateCamera.
     * Left and right eyes inherit main camera pose, then translate along local X axis for IPD offset.
     * @param[en] camera Main perspective camera
     */
    public func updateCamera(camera: PerspectiveCamera): Unit {
        if (!this.presenting) { return }
        this.cameraL.projectionMatrix = camera.projectionMatrix
        this.cameraR.projectionMatrix = camera.projectionMatrix
        // ★修复：左右眼必须继承主相机位姿（用户头部位置/朝向），再沿本地 X 轴做 IPD 偏移。
        // 此前硬编码 cameraL.position.set(-0.032,0,0) 使左右眼停在原点、不跟随轨道相机，
        // 拖动改变主相机位置/朝向后面面丢失（左眼黑、右眼 clear 色）。
        
        // 测试场景以主相机轨道位姿模拟头部，故先 copy position/quaternion 再 translateX。
        this.cameraL.position.copy(camera.position)
        this.cameraL.quaternion.copy(camera.quaternion)
        this.cameraR.position.copy(camera.position)
        this.cameraR.quaternion.copy(camera.quaternion)
        // translateX 基于本地轴（translateOnAxis(1,0,0)），沿视线右方向偏移 = IPD 视差
        this.cameraL.translateX(-0.032)
        this.cameraR.translateX(0.032)
        this.cameraL.updateMatrixWorld(true)
        this.cameraR.updateMatrixWorld(true)
    }

    
    // 由左右眼相机投影矩阵计算"联合投影"（frustum 并集 + IPD 视差偏移），
    // 使单相机渲染覆盖双眼视野。VR 系统左右眼 near/far 相同，取左眼值。
    private func setProjectionFromUnion(camera: PerspectiveCamera, cameraL: PerspectiveCamera, cameraR: PerspectiveCamera): Unit {
        let cameraLPos = Vector3()
        let cameraRPos = Vector3()
        cameraLPos.setFromMatrixPosition(cameraL.matrixWorld)
        cameraRPos.setFromMatrixPosition(cameraR.matrixWorld)
        let ipd = cameraLPos.distanceTo(cameraRPos)

        let projL = cameraL.projectionMatrix.elements
        let projR = cameraR.projectionMatrix.elements

        // 近/远平面与上下 frustum 取左眼值（VR 左右眼一致）
        let near = projL[14] / (projL[10] - 1.0)
        let far = projL[14] / (projL[10] + 1.0)
        let topFov = (projL[9] + 1.0) / projL[5]
        let bottomFov = (projL[9] - 1.0) / projL[5]
        let leftFov = (projL[8] - 1.0) / projL[0]
        let rightFov = (projR[8] + 1.0) / projR[0]
        let left = near * leftFov
        let right = near * rightFov

        // 新相机相对左眼的偏移：zOffset 约等于 IPD 的一半（非对称投影）
        let zOffset = ipd / (-leftFov + rightFov)
        let xOffset = zOffset * -leftFov

        // 把左眼相机世界位姿分解后平移偏移量（对照 JS: decompose → translateX/Z → compose）
        let pos = Vector3(); let quat = Quaternion(); let scale = Vector3()
        cameraL.matrixWorld.decompose(pos, quat, scale)
        camera.position.copy(pos)
        camera.quaternion.copy(quat)
        camera.scale.copy(scale)
        camera.translateX(xOffset)
        camera.translateZ(zOffset)
        camera.matrixWorld.compose(camera.position, camera.quaternion, camera.scale)
        camera.matrixWorldInverse.copy(camera.matrixWorld).invert()

        // 无限远平面（projL[10] === -1.0）时直接用左眼投影；否则求 frustum 并集
        if (projL[10] == -1.0) {
            camera.projectionMatrix.copy(cameraL.projectionMatrix)
            camera.projectionMatrixInverse.copy(cameraL.projectionMatrixInverse)
        } else {
            let near2 = near + zOffset
            let far2 = far + zOffset
            let left2 = left - xOffset
            let right2 = right + (ipd - xOffset)
            let top2 = topFov * far / far2 * near2
            let bottom2 = bottomFov * far / far2 * near2
            camera.projectionMatrix.makePerspective(left2, right2, top2, bottom2, near2, far2)
            camera.projectionMatrixInverse.copy(camera.projectionMatrix).invert()
        }
    }

    
    // 把 XR 相机世界矩阵应用到用户相机（parent 非空时先变换到父空间再应用）。
    // 仓颉用 Option<Object3D> 表达 JS 的可空 parent。
    /**
     * @brief[zh-cn] 把 XR 相机世界矩阵应用到用户相机
     *
     * @brief[en] Applies the XR camera world matrix to the user camera
     */
    private func updateUserCamera(camera: PerspectiveCamera, cameraXR: Camera, parent: Option<Object3D>): Unit {
        match (parent) {
            case None =>
                camera.matrix.copy(cameraXR.matrixWorld)
            case Some(p) =>
                camera.matrix.copy(p.matrixWorld)
                camera.matrix.invert()
                camera.matrix.multiply(cameraXR.matrixWorld)
        }
        camera.matrix.decompose(camera.position, camera.quaternion, camera.scale)
        camera.updateMatrixWorld(true)
    }

    /**
     * @brief[zh-cn] XR 是否正在呈现
     * @return[zh-cn] 是否正在呈现
     *
     * @brief[en] Whether XR is presenting
     * @return[en] Whether presenting
     */
    public func isXRPresenting(): Bool { return this.presenting }

    /**
     * @brief[zh-cn] 设置 XR 是否启用
     * @param[zh-cn] value 是否启用
     *
     * @brief[en] Set whether XR is enabled
     * @param[en] value Whether enabled
     */
    public func setEnabled(value: Bool): Unit {
        this.enabled = value
    }

    /**
     * @brief[zh-cn] 获取环境混合模式
     * @return[zh-cn] 环境混合模式
     *
     * @brief[en] Get environment blend mode
     * @return[en] Environment blend mode
     */
    public func getEnvironmentBlendMode(): String {
        return "opaque"
    }
}

/**
 * @brief[zh-cn] XR 渲染目标
 *
 * @brief[en] XR render target
 */
public class XRRenderTarget {
    /**
     * @brief[zh-cn] 宽度
     *
     * @brief[en] Width
     */
    public var width: Int64
    /**
     * @brief[zh-cn] 高度
     *
     * @brief[en] Height
     */
    public var height: Int64
    /**
     * @brief[zh-cn] 颜色纹理
     *
     * @brief[en] Color texture
     */
    public var colorTexture: Texture
    /**
     * @brief[zh-cn] 深度纹理
     *
     * @brief[en] Depth texture
     */
    public var depthTexture: DepthTexture

    /**
     * @brief[zh-cn] 构造 XR 渲染目标
     * @param[zh-cn] width 宽度
     * height 高度
     *
     * @brief[en] Construct XR render target
     * @param[en] width Width
     * height Height
     */
    public init(width: Int64, height: Int64) {
        this.width = width; this.height = height
        this.colorTexture = Texture()
        this.depthTexture = DepthTexture(width, height)
    }

    /**
     * @brief[zh-cn] 设置渲染目标尺寸
     * @param[zh-cn] width 宽度
     * height 高度
     *
     * @brief[en] Set render target size
     * @param[en] width Width
     * height Height
     */
    public func setSize(width: Int64, height: Int64): Unit {
        this.width = width; this.height = height
    }
}
