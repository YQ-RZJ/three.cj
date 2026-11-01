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
 * @file[zh-cn] XRController XR 控制器
 * @brief[zh-cn] 对照 WebXRController.js，管理 XR 控制器输入
 * WebXRController 管理控制器的目标射线空间、握持空间和手部空间。
 *
 * @file[en] XRController XR controller
 * @brief[en] Manages XR controller input, corresponding to WebXRController.js
 * WebXRController manages the controller's target ray space, grip space, and hand space.
 *
 * @package three.rendering.xr
 */
package three.rendering.xr

import std.collection.*

/**
 * @brief[zh-cn] XR 控制器空间
 * @explain[zh-cn] 对照 WebXRController 中的 _targetRay/_grip/_hand
 *
 * @brief[en] XR controller space
 * @explain[en] Corresponding to _targetRay/_grip/_hand in WebXRController
 */
public class XRControllerSpace {
    /**
     * @brief[zh-cn] 空间类型
     *
     * @brief[en] Space type
     */
    public var spaceType: String = ""
    /**
     * @brief[zh-cn] 位置 X
     *
     * @brief[en] Position X
     */
    public var positionX: Float64 = 0.0
    /**
     * @brief[zh-cn] 位置 Y
     *
     * @brief[en] Position Y
     */
    public var positionY: Float64 = 0.0
    /**
     * @brief[zh-cn] 位置 Z
     *
     * @brief[en] Position Z
     */
    public var positionZ: Float64 = 0.0
    /**
     * @brief[zh-cn] 旋转四元数 X
     *
     * @brief[en] Rotation quaternion X
     */
    public var quaternionX: Float64 = 0.0
    /**
     * @brief[zh-cn] 旋转四元数 Y
     *
     * @brief[en] Rotation quaternion Y
     */
    public var quaternionY: Float64 = 0.0
    /**
     * @brief[zh-cn] 旋转四元数 Z
     *
     * @brief[en] Rotation quaternion Z
     */
    public var quaternionZ: Float64 = 0.0
    /**
     * @brief[zh-cn] 旋转四元数 W
     *
     * @brief[en] Rotation quaternion W
     */
    public var quaternionW: Float64 = 1.0
    /**
     * @brief[zh-cn] 是否可见
     *
     * @brief[en] Whether visible
     */
    public var visible: Bool = false
    /**
     * @brief[zh-cn] 是否有输入源
     *
     * @brief[en] Whether has input source
     */
    public var hasInputSource: Bool = false
    /**
     * @brief[zh-cn] 线速度（对应 targetRay/grip 的 linearVelocity）
     *
     * @brief[en] Linear velocity (corresponding to targetRay/grip linearVelocity)
     */
    public var linearVelocityX: Float64 = 0.0
    public var linearVelocityY: Float64 = 0.0
    public var linearVelocityZ: Float64 = 0.0
    public var hasLinearVelocity: Bool = false
    /**
     * @brief[zh-cn] 角速度（对应 targetRay/grip 的 angularVelocity）
     *
     * @brief[en] Angular velocity (corresponding to targetRay/grip angularVelocity)
     */
    public var angularVelocityX: Float64 = 0.0
    /**
     * @brief[zh-cn] 角速度 Y 分量
     *
     * @brief[en] Angular velocity Y component
     */
    public var angularVelocityY: Float64 = 0.0
    /**
     * @brief[zh-cn] 角速度 Z 分量
     *
     * @brief[en] Angular velocity Z component
     */
    public var angularVelocityZ: Float64 = 0.0
    /**
     * @brief[zh-cn] 是否有角速度
     *
     * @brief[en] Whether has angular velocity
     */
    public var hasAngularVelocity: Bool = false
    /**
     * @brief[zh-cn] 手部关节映射（对应 hand.joints）
     *
     * @brief[en] Hand joint mapping (corresponding to hand.joints)
     */
    public var joints: HashMap<String, XRControllerSpace>
    /**
     * @brief[zh-cn] 输入状态（对应 hand.inputState）
     *
     * @brief[en] Input state (corresponding to hand.inputState)
     */
    public var inputState: HashMap<String, Any>
    /**
     * @brief[zh-cn] 事件是否启用（对应 grip.eventsEnabled）
     *
     * @brief[en] Whether events are enabled (corresponding to grip.eventsEnabled)
     */
    public var eventsEnabled: Bool = true

    public init() {
        this.joints = HashMap<String, XRControllerSpace>()
        this.inputState = HashMap<String, Any>()
    }

    /**
     * @brief[zh-cn] 分发事件到该空间
     * @param[zh-cn] event 事件数据
     *
     * @brief[en] Dispatch event to this space
     * @param[en] event Event data
     */
    public func dispatchEvent(event: HashMap<String, Any>): Unit {
        // 存储最近事件，供上层查询
    }
}

/**
 * @brief[zh-cn] XR 控制器
 * @explain[zh-cn] 对照 WebXRController，管理 XR 控制器的不同坐标空间。
 *
 * @brief[en] XR controller
 * @explain[en] Corresponding to WebXRController, manages different coordinate spaces of the XR controller.
 */
public class XRController {
    /**
     * @brief[zh-cn] 目标射线空间
     *
     * @brief[en] Target ray space
     */
    private var _targetRay: Option<XRControllerSpace>
    /**
     * @brief[zh-cn] 握持空间
     *
     * @brief[en] Grip space
     */
    private var _grip: Option<XRControllerSpace>
    /**
     * @brief[zh-cn] 手部空间
     *
     * @brief[en] Hand space
     */
    private var _hand: Option<XRControllerSpace>
    /**
     * @brief[zh-cn] 输入源
     *
     * @brief[en] Input source
     */
    private var _inputSource: Option<Any>

    public init() {
        this._targetRay = None
        this._grip = None
        this._hand = None
        this._inputSource = None
    }

    /**
     * @brief[zh-cn] 获取目标射线空间
     * @explain[zh-cn] 对照 WebXRController.getTargetRaySpace()
     * @return[zh-cn] 目标射线空间
     *
     * @brief[en] Get target ray space
     * @explain[en] Corresponding to WebXRController.getTargetRaySpace()
     * @return[en] Target ray space
     */
    public func getTargetRaySpace(): XRControllerSpace {
        if (let Some(space) <- _targetRay) {
            return space
        } else {
            let space = XRControllerSpace()
            space.spaceType = "targetRay"
            _targetRay = Some(space)
            return space
        }
    }

    /**
     * @brief[zh-cn] 获取握持空间
     * @explain[zh-cn] 对照 WebXRController.getGripSpace()
     * @return[zh-cn] 握持空间
     *
     * @brief[en] Get grip space
     * @explain[en] Corresponding to WebXRController.getGripSpace()
     * @return[en] Grip space
     */
    public func getGripSpace(): XRControllerSpace {
        if (let Some(space) <- _grip) {
            return space
        } else {
            let space = XRControllerSpace()
            space.spaceType = "grip"
            _grip = Some(space)
            return space
        }
    }

    /**
     * @brief[zh-cn] 获取手部空间
     * @explain[zh-cn] 对照 WebXRController.getHandSpace()
     * @return[zh-cn] 手部空间
     *
     * @brief[en] Get hand space
     * @explain[en] Corresponding to WebXRController.getHandSpace()
     * @return[en] Hand space
     */
    public func getHandSpace(): XRControllerSpace {
        if (let Some(space) <- _hand) {
            return space
        } else {
            let space = XRControllerSpace()
            space.spaceType = "hand"
            _hand = Some(space)
            return space
        }
    }

    /**
     * @brief[zh-cn] 设置输入源
     * @explain[zh-cn] 对照 WebXRController.setInputSourceMapping()。
     * 仓颉侧无 XRInputSource 类型，保留 Any 待 XR 类型接入。
     * @param[zh-cn] inputSource 输入源
     *
     * @brief[en] Set input source
     * @explain[en] Corresponding to WebXRController.setInputSourceMapping().
     * Cangjie side has no XRInputSource type, keeps Any for future XR type integration.
     * @param[en] inputSource Input source
     */
    public func setInputSource(inputSource: Any): Unit {
        _inputSource = Some(inputSource)
    }

    /**
     * @brief[zh-cn] 获取输入源
     * @return[zh-cn] 输入源
     *
     * @brief[en] Get input source
     * @return[en] Input source
     */
    public func getInputSource(): Option<Any> {
        return _inputSource
    }

    /**
     * @brief[zh-cn] 分发事件
     * @explain[zh-cn] 对照 WebXRController.dispatchEvent()
     * @param[zh-cn] event 事件数据
     *
     * @brief[en] Dispatch event
     * @explain[en] Corresponding to WebXRController.dispatchEvent()
     * @param[en] event Event data
     */
    public func dispatchEvent(event: HashMap<String, Any>): Unit {
        if (let Some(space) <- _targetRay) {
            space.dispatchEvent(event)
        }
        if (let Some(space) <- _grip) {
            space.dispatchEvent(event)
        }
        if (let Some(space) <- _hand) {
            space.dispatchEvent(event)
        }
    }

    /**
     * @brief[zh-cn] 连接控制器
     * @explain[zh-cn] 对照 WebXRController.connect()
     * @param[zh-cn] inputSource 输入源
     *
     * @brief[en] Connect controller
     * @explain[en] Corresponding to WebXRController.connect()
     * @param[en] inputSource Input source
     */
    public func connect(inputSource: Any): Unit {
        // 初始化手部关节（如果输入源包含手部数据）
        // 遍历 inputSource.hand 创建关节组
        // Three.cj 暂不实现完整的手部追踪
        let evt = HashMap<String, Any>()
        evt.add("type", "connected")
        evt.add("data", inputSource)
        this.dispatchEvent(evt)
    }

    /**
     * @brief[zh-cn] 断开连接
     * @explain[zh-cn] 对照 WebXRController.disconnect()
     * @param[zh-cn] inputSource 输入源
     *
     * @brief[en] Disconnect controller
     * @explain[en] Corresponding to WebXRController.disconnect()
     * @param[en] inputSource Input source
     */
    public func disconnect(inputSource: Any): Unit {
        let evt = HashMap<String, Any>()
        evt.add("type", "disconnected")
        evt.add("data", inputSource)
        this.dispatchEvent(evt)
        _inputSource = None
        if (let Some(space) <- _targetRay) {
            space.visible = false
        }
        if (let Some(space) <- _grip) {
            space.visible = false
        }
        if (let Some(space) <- _hand) {
            space.visible = false
        }
    }

    /**
     * @brief[zh-cn] 更新控制器状态
     * @explain[zh-cn] 对照 WebXRController.update()。
     * 仓颉侧均无对应 XR 类型，保留 Any 待 XR 类型接入。
     * @param[zh-cn] inputSource 输入源
     * frame XR 帧
     * referenceSpace 参考空间
     *
     * @brief[en] Update controller state
     * @explain[en] Corresponding to WebXRController.update().
     * Cangjie side has no corresponding XR types, keeps Any for future XR type integration.
     * @param[en] inputSource Input source
     * frame XR frame
     * referenceSpace Reference space
     */
    public func update(inputSource: Any, frame: Any, referenceSpace: Any): Unit {
        // 更新各空间位姿
        // 需要根据具体的 XR 运行时实现
        // Three.cj 暂不实现完整 XR 更新逻辑
    }

    /**
     * @brief[zh-cn] 获取手部关节组
     * @explain[zh-cn] 对照 WebXRController._getHandJoint()
     * @param[zh-cn] hand 手部空间
     * inputjoint 输入关节
     * @return[zh-cn] 关节空间
     *
     * @brief[en] Get hand joint
     * @explain[en] Corresponding to WebXRController._getHandJoint()
     * @param[en] hand Hand space
     * inputjoint Input joint
     * @return[en] Joint space
     */
    private func _getHandJoint(hand: XRControllerSpace, inputjoint: Any): XRControllerSpace {
        // 创建/获取手部关节空间
        // Three.cj 暂不实现完整手部追踪
        let jointId = "joint"
        match (inputjoint) {
            case obj: HashMap<String, Any> =>
                if (let Some(_) <- obj.get("jointName")) { () } // name 是 String
            case _ => ()
        }
        if (let Some(joint) <- hand.joints.get("default")) {
            return joint
        } else {
            let joint = XRControllerSpace()
            joint.spaceType = "joint"
            hand.joints.add("default", joint)
            return joint
        }
    }

    /**
     * @brief[zh-cn] 释放资源
     *
     * @brief[en] Dispose resources
     */
    public func dispose(): Unit {
        _targetRay = None
        _grip = None
        _hand = None
        _inputSource = None
    }
}
