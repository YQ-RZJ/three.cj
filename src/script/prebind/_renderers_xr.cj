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
 * @file[zh-cn] renderers_xr three.renderers.xr 包的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 绑定 XR 会话枚举、XRManager、XRRenderTarget、XRControllerSpace /
 * XRController、XRDepthSensing
 * @explain[zh-cn] 约定：
 * - XRSessionState / XRReferenceSpaceType 为无显式值的普通枚举，Lua 侧统一用声明顺序整数
 *   （None=0/Creating=1/Active=2/Ending=3；LocalFloor=0/Local=1/Bounded=2/Unbounded=3）传递，
 *   枚举类表以同名静态方法返回该整数，绑定层用 prebindXxx 把整数还原为枚举；
 * - 返回的 XRControllerSpace / ArrayCamera / Mesh 均为注册对象，可与其它绑定类互认；
 * - 输入源参数（Any）以 Lua 值原样透传并存回（getInputSource 按原值返回）；
 * - dispatchEvent 接收 Lua 表，按下标键读取 "type" / "data" 组装事件字典（其余键不读，
 *   因为绑定层不遍历 Lua 表）；
 * - 跳过成员：XRControllerSpace.joints / inputState（内部无类型容器，逐关节/逐输入项读取需要
 *   绑定层遍历 Lua 表或新增访问器，本绑定不引入新接口）、XRRenderTarget.colorTexture /
 *   depthTexture（值语义字段，跨语言按值复制会丢失写回语义）。
 *
 * @file[en] renderers_xr  Lua bindings of the three.renderers.xr package (three.script.prebind)
 * @brief[en] Binds the XR session enums, XRManager, XRRenderTarget, XRControllerSpace /
 * XRController, XRDepthSensing
 * @explain[en] Conventions:
 * - XRSessionState / XRReferenceSpaceType are plain enums without explicit values; Lua uses
 *   declaration-order integers (None=0/Creating=1/Active=2/Ending=3;
 *   LocalFloor=0/Local=1/Bounded=2/Unbounded=3). Enum class tables expose those integers via
 *   same-named static methods, and the binding layer converts them back with prebindXxx helpers;
 * - returned XRControllerSpace / ArrayCamera / Mesh values are registered objects and interoperate
 *   with the other bound classes;
 * - the input-source parameter (Any) carries the Lua value through unchanged (getInputSource returns
 *   the same value);
 * - dispatchEvent takes a Lua table and reads the "type" / "data" keys to build the event map
 *   (other keys are not read, because the binding layer does not iterate Lua tables);
 * - skipped members: XRControllerSpace.joints / inputState (untyped internal containers; per-joint /
 *   per-input reads would require iterating Lua tables or new accessors, which this binding avoids),
 *   XRRenderTarget.colorTexture / depthTexture (value-semantics fields; cross-language copying would
 *   lose write-back semantics).
 */
package three.script.prebind

import three.renderers.xr.{XRSessionState, XRReferenceSpaceType, XRManager, XRRenderTarget, XRControllerSpace, 
    XRController, XRDepthSensing}
import three.renderers.ThreeRenderer
import three.renderers.cameras.{ArrayCamera, PerspectiveCamera}
import three.scene.entity.Mesh
import three.script.vm.*
import three.script.binding.*
import std.collection.*

// =============================================================================
// ===== 绑定层辅助（枚举 ↔ 声明顺序整数） =====
// =============================================================================

/// XRSessionState → Lua 整数（声明顺序）
internal func prebindXRSessionStateIdx(v: XRSessionState): Int64 {
    match (v) {
        case XRSessionState.None => 0
        case XRSessionState.Creating => 1
        case XRSessionState.Active => 2
        case XRSessionState.Ending => 3
    }
}

/// Lua 整数 → XRReferenceSpaceType（越界取 Unbounded）
internal func prebindXRReferenceSpaceType(code: Int64): XRReferenceSpaceType {
    match (code) {
        case 0 => XRReferenceSpaceType.LocalFloor
        case 1 => XRReferenceSpaceType.Local
        case 2 => XRReferenceSpaceType.Bounded
        case _ => XRReferenceSpaceType.Unbounded
    }
}

/// XRReferenceSpaceType → Lua 整数（声明顺序）
internal func prebindXRReferenceSpaceTypeIdx(v: XRReferenceSpaceType): Int64 {
    match (v) {
        case XRReferenceSpaceType.LocalFloor => 0
        case XRReferenceSpaceType.Local => 1
        case XRReferenceSpaceType.Bounded => 2
        case XRReferenceSpaceType.Unbounded => 3
    }
}

/// 读取 Lua 表参数的 "type" / "data" 键组装事件字典（缺失键不写入）
internal func prebindEventMap(vm: LuaVM, args: Array<LuaValue>, idx: Int64): HashMap<String, Any> {
    let out = HashMap<String, Any>()
    if (args.size <= idx || !args[idx].isTable) {
        return out
    }
    let t = LuaTable(vm: vm, ref: Int32(args[idx].refId()))
    let typeValue = t.get("type")
    if (!typeValue.isNil) {
        out.add("type", typeValue)
    }
    let dataValue = t.get("data")
    if (!dataValue.isNil) {
        out.add("data", dataValue)
    }
    return out
}

/// 读取可选参数为 Any（缺失时给 LuaValue.Nil，保持原 Lua 值不丢类型）
internal func prebindAnyValue(args: Array<LuaValue>, idx: Int64): Any {
    if (args.size <= idx) {
        return LuaValue.Nil
    }
    return args[idx]
}

/// Option<Any> → LuaValue（原样透传存回的 LuaValue；其它 Any 返回 nil）
internal func prebindAnyToLua(v: Option<Any>): LuaValue {
    if (let Some(inner) <- v) {
        match (inner) {
            case lv: LuaValue => lv
            case _ => LuaValue.Nil
        }
    } else {
        LuaValue.Nil
    }
}

// =============================================================================
// ===== XRSessionState / XRReferenceSpaceType =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 XRSessionState 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.xr.XRSessionState）
 *
 * @brief[en] Installs the Lua binding of XRSessionState
 * @param[en] vm The target virtual machine (class table at three.renderers.xr.XRSessionState)
 */
public func installXRSessionState(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.xr.XRSessionState")
    b.staticMethod("None") {_ => [LuaValue.of(prebindXRSessionStateIdx(XRSessionState.None))]}
    b.staticMethod("Creating") {_ => [LuaValue.of(prebindXRSessionStateIdx(XRSessionState.Creating))]}
    b.staticMethod("Active") {_ => [LuaValue.of(prebindXRSessionStateIdx(XRSessionState.Active))]}
    b.staticMethod("Ending") {_ => [LuaValue.of(prebindXRSessionStateIdx(XRSessionState.Ending))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 XRReferenceSpaceType 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.xr.XRReferenceSpaceType）
 *
 * @brief[en] Installs the Lua binding of XRReferenceSpaceType
 * @param[en] vm The target virtual machine (class table at three.renderers.xr.XRReferenceSpaceType)
 */
public func installXRReferenceSpaceType(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.xr.XRReferenceSpaceType")
    b.staticMethod("LocalFloor") {_ => [LuaValue.of(prebindXRReferenceSpaceTypeIdx(XRReferenceSpaceType.LocalFloor))]}
    b.staticMethod("Local") {_ => [LuaValue.of(prebindXRReferenceSpaceTypeIdx(XRReferenceSpaceType.Local))]}
    b.staticMethod("Bounded") {_ => [LuaValue.of(prebindXRReferenceSpaceTypeIdx(XRReferenceSpaceType.Bounded))]}
    b.staticMethod("Unbounded") {_ => [LuaValue.of(prebindXRReferenceSpaceTypeIdx(XRReferenceSpaceType.Unbounded))]}
    b.install(vm)
}

// =============================================================================
// ===== XRManager =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 XRManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.xr.XRManager）
 *
 * @brief[en] Installs the Lua binding of XRManager
 * @param[en] vm The target virtual machine (class table at three.renderers.xr.XRManager)
 */
public func installXRManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.xr.XRManager")
    // ===== 构造：new(renderer) =====
    b.constructor {args => XRManager(prebindAs<ThreeRenderer>(args, 0))}
    // ===== 会话生命周期 =====
    b.method("requestSession") {
        ref, args =>
            ref.cast<XRManager>().requestSession(prebindStr(args, 0, default: "immersive-vr"))
            Array<LuaValue>()
    }
    b.method("endSession") {
        ref, _ =>
            ref.cast<XRManager>().endSession()
            Array<LuaValue>()
    }
    // ===== 参考空间 / 缩放 / 注视点 =====
    b.method("setReferenceSpaceType") {
        ref, args =>
            ref.cast<XRManager>().setReferenceSpaceType(prebindXRReferenceSpaceType(prebindInt(args, 0)))
            Array<LuaValue>()
    }
    b.method("getReferenceSpaceType") {
        ref, _ => [LuaValue.of(prebindXRReferenceSpaceTypeIdx(ref.cast<XRManager>().getReferenceSpaceType()))]
    }
    b.method("setFramebufferScaleFactor") {
        ref, args =>
            ref.cast<XRManager>().setFramebufferScaleFactor(prebindNum(args, 0, default: 1.0))
            Array<LuaValue>()
    }
    b.method("setFoveation") {
        ref, args =>
            ref.cast<XRManager>().setFoveation(prebindNum(args, 0, default: 1.0))
            Array<LuaValue>()
    }
    b.method("getFoveation") {
        ref, _ => [LuaValue.of(ref.cast<XRManager>().getFoveation())]
    }
    // ===== 相机与控制器空间 =====
    b.method("getCamera") {
        ref, _ => [prebindRegister(ref.cast<XRManager>().getCamera(), "three.renderers.cameras.ArrayCamera")]
    }
    b.method("getController") {
        ref, args => [prebindRegister(ref.cast<XRManager>().getController(prebindInt(args, 0)),
            "three.renderers.xr.XRControllerSpace")]
    }
    b.method("getControllerGrip") {
        ref, args => [prebindRegister(ref.cast<XRManager>().getControllerGrip(prebindInt(args, 0)),
            "three.renderers.xr.XRControllerSpace")]
    }
    b.method("getHand") {
        ref, args => [prebindRegister(ref.cast<XRManager>().getHand(prebindInt(args, 0)),
            "three.renderers.xr.XRControllerSpace")]
    }
    b.method("updateCamera") {
        ref, args =>
            ref.cast<XRManager>().updateCamera(prebindAs<PerspectiveCamera>(args, 0))
            Array<LuaValue>()
    }
    // ===== 状态查询 =====
    b.method("isXRPresenting") {
        ref, _ => [LuaValue.of(ref.cast<XRManager>().isXRPresenting())]
    }
    b.method("setEnabled") {
        ref, args =>
            ref.cast<XRManager>().setEnabled(prebindBool(args, 0))
            Array<LuaValue>()
    }
    b.method("getEnvironmentBlendMode") {
        ref, _ => [LuaValue.of(ref.cast<XRManager>().getEnvironmentBlendMode())]
    }
    b.install(vm)
}

// =============================================================================
// ===== XRRenderTarget（three.renderers.xr） =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 XRRenderTarget 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.xr.XRRenderTarget）
 *
 * @brief[en] Installs the Lua binding of XRRenderTarget
 * @param[en] vm The target virtual machine (class table at three.renderers.xr.XRRenderTarget)
 */
public func installXRRenderTarget(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.xr.XRRenderTarget")
    b.constructor {args => XRRenderTarget(prebindInt(args, 0), prebindInt(args, 1))}
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<XRRenderTarget>().width)}),
        setter: Some({ref, v => ref.cast<XRRenderTarget>().width = v.intValue()}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<XRRenderTarget>().height)}),
        setter: Some({ref, v => ref.cast<XRRenderTarget>().height = v.intValue()}))
    b.method("setSize") {
        ref, args =>
            ref.cast<XRRenderTarget>().setSize(prebindInt(args, 0), prebindInt(args, 1))
            Array<LuaValue>()
    }
    b.install(vm)
}

// =============================================================================
// ===== XRControllerSpace =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 XRControllerSpace 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.xr.XRControllerSpace）
 *
 * @brief[en] Installs the Lua binding of XRControllerSpace
 * @param[en] vm The target virtual machine (class table at three.renderers.xr.XRControllerSpace)
 */
public func installXRControllerSpace(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.xr.XRControllerSpace")
    b.constructor {_ => XRControllerSpace()}
    // ===== 空间标识与位姿 =====
    b.property("spaceType", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().spaceType)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().spaceType = v.stringValue()}))
    b.property("positionX", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().positionX)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().positionX = v.numberValue()}))
    b.property("positionY", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().positionY)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().positionY = v.numberValue()}))
    b.property("positionZ", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().positionZ)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().positionZ = v.numberValue()}))
    b.property("quaternionX", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().quaternionX)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().quaternionX = v.numberValue()}))
    b.property("quaternionY", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().quaternionY)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().quaternionY = v.numberValue()}))
    b.property("quaternionZ", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().quaternionZ)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().quaternionZ = v.numberValue()}))
    b.property("quaternionW", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().quaternionW)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().quaternionW = v.numberValue()}))
    // ===== 可见性与输入 =====
    b.property("visible", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().visible)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().visible = v.boolValue()}))
    b.property("hasInputSource", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().hasInputSource)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().hasInputSource = v.boolValue()}))
    b.property("eventsEnabled", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().eventsEnabled)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().eventsEnabled = v.boolValue()}))
    // ===== 线速度 =====
    b.property("linearVelocityX", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().linearVelocityX)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().linearVelocityX = v.numberValue()}))
    b.property("linearVelocityY", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().linearVelocityY)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().linearVelocityY = v.numberValue()}))
    b.property("linearVelocityZ", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().linearVelocityZ)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().linearVelocityZ = v.numberValue()}))
    b.property("hasLinearVelocity", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().hasLinearVelocity)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().hasLinearVelocity = v.boolValue()}))
    // ===== 角速度 =====
    b.property("angularVelocityX", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().angularVelocityX)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().angularVelocityX = v.numberValue()}))
    b.property("angularVelocityY", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().angularVelocityY)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().angularVelocityY = v.numberValue()}))
    b.property("angularVelocityZ", getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().angularVelocityZ)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().angularVelocityZ = v.numberValue()}))
    b.property("hasAngularVelocity",
        getter: Some({ref => LuaValue.of(ref.cast<XRControllerSpace>().hasAngularVelocity)}),
        setter: Some({ref, v => ref.cast<XRControllerSpace>().hasAngularVelocity = v.boolValue()}))
    // ===== 事件（表参数：type / data） =====
    b.method("dispatchEvent") {
        ref, args =>
            ref.cast<XRControllerSpace>().dispatchEvent(prebindEventMap(vm, args, 0))
            Array<LuaValue>()
    }
    b.install(vm)
}

// =============================================================================
// ===== XRController =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 XRController 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.xr.XRController）
 *
 * @brief[en] Installs the Lua binding of XRController
 * @param[en] vm The target virtual machine (class table at three.renderers.xr.XRController)
 */
public func installXRController(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.xr.XRController")
    b.constructor {_ => XRController()}
    // ===== 三种坐标空间（惰性创建） =====
    b.method("getTargetRaySpace") {
        ref, _ => [prebindRegister(ref.cast<XRController>().getTargetRaySpace(), "three.renderers.xr.XRControllerSpace")]
    }
    b.method("getGripSpace") {
        ref, _ => [prebindRegister(ref.cast<XRController>().getGripSpace(), "three.renderers.xr.XRControllerSpace")]
    }
    b.method("getHandSpace") {
        ref, _ => [prebindRegister(ref.cast<XRController>().getHandSpace(), "three.renderers.xr.XRControllerSpace")]
    }
    // ===== 输入源（Any 原样透传） =====
    b.method("setInputSource") {
        ref, args =>
            ref.cast<XRController>().setInputSource(prebindAnyValue(args, 0))
            Array<LuaValue>()
    }
    b.method("getInputSource") {
        ref, _ => [prebindAnyToLua(ref.cast<XRController>().getInputSource())]
    }
    // ===== 连接 / 更新 / 事件 =====
    b.method("connect") {
        ref, args =>
            ref.cast<XRController>().connect(prebindAnyValue(args, 0))
            Array<LuaValue>()
    }
    b.method("disconnect") {
        ref, args =>
            ref.cast<XRController>().disconnect(prebindAnyValue(args, 0))
            Array<LuaValue>()
    }
    b.method("update") {
        ref, args =>
            ref.cast<XRController>().update(prebindAnyValue(args, 0), prebindAnyValue(args, 1), prebindAnyValue(args, 2))
            Array<LuaValue>()
    }
    b.method("dispatchEvent") {
        ref, args =>
            ref.cast<XRController>().dispatchEvent(prebindEventMap(vm, args, 0))
            Array<LuaValue>()
    }
    // ===== IReleasable =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<XRController>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<XRController>().release())]
    }
    b.install(vm)
}

// =============================================================================
// ===== XRDepthSensing =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 XRDepthSensing 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.xr.XRDepthSensing）
 *
 * @brief[en] Installs the Lua binding of XRDepthSensing
 * @param[en] vm The target virtual machine (class table at three.renderers.xr.XRDepthSensing)
 */
public func installXRDepthSensing(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.xr.XRDepthSensing")
    b.constructor {_ => XRDepthSensing()}
    // ===== 深度纹理（只读裸索引，无符号 16 位；0xFFFF = 无效） =====
    b.method("getTextureIdx") {
        ref, _ => [LuaValue.of(Int64(ref.cast<XRDepthSensing>().getTextureIdx()))]
    }
    // ===== 绑定渲染器（深度纹理销毁经其下发） =====
    b.method("bindRenderer") {
        ref, args =>
            ref.cast<XRDepthSensing>().bindRenderer(prebindAs<ThreeRenderer>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 深度可视化网格 =====
    b.method("getMesh") {
        ref, _ => match (ref.cast<XRDepthSensing>().getMesh()) {
            case Some(mesh) => [prebindRegister(mesh, "three.scene.entity.Mesh")]
            case None => [LuaValue.Nil]
        }
    }
    // ===== 深度数据 =====
    b.method("isAvailable") {
        ref, _ => [LuaValue.of(ref.cast<XRDepthSensing>().isAvailable())]
    }
    b.method("update") {
        ref, args =>
            ref
                .cast<XRDepthSensing>()
                .update(prebindNum(args, 0), prebindNum(args, 1), prebindInt(args, 2), prebindInt(args, 3))
            Array<LuaValue>()
    }
    b.method("reset") {
        ref, _ =>
            ref.cast<XRDepthSensing>().reset()
            Array<LuaValue>()
    }
    // ===== IReleasable =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<XRDepthSensing>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<XRDepthSensing>().release())]
    }
    b.install(vm)
}
