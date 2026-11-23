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
 * @file[zh-cn] LuaBindingFactory 引擎 Lua 绑定统一工厂（three.script.prebind）
 * @brief[zh-cn] 统一注册并安装所有仓颉 → Lua 绑定，支持全量 / 按类名 / 按包前缀安装
 * @explain[zh-cn] prebind 下每个 <domain>_<name>.cj（如 _renderers_threerenderer.cj）只负责
 * 提供 install<Name>(vm) 安装函数；
 * 本工厂将全部安装函数集中登记在 _bindingRegistry（键 = 绑定类全名），并提供三种安装入口：
 * - installAll：全量安装所有已登记绑定；
 * - install(vm, className)：按绑定类名精确安装（未登记返回 false）；
 * - installPackage(vm, prefix)：按包前缀批量安装（如 "three.core.math"），返回成功数；
 * - boundClasses：列出已登记的全部绑定类名（供清单/调试）。
 * 重复安装同名绑定会被跳过（返回 0 / 计入 installAll 结果），保证工厂可重复调用。
 * @see[zh-cn] 新增绑定的接入方式：在 <domain>_<name>.cj 中实现 install<Name>(vm)，
 * 然后在本文件底部 _registerBinding 处登记一行即可。
 *
 * @file[en] LuaBindingFactory  Unified factory for the Cangjie→Lua bindings (three.script.prebind)
 * @brief[en] Registers and installs all Cangjie→Lua bindings; supports all / by-class-name /
 *            by-package-prefix installation
 * @explain[en] Every <domain>_<name>.cj file under prebind (e.g. _renderers_threerenderer.cj)
 * only provides an install<Name>(vm) function; this factory centralizes them in
 * _bindingRegistry (key = full bound class name)
 * and offers three entry points:
 * - installAll: installs every registered binding;
 * - install(vm, className): installs one binding by its full class name (false when unregistered);
 * - installPackage(vm, prefix): installs a group by package prefix (e.g. "three.core.math"),
 *   returning the number installed;
 * - boundClasses: lists all registered bound class names (for docs/debug).
 * Re-installing an already-registered class is skipped (counted in installAll results),
 * so the factory stays safe to call repeatedly.
 * @see[en] Adding a new binding: implement install<Name>(vm) in <domain>_<name>.cj and
 * add a single _registerBinding line at the bottom of this file.
 */
package three.script.prebind

import std.collection.*
import three.script.vm.*

// 绑定注册表：绑定类全名 → 安装函数（install<Name> 的适配器）
private var _bindingRegistry: HashMap<String, (LuaVM) -> Unit> = HashMap()

/** 绑定是否已登记（惰性，首次使用任一工厂入口时执行一次） */
private var _bindingRegistered: Bool = false

/**
 * @brief[zh-cn] 登记一个绑定安装函数（内部）
 * @param[zh-cn] name 绑定类全名（Lua 侧类表路径，如 "three.core.math.Vector2"）
 * @param[zh-cn] fn   安装函数（接收目标 LuaVM）
 *
 * @brief[en] Registers a binding install function (internal)
 * @param[en] name The full bound class name (the Lua-side class path, e.g. "three.core.math.Vector2")
 * @param[en] fn   The install function (takes the target LuaVM)
 */
private func _registerBinding(name: String, fn: (LuaVM) -> Unit): Unit {
    _bindingRegistry[name] = fn
}

/**
 * @brief[zh-cn] 确保全部绑定已登记（惰性初始化，重复调用无副作）
 *
 * @brief[en] Ensures every binding is registered (lazy; repeated calls are no-ops)
 */
private func _ensureBindingRegistered(): Unit {
    if (_bindingRegistered) {
        return
    }
    _bindingRegistered = true
    // —— three.core.math ——
    _registerBinding("three.core.math.Vector2") {vm => installVector2(vm)}
    _registerBinding("three.core.math.Vector3") {vm => installVector3(vm)}
    _registerBinding("three.core.math.Vector4") {vm => installVector4(vm)}
    _registerBinding("three.core.math.Vector3F") {vm => installVector3F(vm)}
    _registerBinding("three.core.math.Vector4F") {vm => installVector4F(vm)}
    _registerBinding("three.core.math.Color") {vm => installColor(vm)}
    _registerBinding("three.core.math.Color4") {vm => installColor4(vm)}
    _registerBinding("three.core.math.Euler") {vm => installEuler(vm)}
    _registerBinding("three.core.math.Cylindrical") {vm => installCylindrical(vm)}
    _registerBinding("three.core.math.Spherical") {vm => installSpherical(vm)}
    _registerBinding("three.core.math.Matrix3") {vm => installMatrix3(vm)}
    _registerBinding("three.core.math.Matrix4") {vm => installMatrix4(vm)}
    _registerBinding("three.core.math.Quaternion") {vm => installQuaternion(vm)}
    _registerBinding("three.core.math.QuaternionF") {vm => installQuaternionF(vm)}
    _registerBinding("three.core.math.MathUtils") {vm => installMathUtils(vm)}
    _registerBinding("three.core.math.Box2") {vm => installBox2(vm)}
    _registerBinding("three.core.math.Box3") {vm => installBox3(vm)}
    _registerBinding("three.core.math.Plane") {vm => installPlane(vm)}
    _registerBinding("three.core.math.Ray") {vm => installRay(vm)}
    _registerBinding("three.core.math.Line3") {vm => installLine3(vm)}
    _registerBinding("three.core.math.Sphere") {vm => installSphere(vm)}
    _registerBinding("three.core.math.Triangle") {vm => installTriangle(vm)}
    _registerBinding("three.core.math.Frustum") {vm => installFrustum(vm)}
    _registerBinding("three.core.math.SphericalHarmonics3") {vm => installSphericalHarmonics3(vm)}
    _registerBinding("three.core.math.Interpolant") {vm => installInterpolant(vm)}
    _registerBinding("three.core.math.interpolants.LinearInterpolant") {vm => installLinearInterpolant(vm)}
    _registerBinding("three.core.math.interpolants.DiscreteInterpolant") {vm => installDiscreteInterpolant(vm)}
    _registerBinding("three.core.math.interpolants.CubicInterpolant") {vm => installCubicInterpolant(vm)}
    _registerBinding("three.core.math.interpolants.QuaternionLinearInterpolant") {
        vm => installQuaternionLinearInterpolant(vm)
    }
    _registerBinding("three.core.math.interpolants.BezierInterpolant") {vm => installBezierInterpolant(vm)}
    _registerBinding("three.core.math.ColorManagement") {vm => installColorManagement(vm)}
    _registerBinding("three.core.math.ColorSpaceDefinition") {vm => installColorSpaceDefinition(vm)}
    _registerBinding("three.core.math.ColorSpaceWorkingConfig") {vm => installColorSpaceWorkingConfig(vm)}
    _registerBinding("three.core.math.ColorSpaceOutputConfig") {vm => installColorSpaceOutputConfig(vm)}
    // —— three.core.dsa ——
    _registerBinding("three.core.dsa.Bvh") {vm => installBvh(vm)}
    _registerBinding("three.core.dsa.SpatialHashGrid") {vm => installSpatialHashGrid(vm)}
    _registerBinding("three.core.dsa.FenwickTree") {vm => installFenwickTree(vm)}
    _registerBinding("three.core.dsa.UnionFind") {vm => installUnionFind(vm)}
    _registerBinding("three.core.dsa.SimplexNoise") {vm => installSimplexNoise(vm)}
    _registerBinding("three.core.dsa.BitArray") {vm => installBitArray(vm)}
    _registerBinding("three.core.dsa.FlockConfig") {vm => installFlockConfig(vm)}
    _registerBinding("three.core.dsa.Boid") {vm => installBoid(vm)}
    _registerBinding("three.core.dsa.Flock") {vm => installFlock(vm)}
    // —— three.core.dsa 泛型容器（以 LuaValue 实例化，Lua 侧"any"通道） ——
    _registerBinding("three.core.dsa.RingBuffer") {vm => installRingBuffer(vm)}
    _registerBinding("three.core.dsa.CircularQueue") {vm => installCircularQueue(vm)}
    _registerBinding("three.core.dsa.LinkedList") {vm => installLinkedList(vm)}
    _registerBinding("three.core.dsa.LinkedListNode") {vm => installLinkedListNode(vm)}
    _registerBinding("three.core.dsa.Queue") {vm => installQueue(vm)}
    _registerBinding("three.core.dsa.Stack") {vm => installStack(vm)}
    _registerBinding("three.core.dsa.LruCache") {vm => installLruCache(vm)}
    _registerBinding("three.core.dsa.BinaryHeap") {vm => installBinaryHeap(vm)}
    _registerBinding("three.core.dsa.BinaryPatriciaTrie") {vm => installBinaryPatriciaTrie(vm)}
    // —— three.core.event ——
    _registerBinding("three.core.event.Event") {vm => installEvent(vm)}
    _registerBinding("three.core.event.ListenerHandle") {vm => installListenerHandle(vm)}
    _registerBinding("three.core.event.EventDispatcher") {vm => installEventDispatcher(vm)}
    _registerBinding("three.core.event.EventManager") {vm => installEventManager(vm)}
    _registerBinding("three.core.event.EventRecord") {vm => installEventRecord(vm)}
    _registerBinding("three.core.event.EventFactory") {vm => installEventFactory(vm)}
    // —— three.core.dispatch / thread / time / system ——
    _registerBinding("three.core.dispatch.FrameDispatch") {vm => installFrameDispatch(vm)}
    _registerBinding("three.core.thread.RecursiveMutex") {vm => installRecursiveMutex(vm)}
    _registerBinding("three.core.thread.Mutex") {vm => installMutex(vm)}
    _registerBinding("three.core.thread.Condition") {vm => installCondition(vm)}
    _registerBinding("three.core.thread.Semaphore") {vm => installSemaphore(vm)}
    _registerBinding("three.core.thread.RWLock") {vm => installRWLock(vm)}
    _registerBinding("three.core.thread.FrameFence") {vm => installFrameFence(vm)}
    _registerBinding("three.core.time.Timer") {vm => installTimer(vm)}
    _registerBinding("three.core.time.Clock") {vm => installClock(vm)}
    _registerBinding("three.core.time.SdlTimer") {vm => installSdlTimer(vm)}
    _registerBinding("three.core.system.SystemInfo") {vm => installSystemInfo(vm)}
    _registerBinding("three.core.system.PowerState") {vm => installPowerState(vm)}
    _registerBinding("three.core.system.Folder") {vm => installFolder(vm)}
    // —— three.utils.* ——
    _registerBinding("three.utils.safe.Safe") {vm => installSafe(vm)}
    _registerBinding("three.utils.pool.PoolManager") {vm => installPoolManager(vm)}
    _registerBinding("three.utils.log.Logger") {vm => installLogger(vm)}
    _registerBinding("three.utils.log.LogLevel") {vm => installLogLevel(vm)}
    _registerBinding("three.utils.encode.UUID") {vm => installUUID(vm)}
    _registerBinding("three.utils.constants.Constants") {vm => installConstants(vm)}
    _registerBinding("three.utils.memory.BgfxMemory") {vm => installBgfxMemory(vm)}
    // —— three.utils.memory.PtrArray（按元素类型实例化：UI 控件数值缓冲） ——
    _registerBinding("three.utils.memory.PtrArrayInt32") {vm => installPtrArrayInt32(vm)}
    _registerBinding("three.utils.memory.PtrArrayFloat32") {vm => installPtrArrayFloat32(vm)}
    _registerBinding("three.utils.memory.PtrArrayFloat64") {vm => installPtrArrayFloat64(vm)}
    _registerBinding("three.utils.memory.PtrArrayUInt8") {vm => installPtrArrayUInt8(vm)}
    _registerBinding("three.utils.memory.PtrArrayUInt16") {vm => installPtrArrayUInt16(vm)}
    _registerBinding("three.utils.memory.PtrArrayUInt32") {vm => installPtrArrayUInt32(vm)}
    _registerBinding("three.utils.allocator.IdAllocator") {vm => installIdAllocator(vm)}
    // —— three.animation.blend（关键帧轨道基类） ——
    _registerBinding("three.animation.blend.KeyframeTrack") {vm => installKeyframeTrack(vm)}
    _registerBinding("three.animation.blend.AnimationAction") {vm => installAnimationAction(vm)}
    _registerBinding("three.animation.blend.AnimationMixer") {vm => installAnimationMixer(vm)}
    _registerBinding("three.animation.blend.AnimationObjectGroup") {vm => installAnimationObjectGroup(vm)}
    _registerBinding("three.animation.blend.PropertyBinding") {vm => installPropertyBinding(vm)}
    // —— three.animation.tracks（六种具体关键帧轨道） ——
    _registerBinding("three.animation.tracks.NumberKeyframeTrack") {vm => installNumberKeyframeTrack(vm)}
    _registerBinding("three.animation.tracks.VectorKeyframeTrack") {vm => installVectorKeyframeTrack(vm)}
    _registerBinding("three.animation.tracks.ColorKeyframeTrack") {vm => installColorKeyframeTrack(vm)}
    _registerBinding("three.animation.tracks.QuaternionKeyframeTrack") {vm => installQuaternionKeyframeTrack(vm)}
    _registerBinding("three.animation.tracks.BooleanKeyframeTrack") {vm => installBooleanKeyframeTrack(vm)}
    _registerBinding("three.animation.tracks.StringKeyframeTrack") {vm => installStringKeyframeTrack(vm)}
    // —— three.animation.clip ——
    _registerBinding("three.animation.clip.AnimationClip") {vm => installAnimationClip(vm)}
    _registerBinding("three.animation.clip.AnimationUtils") {vm => installAnimationUtils(vm)}
    // —— three.animation.offline（离线动画与骨骼数据） ——
    _registerBinding("three.animation.offline.RawAnimation") {vm => installRawAnimation(vm)}
    _registerBinding("three.animation.offline.RawFloatTrack") {vm => installRawFloatTrack(vm)}
    _registerBinding("three.animation.offline.RawQuaternionTrack") {vm => installRawQuaternionTrack(vm)}
    _registerBinding("three.animation.offline.RawFloat3Track") {vm => installRawFloat3Track(vm)}
    _registerBinding("three.animation.offline.RawJoint") {vm => installRawJoint(vm)}
    _registerBinding("three.animation.offline.RawSkeleton") {vm => installRawSkeleton(vm)}
    _registerBinding("three.animation.offline.AnimationOptimizer") {vm => installAnimationOptimizer(vm)}
    _registerBinding("three.animation.offline.TrackOptimizer") {vm => installTrackOptimizer(vm)}
    _registerBinding("three.animation.offline.AnimationBuilder") {vm => installAnimationBuilder(vm)}
    _registerBinding("three.animation.offline.TrackBuilder") {vm => installTrackBuilder(vm)}
    _registerBinding("three.animation.offline.AdditiveAnimationBuilder") {vm => installAdditiveAnimationBuilder(vm)}
    _registerBinding("three.animation.offline.RawAnimationUtils") {vm => installRawAnimationUtils(vm)}
    // —— three.animation.skeletal（骨骼动画数据） ——
    _registerBinding("three.animation.skeletal.JointTrack") {vm => installJointTrack(vm)}
    _registerBinding("three.animation.skeletal.SkeletalAnimationData") {vm => installSkeletalAnimationData(vm)}
    _registerBinding("three.animation.skeletal.SkeletalTrackData") {vm => installSkeletalTrackData(vm)}
    _registerBinding("three.animation.skeletal.AnimatorParam") {vm => installAnimatorParam(vm)}
    _registerBinding("three.animation.skeletal.TransitionCondition") {vm => installTransitionCondition(vm)}
    _registerBinding("three.animation.skeletal.AnimatorState") {vm => installAnimatorState(vm)}
    _registerBinding("three.animation.skeletal.AnimatorTransition") {vm => installAnimatorTransition(vm)}
    _registerBinding("three.animation.skeletal.AnimatorController") {vm => installAnimatorController(vm)}
    _registerBinding("three.animation.skeletal.SkeletonData") {vm => installSkeletonData(vm)}
    _registerBinding("three.animation.skeletal.SkeletonUtils") {vm => installSkeletonUtils(vm)}
    _registerBinding("three.animation.skeletal.AnimationEventSystem") {vm => installAnimationEventSystem(vm)}
    // —— three.audio.device（音频上下文与变换槽） ——
    _registerBinding("three.audio.device.AudioContext") {vm => installAudioContext(vm)}
    _registerBinding("three.audio.device.AudioTransformSlot") {vm => installAudioTransformSlot(vm)}
    // —— three.audio.listener ——
    _registerBinding("three.audio.listener.AudioListener") {vm => installAudioListener(vm)}
    // —— three.audio.mixer（EFX 效果 / 效果槽 / 滤波器） ——
    _registerBinding("three.audio.mixer.AudioEffect") {vm => installAudioEffect(vm)}
    _registerBinding("three.audio.mixer.AudioEffectSlot") {vm => installAudioEffectSlot(vm)}
    _registerBinding("three.audio.mixer.AudioFilter") {vm => installAudioFilter(vm)}
    // —— three.audio.source（静态 / 位置 / 流式音频源与缓冲区） ——
    _registerBinding("three.audio.source.Audio") {vm => installAudio(vm)}
    _registerBinding("three.audio.source.PositionalAudio") {vm => installPositionalAudio(vm)}
    _registerBinding("three.audio.source.StreamingAudio") {vm => installStreamingAudio(vm)}
    _registerBinding("three.audio.source.AudioBuffer") {vm => installAudioBuffer(vm)}
    // —— three.audio.capture（麦克风录音） ——
    _registerBinding("three.audio.capture.AudioRecorder") {vm => installAudioRecorder(vm)}
    // —— three.network.protocol（游戏协议包编解码） ——
    _registerBinding("three.network.protocol.PacketWriter") {vm => installPacketWriter(vm)}
    _registerBinding("three.network.protocol.PacketReader") {vm => installPacketReader(vm)}
    // —— three.network.http（HTTP 请求 / 响应 / 客户端） ——
    _registerBinding("three.network.http.HttpRequest") {vm => installHttpRequest(vm)}
    _registerBinding("three.network.http.HttpResponse") {vm => installHttpResponse(vm)}
    _registerBinding("three.network.http.NetworkHttp") {vm => installNetworkHttp(vm)}
    _registerBinding("three.network.http.HttpClient") {vm => installHttpClient(vm)}
    // —— three.network.socket（TCP 客户端 / 服务端 / UDP） ——
    _registerBinding("three.network.socket.SocketClient") {vm => installSocketClient(vm)}
    _registerBinding("three.network.socket.SocketServer") {vm => installSocketServer(vm)}
    _registerBinding("three.network.socket.SocketUdp") {vm => installSocketUdp(vm)}
    // —— three.network.transport（TCP 长连接 / 可靠 UDP） ——
    _registerBinding("three.network.transport.Connection") {vm => installConnection(vm)}
    _registerBinding("three.network.transport.ReliableChannel") {vm => installReliableChannel(vm)}
    // —— three.network.sync（帧同步 / 快照缓冲） ——
    _registerBinding("three.network.sync.LockstepSession") {vm => installLockstepSession(vm)}
    _registerBinding("three.network.sync.SnapshotBuffer") {vm => installSnapshotBuffer(vm)}
    // —— three.physics.common（枚举 / 描述 / 句柄 / 查询结果） ——
    _registerBinding("three.physics.common.PhysicsShapeType") {vm => installPhysicsShapeType(vm)}
    _registerBinding("three.physics.common.PhysicsCompoundPart") {vm => installPhysicsCompoundPart(vm)}
    _registerBinding("three.physics.common.PhysicsShape") {vm => installPhysicsShape(vm)}
    _registerBinding("three.physics.common.PhysicsMotionType") {vm => installPhysicsMotionType(vm)}
    _registerBinding("three.physics.common.PhysicsActivation") {vm => installPhysicsActivation(vm)}
    _registerBinding("three.physics.common.PhysicsLayer") {vm => installPhysicsLayer(vm)}
    _registerBinding("three.physics.common.PhysicsBodyDesc") {vm => installPhysicsBodyDesc(vm)}
    _registerBinding("three.physics.common.PhysicsConstraintType") {vm => installPhysicsConstraintType(vm)}
    _registerBinding("three.physics.common.PhysicsMotorState") {vm => installPhysicsMotorState(vm)}
    _registerBinding("three.physics.common.PhysicsConstraintSpace") {vm => installPhysicsConstraintSpace(vm)}
    _registerBinding("three.physics.common.PhysicsConstraintDesc") {vm => installPhysicsConstraintDesc(vm)}
    _registerBinding("three.physics.common.PhysicsConstraintHandle") {vm => installPhysicsConstraintHandle(vm)}
    _registerBinding("three.physics.common.PhysicsContactEvent") {vm => installPhysicsContactEvent(vm)}
    _registerBinding("three.physics.common.PhysicsBodyHandle") {vm => installPhysicsBodyHandle(vm)}
    _registerBinding("three.physics.common.PhysicsRayHit") {vm => installPhysicsRayHit(vm)}
    _registerBinding("three.physics.common.PhysicsPointHit") {vm => installPhysicsPointHit(vm)}
    _registerBinding("three.physics.common.PhysicsShapeHit") {vm => installPhysicsShapeHit(vm)}
    // —— three.physics.world / body / constraint ——
    _registerBinding("three.physics.world.PhysicsWorld") {vm => installPhysicsWorld(vm)}
    _registerBinding("three.physics.body.RigidBody") {vm => installRigidBody(vm)}
    _registerBinding("three.physics.constraint.PhysicsConstraint") {vm => installPhysicsConstraint(vm)}
    // —— three.physics.character ——
    _registerBinding("three.physics.character.PhysicsCharacterDesc") {vm => installPhysicsCharacterDesc(vm)}
    _registerBinding("three.physics.character.PhysicsCharacterFactory") {vm => installPhysicsCharacterFactory(vm)}
    _registerBinding("three.physics.character.PhysicsCharacter") {vm => installPhysicsCharacter(vm)}
    _registerBinding("three.physics.character.PhysicsCharacterVirtual") {vm => installPhysicsCharacterVirtual(vm)}
    // —— three.physics.heightfield ——
    _registerBinding("three.physics.heightfield.PhysicsHeightFieldDesc") {vm => installPhysicsHeightFieldDesc(vm)}
    _registerBinding("three.physics.heightfield.PhysicsHeightField") {vm => installPhysicsHeightField(vm)}
    _registerBinding("three.physics.heightfield.PhysicsHeightFieldFactory") {vm => installPhysicsHeightFieldFactory(vm)}
    // —— three.physics.softbody ——
    _registerBinding("three.physics.softbody.PhysicsSoftBodyDesc") {vm => installPhysicsSoftBodyDesc(vm)}
    _registerBinding("three.physics.softbody.PhysicsSoftBody") {vm => installPhysicsSoftBody(vm)}
    _registerBinding("three.physics.softbody.PhysicsSoftBodyFactory") {vm => installPhysicsSoftBodyFactory(vm)}
    // —— three.physics.vehicle ——
    _registerBinding("three.physics.vehicle.PhysicsVehicleWheelDesc") {vm => installPhysicsVehicleWheelDesc(vm)}
    _registerBinding("three.physics.vehicle.PhysicsVehicleEngineDesc") {vm => installPhysicsVehicleEngineDesc(vm)}
    _registerBinding("three.physics.vehicle.PhysicsVehicleDesc") {vm => installPhysicsVehicleDesc(vm)}
    _registerBinding("three.physics.vehicle.PhysicsVehicle") {vm => installPhysicsVehicle(vm)}
    _registerBinding("three.physics.vehicle.PhysicsVehicleFactory") {vm => installPhysicsVehicleFactory(vm)}
    // —— three.physics.ragdoll ——
    _registerBinding("three.physics.ragdoll.PhysicsSkeleton") {vm => installPhysicsSkeleton(vm)}
    _registerBinding("three.physics.ragdoll.PhysicsSkeletonPose") {vm => installPhysicsSkeletonPose(vm)}
    _registerBinding("three.physics.ragdoll.RagdollJoint") {vm => installRagdollJoint(vm)}
    _registerBinding("three.physics.ragdoll.RagdollPartSettings") {vm => installRagdollPartSettings(vm)}
    _registerBinding("three.physics.ragdoll.PhysicsRagdollSettings") {vm => installPhysicsRagdollSettings(vm)}
    _registerBinding("three.physics.ragdoll.PhysicsRagdoll") {vm => installPhysicsRagdoll(vm)}
    // —— three.physics.debug / binding / backend ——
    _registerBinding("three.physics.debug.PhysicsDebugLine") {vm => installPhysicsDebugLine(vm)}
    _registerBinding("three.physics.debug.PhysicsDebugTriangle") {vm => installPhysicsDebugTriangle(vm)}
    _registerBinding("three.physics.debug.PhysicsDebugRenderer") {vm => installPhysicsDebugRenderer(vm)}
    _registerBinding("three.physics.binding.PhysicsBinding") {vm => installPhysicsBinding(vm)}
    _registerBinding("three.physics.backend.JoltBackend") {vm => installJoltBackend(vm)}
    // —— three.profiler（Tracy 运行时门面） ——
    _registerBinding("three.profiler.TracyPlotFormat") {vm => installTracyPlotFormat(vm)}
    _registerBinding("three.profiler.TracyMessageSeverity") {vm => installTracyMessageSeverity(vm)}
    _registerBinding("three.profiler.ProfZone") {vm => installProfZone(vm)}
    _registerBinding("three.profiler.ProfFrame") {vm => installProfFrame(vm)}
    _registerBinding("three.profiler.ProfPlot") {vm => installProfPlot(vm)}
    _registerBinding("three.profiler.ProfMessage") {vm => installProfMessage(vm)}
    _registerBinding("three.profiler.ProfMemory") {vm => installProfMemory(vm)}
    _registerBinding("three.profiler.Gpu") {vm => installGpu(vm)}
    _registerBinding("three.profiler.Lock") {vm => installLock(vm)}
    _registerBinding("three.profiler.ProfFiber") {vm => installProfFiber(vm)}
    _registerBinding("three.profiler.ProfGpuZone") {vm => installProfGpuZone(vm)}
    _registerBinding("three.profiler.ProfLockZone") {vm => installProfLockZone(vm)}
    _registerBinding("three.profiler.FiberScope") {vm => installFiberScope(vm)}
    _registerBinding("three.profiler.Sampling") {vm => installSampling(vm)}
    _registerBinding("three.profiler.ProfilerState") {vm => installProfilerState(vm)}
    // —— three.resource.cache / archive / serializer ——
    _registerBinding("three.resource.cache.Cache") {vm => installCache(vm)}
    _registerBinding("three.resource.archive.ZipEntry") {vm => installZipEntry(vm)}
    _registerBinding("three.resource.archive.ZipArchive") {vm => installZipArchive(vm)}
    _registerBinding("three.resource.serializer.JsonSerializer") {vm => installJsonSerializer(vm)}
    // —— three.resource.pipeline（AssetBundle / AssetCache / AssetManager） ——
    _registerBinding("three.resource.pipeline.BundleEntry") {vm => installBundleEntry(vm)}
    _registerBinding("three.resource.pipeline.AssetBundle") {vm => installAssetBundle(vm)}
    _registerBinding("three.resource.pipeline.AssetBundleBuilder") {vm => installAssetBundleBuilder(vm)}
    _registerBinding("three.resource.pipeline.AssetCache") {vm => installAssetCache(vm)}
    _registerBinding("three.resource.pipeline.AssetManager") {vm => installAssetManager(vm)}
    // —— three.resource.loader（核心 / 通用加载器） ——
    _registerBinding("three.resource.loader.Loader") {vm => installLoader(vm)}
    _registerBinding("three.resource.loader.LoadingManager") {vm => installLoadingManager(vm)}
    _registerBinding("three.resource.loader.LoaderUtils") {vm => installLoaderUtils(vm)}
    _registerBinding("three.resource.loader.StringLoadResult") {vm => installStringLoadResult(vm)}
    _registerBinding("three.resource.loader.BytesLoadResult") {vm => installBytesLoadResult(vm)}
    _registerBinding("three.resource.loader.ClipsLoadResult") {vm => installClipsLoadResult(vm)}
    _registerBinding("three.resource.loader.FileLoader") {vm => installFileLoader(vm)}
    _registerBinding("three.resource.loader.ImageLoader") {vm => installImageLoader(vm)}
    _registerBinding("three.resource.loader.TextureLoader") {vm => installTextureLoader(vm)}
    _registerBinding("three.resource.loader.CubeTextureLoader") {vm => installCubeTextureLoader(vm)}
    _registerBinding("three.resource.loader.FontLoader") {vm => installFontLoader(vm)}
    _registerBinding("three.resource.loader.AnimationLoader") {vm => installAnimationLoader(vm)}
    _registerBinding("three.resource.loader.AudioLoader") {vm => installAudioLoader(vm)}
    _registerBinding("three.resource.loader.MaterialLoader") {vm => installMaterialLoader(vm)}
    // —— three.resource.loader（几何 / 模型） ——
    _registerBinding("three.resource.loader.BufferGeometryLoader") {vm => installBufferGeometryLoader(vm)}
    _registerBinding("three.resource.loader.OBJLoader") {vm => installOBJLoader(vm)}
    _registerBinding("three.resource.loader.PLYLoader") {vm => installPLYLoader(vm)}
    _registerBinding("three.resource.loader.STLLoader") {vm => installSTLLoader(vm)}
    _registerBinding("three.resource.loader.GltfLoader") {vm => installGltfLoader(vm)}
    _registerBinding("three.resource.loader.GltfAnimationChannel") {vm => installGltfAnimationChannel(vm)}
    _registerBinding("three.resource.loader.GltfAnimationSampler") {vm => installGltfAnimationSampler(vm)}
    _registerBinding("three.resource.loader.GltfAnimationData") {vm => installGltfAnimationData(vm)}
    _registerBinding("three.resource.loader.GltfSkinData") {vm => installGltfSkinData(vm)}
    // —— three.resource.loader（纹理格式） ——
    _registerBinding("three.resource.loader.CompressedTextureLoader") {vm => installCompressedTextureLoader(vm)}
    _registerBinding("three.resource.loader.DataTextureLoader") {vm => installDataTextureLoader(vm)}
    _registerBinding("three.resource.loader.DDSLoader") {vm => installDDSLoader(vm)}
    _registerBinding("three.resource.loader.KTXLoader") {vm => installKTXLoader(vm)}
    _registerBinding("three.resource.loader.PVRLoader") {vm => installPVRLoader(vm)}
    _registerBinding("three.resource.loader.EXRLoader") {vm => installEXRLoader(vm)}
    _registerBinding("three.resource.loader.HDRLoader") {vm => installHDRLoader(vm)}
    _registerBinding("three.resource.loader.RGBELoader") {vm => installRGBELoader(vm)}
    _registerBinding("three.resource.loader.TGALoader") {vm => installTGALoader(vm)}
    _registerBinding("three.resource.loader.MTLLoader") {vm => installMTLLoader(vm)}
    _registerBinding("three.resource.loader.MaterialCreator") {vm => installMaterialCreator(vm)}
    // —— three.scene.ecs（运行时 + 注册表 + 管理器） ——
    _registerBinding("three.scene.ecs.EcsObject") {vm => installEcsObject(vm)}
    _registerBinding("three.scene.ecs.Component") {vm => installComponent(vm)}
    _registerBinding("three.scene.ecs.ComponentRegistry") {vm => installComponentRegistry(vm)}
    _registerBinding("three.scene.ecs.Entity") {vm => installEntity(vm)}
    _registerBinding("three.scene.ecs.System") {vm => installSystem(vm)}
    _registerBinding("three.scene.ecs.World") {vm => installWorld(vm)}
    _registerBinding("three.scene.ecs.EntityManager") {vm => installEntityManager(vm)}
    _registerBinding("three.scene.ecs.ComponentManager") {vm => installComponentManager(vm)}
    _registerBinding("three.scene.ecs.SystemManager") {vm => installSystemManager(vm)}
    _registerBinding("three.scene.ecs.ArrSysEtyMapManager") {vm => installArrSysEtyMapManager(vm)}
    _registerBinding("three.scene.ecs.TreeSysEtyMapManager") {vm => installTreeSysEtyMapManager(vm)}
    // —— three.scene.objects ——
    _registerBinding("three.scene.objects.Object3D") {vm => installObject3D(vm)}
    _registerBinding("three.scene.objects.Layers") {vm => installLayers(vm)}
    _registerBinding("three.scene.objects.Intersection") {vm => installIntersection(vm)}
    _registerBinding("three.scene.objects.Face") {vm => installFace(vm)}
    _registerBinding("three.scene.objects.RaycasterParams") {vm => installRaycasterParams(vm)}
    _registerBinding("three.scene.objects.Raycaster") {vm => installRaycaster(vm)}
    // —— three.scene.scenegraph ——
    _registerBinding("three.scene.scenegraph.Scene") {vm => installScene(vm)}
    _registerBinding("three.scene.scenegraph.Group") {vm => installGroup(vm)}
    _registerBinding("three.scene.scenegraph.Fog") {vm => installFog(vm)}
    _registerBinding("three.scene.scenegraph.FogExp2") {vm => installFogExp2(vm)}
    _registerBinding("three.scene.scenegraph.ClippingGroup") {vm => installClippingGroup(vm)}
    // —— three.scene.entity（网格 / 骨骼 / 批处理） ——
    _registerBinding("three.scene.entity.Mesh") {vm => installMesh(vm)}
    _registerBinding("three.scene.entity.SkinnedMesh") {vm => installSkinnedMesh(vm)}
    _registerBinding("three.scene.entity.Bone") {vm => installBone(vm)}
    _registerBinding("three.scene.entity.Skeleton") {vm => installSkeleton(vm)}
    _registerBinding("three.scene.entity.InstancedMesh") {vm => installInstancedMesh(vm)}
    _registerBinding("three.scene.entity.BatchedMesh") {vm => installBatchedMesh(vm)}
    _registerBinding("three.scene.entity.StaticBatch") {vm => installStaticBatch(vm)}
    // —— three.scene.entity（线 / 点 / 精灵 / LOD） ——
    _registerBinding("three.scene.entity.Line") {vm => installLine(vm)}
    _registerBinding("three.scene.entity.LineLoop") {vm => installLineLoop(vm)}
    _registerBinding("three.scene.entity.LineSegments") {vm => installLineSegments(vm)}
    _registerBinding("three.scene.entity.Points") {vm => installPoints(vm)}
    _registerBinding("three.scene.entity.Sprite") {vm => installSprite(vm)}
    _registerBinding("three.scene.entity.LOD") {vm => installLOD(vm)}
    _registerBinding("three.scene.entity.GroundReflector") {vm => installGroundReflector(vm)}
    // —— three.window（窗口 / 输入 / 声明式窗口 / UI 上下文） ——
    _registerBinding("three.window.GamepadAxis") {vm => installGamepadAxis(vm)}
    _registerBinding("three.window.GamepadButton") {vm => installGamepadButton(vm)}
    _registerBinding("three.window.GamepadProvider") {vm => installGamepadProvider(vm)}
    _registerBinding("three.window.InputEngine") {vm => installInputEngine(vm)}
    _registerBinding("three.window.InputProvider") {vm => installInputProvider(vm)}
    _registerBinding("three.window.KeyboardProvider") {vm => installKeyboardProvider(vm)}
    _registerBinding("three.window.KeyCode") {vm => installKeyCode(vm)}
    _registerBinding("three.window.KeyEvent") {vm => installKeyEvent(vm)}
    _registerBinding("three.window.MouseButton") {vm => installMouseButton(vm)}
    _registerBinding("three.window.MouseButtonEvent") {vm => installMouseButtonEvent(vm)}
    _registerBinding("three.window.MouseMotionEvent") {vm => installMouseMotionEvent(vm)}
    _registerBinding("three.window.MouseProvider") {vm => installMouseProvider(vm)}
    _registerBinding("three.window.MouseWheelEvent") {vm => installMouseWheelEvent(vm)}
    _registerBinding("three.window.SystemCursor") {vm => installSystemCursor(vm)}
    _registerBinding("three.window.TouchEvent") {vm => installTouchEvent(vm)}
    _registerBinding("three.window.TouchPoint") {vm => installTouchPoint(vm)}
    _registerBinding("three.window.TouchProvider") {vm => installTouchProvider(vm)}
    _registerBinding("three.window.UiContext") {vm => installUiContext(vm)}
    _registerBinding("three.window.Window") {vm => installDeclarativeWindow(vm)}
    _registerBinding("three.window.WindowConfig") {vm => installWindowConfig(vm)}
    _registerBinding("three.window.WindowEngine") {vm => installWindowEngine(vm)}
    _registerBinding("three.window.WindowEvent") {vm => installWindowEvent(vm)}
    // —— three.window.ui（ImGui 控件 / 布局 / 样式 / 字体 / 绘制列表） ——
    _registerBinding("three.window.ui.UiAcceptDragDropPayload") {vm => installUiAcceptDragDropPayload(vm)}
    _registerBinding("three.window.ui.UiArrowButton") {vm => installUiArrowButton(vm)}
    _registerBinding("three.window.ui.UiBeginCombo") {vm => installUiBeginCombo(vm)}
    _registerBinding("three.window.ui.UiBeginListBox") {vm => installUiBeginListBox(vm)}
    _registerBinding("three.window.ui.UiBullet") {vm => installUiBullet(vm)}
    _registerBinding("three.window.ui.UiButton") {vm => installUiButton(vm)}
    _registerBinding("three.window.ui.UiCheckbox") {vm => installUiCheckbox(vm)}
    _registerBinding("three.window.ui.UiCheckboxFlags") {vm => installUiCheckboxFlags(vm)}
    _registerBinding("three.window.ui.UiChildWindow") {vm => installUiChildWindow(vm)}
    _registerBinding("three.window.ui.UiClipRect") {vm => installUiClipRect(vm)}
    _registerBinding("three.window.ui.UiCloseCurrentPopup") {vm => installUiCloseCurrentPopup(vm)}
    _registerBinding("three.window.ui.UiCollapsingHeader") {vm => installUiCollapsingHeader(vm)}
    _registerBinding("three.window.ui.UiColorButton") {vm => installUiColorButton(vm)}
    _registerBinding("three.window.ui.UiColorEdit3") {vm => installUiColorEdit3(vm)}
    _registerBinding("three.window.ui.UiColorEdit4") {vm => installUiColorEdit4(vm)}
    _registerBinding("three.window.ui.UiColorPicker3") {vm => installUiColorPicker3(vm)}
    _registerBinding("three.window.ui.UiColorPicker4") {vm => installUiColorPicker4(vm)}
    _registerBinding("three.window.ui.UiColumns") {vm => installUiColumns(vm)}
    _registerBinding("three.window.ui.UiCombo") {vm => installUiCombo(vm)}
    _registerBinding("three.window.ui.UiComboPreview") {vm => installUiComboPreview(vm)}
    _registerBinding("three.window.ui.UiCursor") {vm => installUiCursor(vm)}
    _registerBinding("three.window.ui.UiDisabled") {vm => installUiDisabled(vm)}
    _registerBinding("three.window.ui.UiDisabledBlock") {vm => installUiDisabledBlock(vm)}
    _registerBinding("three.window.ui.UiDragDropSource") {vm => installUiDragDropSource(vm)}
    _registerBinding("three.window.ui.UiDragDropTarget") {vm => installUiDragDropTarget(vm)}
    _registerBinding("three.window.ui.UiDragFloat") {vm => installUiDragFloat(vm)}
    _registerBinding("three.window.ui.UiDragFloat2") {vm => installUiDragFloat2(vm)}
    _registerBinding("three.window.ui.UiDragFloat3") {vm => installUiDragFloat3(vm)}
    _registerBinding("three.window.ui.UiDragFloat4") {vm => installUiDragFloat4(vm)}
    _registerBinding("three.window.ui.UiDragInt") {vm => installUiDragInt(vm)}
    _registerBinding("three.window.ui.UiDragInt2") {vm => installUiDragInt2(vm)}
    _registerBinding("three.window.ui.UiDragInt3") {vm => installUiDragInt3(vm)}
    _registerBinding("three.window.ui.UiDragInt4") {vm => installUiDragInt4(vm)}
    _registerBinding("three.window.ui.UiDrawList") {vm => installUiDrawList(vm)}
    _registerBinding("three.window.ui.UiDummy") {vm => installUiDummy(vm)}
    _registerBinding("three.window.ui.UiEndCombo") {vm => installUiEndCombo(vm)}
    _registerBinding("three.window.ui.UiEndListBox") {vm => installUiEndListBox(vm)}
    _registerBinding("three.window.ui.UiEndPopup") {vm => installUiEndPopup(vm)}
    _registerBinding("three.window.ui.UiFont") {vm => installUiFont(vm)}
    _registerBinding("three.window.ui.UiFontAtlas") {vm => installUiFontAtlas(vm)}
    _registerBinding("three.window.ui.UiFontBaked") {vm => installUiFontBaked(vm)}
    _registerBinding("three.window.ui.UiFontConfig") {vm => installUiFontConfig(vm)}
    _registerBinding("three.window.ui.UiFontData") {vm => installUiFontData(vm)}
    _registerBinding("three.window.ui.UiFontGlyph") {vm => installUiFontGlyph(vm)}
    _registerBinding("three.window.ui.UiFontGlyphRangesBuilder") {vm => installUiFontGlyphRangesBuilder(vm)}
    _registerBinding("three.window.ui.UiGetDragDropPayload") {vm => installUiGetDragDropPayload(vm)}
    _registerBinding("three.window.ui.UiGlyphRanges") {vm => installUiGlyphRanges(vm)}
    _registerBinding("three.window.ui.UiGroup") {vm => installUiGroup(vm)}
    _registerBinding("three.window.ui.UiIdScope") {vm => installUiIdScope(vm)}
    _registerBinding("three.window.ui.UiImage") {vm => installUiImage(vm)}
    _registerBinding("three.window.ui.UiImageButton") {vm => installUiImageButton(vm)}
    _registerBinding("three.window.ui.UiIndent") {vm => installUiIndent(vm)}
    _registerBinding("three.window.ui.UiInputDouble") {vm => installUiInputDouble(vm)}
    _registerBinding("three.window.ui.UiInputFloat") {vm => installUiInputFloat(vm)}
    _registerBinding("three.window.ui.UiInputFloat2") {vm => installUiInputFloat2(vm)}
    _registerBinding("three.window.ui.UiInputFloat3") {vm => installUiInputFloat3(vm)}
    _registerBinding("three.window.ui.UiInputFloat4") {vm => installUiInputFloat4(vm)}
    _registerBinding("three.window.ui.UiInputInt") {vm => installUiInputInt(vm)}
    _registerBinding("three.window.ui.UiInputInt2") {vm => installUiInputInt2(vm)}
    _registerBinding("three.window.ui.UiInputInt3") {vm => installUiInputInt3(vm)}
    _registerBinding("three.window.ui.UiInputInt4") {vm => installUiInputInt4(vm)}
    _registerBinding("three.window.ui.UiInputText") {vm => installUiInputText(vm)}
    _registerBinding("three.window.ui.UiInputTextCallback") {vm => installUiInputTextCallback(vm)}
    _registerBinding("three.window.ui.UiInputTextMultiline") {vm => installUiInputTextMultiline(vm)}
    _registerBinding("three.window.ui.UiInvisibleButton") {vm => installUiInvisibleButton(vm)}
    _registerBinding("three.window.ui.UiItemFlags") {vm => installUiItemFlags(vm)}
    _registerBinding("three.window.ui.UiItemQuery") {vm => installUiItemQuery(vm)}
    _registerBinding("three.window.ui.UiKeyboard") {vm => installUiKeyboard(vm)}
    _registerBinding("three.window.ui.UiLabelText") {vm => installUiLabelText(vm)}
    _registerBinding("three.window.ui.UiListBox") {vm => installUiListBox(vm)}
    _registerBinding("three.window.ui.UiListClipper") {vm => installUiListClipper(vm)}
    _registerBinding("three.window.ui.UiMainMenuBar") {vm => installUiMainMenuBar(vm)}
    _registerBinding("three.window.ui.UiMenu") {vm => installUiMenu(vm)}
    _registerBinding("three.window.ui.UiMenuBar") {vm => installUiMenuBar(vm)}
    _registerBinding("three.window.ui.UiMenuItem") {vm => installUiMenuItem(vm)}
    _registerBinding("three.window.ui.UiMenuSeparator") {vm => installUiMenuSeparator(vm)}
    _registerBinding("three.window.ui.UiMouse") {vm => installUiMouse(vm)}
    _registerBinding("three.window.ui.UiNewLine") {vm => installUiNewLine(vm)}
    _registerBinding("three.window.ui.UiOpenPopup") {vm => installUiOpenPopup(vm)}
    _registerBinding("three.window.ui.UiPayload") {vm => installUiPayload(vm)}
    _registerBinding("three.window.ui.UiPlotHistogram") {vm => installUiPlotHistogram(vm)}
    _registerBinding("three.window.ui.UiPlotLines") {vm => installUiPlotLines(vm)}
    _registerBinding("three.window.ui.UiPopup") {vm => installUiPopup(vm)}
    _registerBinding("three.window.ui.UiPopupModal") {vm => installUiPopupModal(vm)}
    _registerBinding("three.window.ui.UiProgressBar") {vm => installUiProgressBar(vm)}
    _registerBinding("three.window.ui.UiRadioButton") {vm => installUiRadioButton(vm)}
    _registerBinding("three.window.ui.UiRadioButtonGroup") {vm => installUiRadioButtonGroup(vm)}
    _registerBinding("three.window.ui.UiSameLine") {vm => installUiSameLine(vm)}
    _registerBinding("three.window.ui.UiSelectable") {vm => installUiSelectable(vm)}
    _registerBinding("three.window.ui.UiSeparator") {vm => installUiSeparator(vm)}
    _registerBinding("three.window.ui.UiSeparatorText") {vm => installUiSeparatorText(vm)}
    _registerBinding("three.window.ui.UiSetDragDropPayload") {vm => installUiSetDragDropPayload(vm)}
    _registerBinding("three.window.ui.UiSetNextItemOpen") {vm => installUiSetNextItemOpen(vm)}
    _registerBinding("three.window.ui.UiSetNextItemWidth") {vm => installUiSetNextItemWidth(vm)}
    _registerBinding("three.window.ui.UiSetTabItemClosed") {vm => installUiSetTabItemClosed(vm)}
    _registerBinding("three.window.ui.UiSetTooltip") {vm => installUiSetTooltip(vm)}
    _registerBinding("three.window.ui.UiSliderAngle") {vm => installUiSliderAngle(vm)}
    _registerBinding("three.window.ui.UiSliderFloat") {vm => installUiSliderFloat(vm)}
    _registerBinding("three.window.ui.UiSliderFloat2") {vm => installUiSliderFloat2(vm)}
    _registerBinding("three.window.ui.UiSliderFloat3") {vm => installUiSliderFloat3(vm)}
    _registerBinding("three.window.ui.UiSliderFloat4") {vm => installUiSliderFloat4(vm)}
    _registerBinding("three.window.ui.UiSliderInt") {vm => installUiSliderInt(vm)}
    _registerBinding("three.window.ui.UiSliderInt2") {vm => installUiSliderInt2(vm)}
    _registerBinding("three.window.ui.UiSliderInt3") {vm => installUiSliderInt3(vm)}
    _registerBinding("three.window.ui.UiSliderInt4") {vm => installUiSliderInt4(vm)}
    _registerBinding("three.window.ui.UiSmallButton") {vm => installUiSmallButton(vm)}
    _registerBinding("three.window.ui.UiSpacing") {vm => installUiSpacing(vm)}
    _registerBinding("three.window.ui.UiStorage") {vm => installUiStorage(vm)}
    _registerBinding("three.window.ui.UiStyle") {vm => installUiStyle(vm)}
    _registerBinding("three.window.ui.UiStyleColor") {vm => installUiStyleColor(vm)}
    _registerBinding("three.window.ui.UiSystem") {vm => installUiSystem(vm)}
    _registerBinding("three.window.ui.UiTabBar") {vm => installUiTabBar(vm)}
    _registerBinding("three.window.ui.UiTabItem") {vm => installUiTabItem(vm)}
    _registerBinding("three.window.ui.UiTabItemButton") {vm => installUiTabItemButton(vm)}
    _registerBinding("three.window.ui.UiTable") {vm => installUiTable(vm)}
    _registerBinding("three.window.ui.UiTableCell") {vm => installUiTableCell(vm)}
    _registerBinding("three.window.ui.UiTableHeader") {vm => installUiTableHeader(vm)}
    _registerBinding("three.window.ui.UiTableHeadersRow") {vm => installUiTableHeadersRow(vm)}
    _registerBinding("three.window.ui.UiTableRow") {vm => installUiTableRow(vm)}
    _registerBinding("three.window.ui.UiTableSetupColumn") {vm => installUiTableSetupColumn(vm)}
    _registerBinding("three.window.ui.UiTableSetupScrollFreeze") {vm => installUiTableSetupScrollFreeze(vm)}
    _registerBinding("three.window.ui.UiText") {vm => installUiText(vm)}
    _registerBinding("three.window.ui.UiTextBullet") {vm => installUiTextBullet(vm)}
    _registerBinding("three.window.ui.UiTextColored") {vm => installUiTextColored(vm)}
    _registerBinding("three.window.ui.UiTextDisabled") {vm => installUiTextDisabled(vm)}
    _registerBinding("three.window.ui.UiTextFilter") {vm => installUiTextFilter(vm)}
    _registerBinding("three.window.ui.UiTextLink") {vm => installUiTextLink(vm)}
    _registerBinding("three.window.ui.UiTextWrapped") {vm => installUiTextWrapped(vm)}
    _registerBinding("three.window.ui.UiTheme") {vm => installUiTheme(vm)}
    _registerBinding("three.window.ui.UiTooltip") {vm => installUiTooltip(vm)}
    _registerBinding("three.window.ui.UiTreeNode") {vm => installUiTreeNode(vm)}
    _registerBinding("three.window.ui.UiTreeNodeEx") {vm => installUiTreeNodeEx(vm)}
    _registerBinding("three.window.ui.UiUnindent") {vm => installUiUnindent(vm)}
    _registerBinding("three.window.ui.UiValue") {vm => installUiValue(vm)}
    _registerBinding("three.window.ui.UiValueBool") {vm => installUiValueBool(vm)}
    _registerBinding("three.window.ui.UiValueInt") {vm => installUiValueInt(vm)}
    _registerBinding("three.window.ui.UiValueUint") {vm => installUiValueUint(vm)}
    _registerBinding("three.window.ui.UiViewport") {vm => installUiViewport(vm)}
    _registerBinding("three.window.ui.UiVSliderFloat") {vm => installUiVSliderFloat(vm)}
    _registerBinding("three.window.ui.UiWidget") {vm => installUiWidget(vm)}
    _registerBinding("three.window.ui.UiWindow") {vm => installUiWindow(vm)}
    // —— three.renderers.buffer（缓冲属性与交错缓冲） ——
    _registerBinding("three.renderers.buffer.BufferAttribute") {vm => installBufferAttribute(vm)}
    _registerBinding("three.renderers.buffer.Float32BufferAttribute") {vm => installFloat32BufferAttribute(vm)}
    _registerBinding("three.renderers.buffer.Uint16BufferAttribute") {vm => installUint16BufferAttribute(vm)}
    _registerBinding("three.renderers.buffer.Uint32BufferAttribute") {vm => installUint32BufferAttribute(vm)}
    _registerBinding("three.renderers.buffer.UpdateRange") {vm => installUpdateRange(vm)}
    _registerBinding("three.renderers.buffer.InterleavedBuffer") {vm => installInterleavedBuffer(vm)}
    _registerBinding("three.renderers.buffer.InstancedInterleavedBuffer") {vm => installInstancedInterleavedBuffer(vm)}
    _registerBinding("three.renderers.buffer.InterleavedBufferAttribute") {vm => installInterleavedBufferAttribute(vm)}
    _registerBinding("three.renderers.buffer.GLBufferAttribute") {vm => installGLBufferAttribute(vm)}
    _registerBinding("three.renderers.buffer.InstancedBufferAttribute") {vm => installInstancedBufferAttribute(vm)}
    // —— three.renderers.textures（纹理与数据源） ——
    _registerBinding("three.renderers.textures.Texture") {vm => installTexture(vm)}
    _registerBinding("three.renderers.textures.Source") {vm => installTextureSource(vm)}
    _registerBinding("three.renderers.textures.DataTexture") {vm => installDataTexture(vm)}
    _registerBinding("three.renderers.textures.Data3DTexture") {vm => installData3DTexture(vm)}
    _registerBinding("three.renderers.textures.DataArrayTexture") {vm => installDataArrayTexture(vm)}
    _registerBinding("three.renderers.textures.CompressedTexture") {vm => installCompressedTexture(vm)}
    _registerBinding("three.renderers.textures.CompressedArrayTexture") {vm => installCompressedArrayTexture(vm)}
    _registerBinding("three.renderers.textures.CompressedCubeTexture") {vm => installCompressedCubeTexture(vm)}
    _registerBinding("three.renderers.textures.CubeTexture") {vm => installCubeTexture(vm)}
    _registerBinding("three.renderers.textures.DepthTexture") {vm => installDepthTexture(vm)}
    _registerBinding("three.renderers.textures.CubeDepthTexture") {vm => installCubeDepthTexture(vm)}
    _registerBinding("three.renderers.textures.CanvasTexture") {vm => installCanvasTexture(vm)}
    _registerBinding("three.renderers.textures.VideoTexture") {vm => installVideoTexture(vm)}
    _registerBinding("three.renderers.textures.VideoFrameTexture") {vm => installVideoFrameTexture(vm)}
    _registerBinding("three.renderers.textures.FramebufferTexture") {vm => installFramebufferTexture(vm)}
    _registerBinding("three.renderers.textures.ExternalTexture") {vm => installExternalTexture(vm)}
    _registerBinding("three.renderers.textures.ImageUtils") {vm => installImageUtils(vm)}
    _registerBinding("three.renderers.textures.TextureUtils") {vm => installTextureUtils(vm)}
    _registerBinding("three.renderers.textures.TypeByteLength") {vm => installTypeByteLength(vm)}
    _registerBinding("three.renderers.textures.PMREMGenerator") {vm => installPMREMGenerator(vm)}
    // —— three.renderers.rendertarget（渲染目标） ——
    _registerBinding("three.renderers.rendertarget.RenderTargetOptions") {vm => installRenderTargetOptions(vm)}
    _registerBinding("three.renderers.rendertarget.RenderTarget") {vm => installRenderTarget(vm)}
    _registerBinding("three.renderers.rendertarget.RenderTarget3D") {vm => installRenderTarget3D(vm)}
    // —— three.renderers.geometry（几何体与曲线） ——
    _registerBinding("three.renderers.geometry.BufferGeometry") {vm => installBufferGeometry(vm)}
    _registerBinding("three.renderers.geometry.BufferGeometryGroup") {vm => installBufferGeometryGroup(vm)}
    _registerBinding("three.renderers.geometry.InstancedBufferGeometry") {vm => installInstancedBufferGeometry(vm)}
    _registerBinding("three.renderers.geometry.Curve") {vm => installCurve(vm)}
    _registerBinding("three.renderers.geometry.CurvePath") {vm => installCurvePath(vm)}
    _registerBinding("three.renderers.geometry.Path") {vm => installPath(vm)}
    _registerBinding("three.renderers.geometry.Shape") {vm => installShape(vm)}
    _registerBinding("three.renderers.geometry.ShapePath") {vm => installShapePath(vm)}
    _registerBinding("three.renderers.geometry.ShapeUtils") {vm => installShapeUtils(vm)}
    _registerBinding("three.renderers.geometry.DataUtils") {vm => installDataUtils(vm)}
    _registerBinding("three.renderers.geometry.Earcut") {vm => installEarcut(vm)}
    _registerBinding("three.renderers.geometry.EllipseCurve") {vm => installEllipseCurve(vm)}
    _registerBinding("three.renderers.geometry.ArcCurve") {vm => installArcCurve(vm)}
    _registerBinding("three.renderers.geometry.LineCurve") {vm => installLineCurve(vm)}
    _registerBinding("three.renderers.geometry.LineCurve3") {vm => installLineCurve3(vm)}
    _registerBinding("three.renderers.geometry.CatmullRomCurve3") {vm => installCatmullRomCurve3(vm)}
    _registerBinding("three.renderers.geometry.CubicBezierCurve") {vm => installCubicBezierCurve(vm)}
    _registerBinding("three.renderers.geometry.CubicBezierCurve3") {vm => installCubicBezierCurve3(vm)}
    _registerBinding("three.renderers.geometry.QuadraticBezierCurve") {vm => installQuadraticBezierCurve(vm)}
    _registerBinding("three.renderers.geometry.QuadraticBezierCurve3") {vm => installQuadraticBezierCurve3(vm)}
    _registerBinding("three.renderers.geometry.SplineCurve") {vm => installSplineCurve(vm)}
    _registerBinding("three.renderers.geometry.BoxGeometry") {vm => installBoxGeometry(vm)}
    _registerBinding("three.renderers.geometry.CapsuleGeometry") {vm => installCapsuleGeometry(vm)}
    _registerBinding("three.renderers.geometry.CircleGeometry") {vm => installCircleGeometry(vm)}
    _registerBinding("three.renderers.geometry.ConeGeometry") {vm => installConeGeometry(vm)}
    _registerBinding("three.renderers.geometry.CylinderGeometry") {vm => installCylinderGeometry(vm)}
    _registerBinding("three.renderers.geometry.DodecahedronGeometry") {vm => installDodecahedronGeometry(vm)}
    _registerBinding("three.renderers.geometry.EdgesGeometry") {vm => installEdgesGeometry(vm)}
    _registerBinding("three.renderers.geometry.ExtrudeGeometry") {vm => installExtrudeGeometry(vm)}
    _registerBinding("three.renderers.geometry.IcosahedronGeometry") {vm => installIcosahedronGeometry(vm)}
    _registerBinding("three.renderers.geometry.LatheGeometry") {vm => installLatheGeometry(vm)}
    _registerBinding("three.renderers.geometry.OctahedronGeometry") {vm => installOctahedronGeometry(vm)}
    _registerBinding("three.renderers.geometry.PlaneGeometry") {vm => installPlaneGeometry(vm)}
    _registerBinding("three.renderers.geometry.PolyhedronGeometry") {vm => installPolyhedronGeometry(vm)}
    _registerBinding("three.renderers.geometry.RingGeometry") {vm => installRingGeometry(vm)}
    _registerBinding("three.renderers.geometry.ShapeGeometry") {vm => installShapeGeometry(vm)}
    _registerBinding("three.renderers.geometry.SphereGeometry") {vm => installSphereGeometry(vm)}
    _registerBinding("three.renderers.geometry.TetrahedronGeometry") {vm => installTetrahedronGeometry(vm)}
    _registerBinding("three.renderers.geometry.TorusGeometry") {vm => installTorusGeometry(vm)}
    _registerBinding("three.renderers.geometry.TorusKnotGeometry") {vm => installTorusKnotGeometry(vm)}
    _registerBinding("three.renderers.geometry.TubeGeometry") {vm => installTubeGeometry(vm)}
    _registerBinding("three.renderers.geometry.WireframeGeometry") {vm => installWireframeGeometry(vm)}
    // —— three.renderers.materials（材质族） ——
    _registerBinding("three.renderers.materials.Material") {vm => installMaterial(vm)}
    _registerBinding("three.renderers.materials.MaterialOverrideScope") {vm => installMaterialOverrideScope(vm)}
    _registerBinding("three.renderers.materials.MeshBasicMaterial") {vm => installMeshBasicMaterial(vm)}
    _registerBinding("three.renderers.materials.MeshStandardMaterial") {vm => installMeshStandardMaterial(vm)}
    _registerBinding("three.renderers.materials.MeshPhysicalMaterial") {vm => installMeshPhysicalMaterial(vm)}
    _registerBinding("three.renderers.materials.MeshPhongMaterial") {vm => installMeshPhongMaterial(vm)}
    _registerBinding("three.renderers.materials.MeshLambertMaterial") {vm => installMeshLambertMaterial(vm)}
    _registerBinding("three.renderers.materials.MeshToonMaterial") {vm => installMeshToonMaterial(vm)}
    _registerBinding("three.renderers.materials.MeshNormalMaterial") {vm => installMeshNormalMaterial(vm)}
    _registerBinding("three.renderers.materials.MeshMatcapMaterial") {vm => installMeshMatcapMaterial(vm)}
    _registerBinding("three.renderers.materials.MeshDepthMaterial") {vm => installMeshDepthMaterial(vm)}
    _registerBinding("three.renderers.materials.MeshDistanceMaterial") {vm => installMeshDistanceMaterial(vm)}
    _registerBinding("three.renderers.materials.SpriteMaterial") {vm => installSpriteMaterial(vm)}
    _registerBinding("three.renderers.materials.ShadowMaterial") {vm => installShadowMaterial(vm)}
    _registerBinding("three.renderers.materials.PointsMaterial") {vm => installPointsMaterial(vm)}
    _registerBinding("three.renderers.materials.LineBasicMaterial") {vm => installLineBasicMaterial(vm)}
    _registerBinding("three.renderers.materials.LineDashedMaterial") {vm => installLineDashedMaterial(vm)}
    _registerBinding("three.renderers.materials.ReflectorMaterial") {vm => installReflectorMaterial(vm)}
    _registerBinding("three.renderers.materials.ShaderMaterial") {vm => installShaderMaterial(vm)}
    _registerBinding("three.renderers.materials.RawShaderMaterial") {vm => installRawShaderMaterial(vm)}
    _registerBinding("three.renderers.materials.ShadowProjMaterial") {vm => installShadowProjMaterial(vm)}
    _registerBinding("three.renderers.materials.ShadowFrustumMaterial") {vm => installShadowFrustumMaterial(vm)}
    _registerBinding("three.renderers.materials.ShadowBlitMaterial") {vm => installShadowBlitMaterial(vm)}
    _registerBinding("three.renderers.materials.PcfVizMaterial") {vm => installPcfVizMaterial(vm)}
    _registerBinding("three.renderers.materials.LightDirMaterial") {vm => installLightDirMaterial(vm)}
    _registerBinding("three.renderers.materials.DepthVizMaterial") {vm => installDepthVizMaterial(vm)}
    // —— three.renderers.cameras（相机族） ——
    _registerBinding("three.renderers.cameras.Camera") {vm => installCamera(vm)}
    _registerBinding("three.renderers.cameras.PerspectiveCamera") {vm => installPerspectiveCamera(vm)}
    _registerBinding("three.renderers.cameras.OrthographicCamera") {vm => installOrthographicCamera(vm)}
    _registerBinding("three.renderers.cameras.ArrayCamera") {vm => installArrayCamera(vm)}
    _registerBinding("three.renderers.cameras.CubeCamera") {vm => installCubeCamera(vm)}
    _registerBinding("three.renderers.cameras.StereoCamera") {vm => installStereoCamera(vm)}
    _registerBinding("three.renderers.cameras.CameraView") {vm => installCameraView(vm)}
    // —— three.renderers.lights（光照与阴影） ——
    _registerBinding("three.renderers.lights.Light") {vm => installLight(vm)}
    _registerBinding("three.renderers.lights.AmbientLight") {vm => installAmbientLight(vm)}
    _registerBinding("three.renderers.lights.DirectionalLight") {vm => installDirectionalLight(vm)}
    _registerBinding("three.renderers.lights.HemisphereLight") {vm => installHemisphereLight(vm)}
    _registerBinding("three.renderers.lights.PointLight") {vm => installPointLight(vm)}
    _registerBinding("three.renderers.lights.RectAreaLight") {vm => installRectAreaLight(vm)}
    _registerBinding("three.renderers.lights.SpotLight") {vm => installSpotLight(vm)}
    _registerBinding("three.renderers.lights.LightProbe") {vm => installLightProbe(vm)}
    _registerBinding("three.renderers.lights.LightShadow") {vm => installLightShadow(vm)}
    _registerBinding("three.renderers.lights.DirectionalLightShadow") {vm => installDirectionalLightShadow(vm)}
    _registerBinding("three.renderers.lights.PointLightShadow") {vm => installPointLightShadow(vm)}
    _registerBinding("three.renderers.lights.SpotLightShadow") {vm => installSpotLightShadow(vm)}
    _registerBinding("three.renderers.lights.ShadowConstants") {vm => installShadowConstants(vm)}
    // —— three.renderers.helpers（可视化辅助对象） ——
    _registerBinding("three.renderers.helpers.ArrowHelper") {vm => installArrowHelper(vm)}
    _registerBinding("three.renderers.helpers.AudioListenerHelper") {vm => installAudioListenerHelper(vm)}
    _registerBinding("three.renderers.helpers.AxesHelper") {vm => installAxesHelper(vm)}
    _registerBinding("three.renderers.helpers.Box3Helper") {vm => installBox3Helper(vm)}
    _registerBinding("three.renderers.helpers.BoxHelper") {vm => installBoxHelper(vm)}
    _registerBinding("three.renderers.helpers.CameraHelper") {vm => installCameraHelper(vm)}
    _registerBinding("three.renderers.helpers.ConstraintHelper") {vm => installConstraintHelper(vm)}
    _registerBinding("three.renderers.helpers.DirectionalLightHelper") {vm => installDirectionalLightHelper(vm)}
    _registerBinding("three.renderers.helpers.GridHelper") {vm => installGridHelper(vm)}
    _registerBinding("three.renderers.helpers.HemisphereLightHelper") {vm => installHemisphereLightHelper(vm)}
    _registerBinding("three.renderers.helpers.PlaneHelper") {vm => installPlaneHelper(vm)}
    _registerBinding("three.renderers.helpers.PointLightHelper") {vm => installPointLightHelper(vm)}
    _registerBinding("three.renderers.helpers.PolarGridHelper") {vm => installPolarGridHelper(vm)}
    _registerBinding("three.renderers.helpers.PositionalAudioHelper") {vm => installPositionalAudioHelper(vm)}
    _registerBinding("three.renderers.helpers.RigidBodyHelper") {vm => installRigidBodyHelper(vm)}
    _registerBinding("three.renderers.helpers.SkeletonHelper") {vm => installSkeletonHelper(vm)}
    _registerBinding("three.renderers.helpers.SpotLightHelper") {vm => installSpotLightHelper(vm)}
    // —— three.renderers（根渲染器 ThreeRenderer） ——
    _registerBinding("three.renderers.ThreeRenderer") {vm => installThreeRenderer(vm)}
    _registerBinding("three.renderers.textures.EngineDataTexture") {vm => installEngineDataTexture(vm)}
    _registerBinding("three.renderers.rendertarget.EngineRenderTarget") {vm => installEngineRenderTarget(vm)}
    // —— three.renderers.common（渲染统计 / 通用常量） ——
    _registerBinding("three.renderers.common.Info") {vm => installInfo(vm)}
    _registerBinding("three.renderers.common.RenderInfo") {vm => installRenderInfo(vm)}
    _registerBinding("three.renderers.common.ComputeInfo") {vm => installComputeInfo(vm)}
    _registerBinding("three.renderers.common.MemoryInfo") {vm => installMemoryInfo(vm)}
    _registerBinding("three.renderers.common.Constants") {vm => installrenderersConstants(vm)}
    // —— three.renderers.shaders（自定义着色器工具） ——
    _registerBinding("three.renderers.shaders.ShaderChunks") {vm => installShaderChunks(vm)}
    _registerBinding("three.renderers.shaders.ShaderVariant") {vm => installShaderVariant(vm)}
    _registerBinding("three.renderers.shaders.UniformsLib") {vm => installUniformsLib(vm)}
    _registerBinding("three.renderers.shaders.SamplerStages") {vm => installSamplerStages(vm)}
    _registerBinding("three.renderers.shaders.ShaderCompiler") {vm => installShaderCompiler(vm)}
    _registerBinding("three.renderers.shaders.ShaderCompileJob") {vm => installShaderCompileJob(vm)}
    // —— three.renderers.common（抽象层枚举 / 位标志 / 值结构 / 句柄） ——
    _registerBinding("three.renderers.common.GfxTextureFormat") {vm => installGfxTextureFormat(vm)}
    _registerBinding("three.renderers.common.GfxUniformType") {vm => installGfxUniformType(vm)}
    _registerBinding("three.renderers.common.GfxAttrib") {vm => installGfxAttrib(vm)}
    _registerBinding("three.renderers.common.GfxAttribType") {vm => installGfxAttribType(vm)}
    _registerBinding("three.renderers.common.GfxViewMode") {vm => installGfxViewMode(vm)}
    _registerBinding("three.renderers.common.GfxBackbufferRatio") {vm => installGfxBackbufferRatio(vm)}
    _registerBinding("three.renderers.common.GfxAccess") {vm => installGfxAccess(vm)}
    _registerBinding("three.renderers.common.GfxRendererType") {vm => installGfxRendererType(vm)}
    _registerBinding("three.renderers.common.GfxTextureFlag") {vm => installGfxTextureFlag(vm)}
    _registerBinding("three.renderers.common.GfxSamplerFlag") {vm => installGfxSamplerFlag(vm)}
    _registerBinding("three.renderers.common.GfxBufferFlag") {vm => installGfxBufferFlag(vm)}
    _registerBinding("three.renderers.common.GfxState") {vm => installGfxState(vm)}
    _registerBinding("three.renderers.common.GfxStencilFlag") {vm => installGfxStencilFlag(vm)}
    _registerBinding("three.renderers.common.GfxClearFlag") {vm => installGfxClearFlag(vm)}
    _registerBinding("three.renderers.common.GfxResetFlag") {vm => installGfxResetFlag(vm)}
    _registerBinding("three.renderers.common.GfxAttributeDesc") {vm => installGfxAttributeDesc(vm)}
    _registerBinding("three.renderers.common.GfxAttachmentDesc") {vm => installGfxAttachmentDesc(vm)}
    _registerBinding("three.renderers.common.GfxUniformDesc") {vm => installGfxUniformDesc(vm)}
    _registerBinding("three.renderers.common.GfxCapsSummary") {vm => installGfxCapsSummary(vm)}
    _registerBinding("three.renderers.common.GfxStatsSummary") {vm => installGfxStatsSummary(vm)}
    _registerBinding("three.renderers.common.GfxTextureHandle") {vm => installGfxTextureHandle(vm)}
    _registerBinding("three.renderers.common.GfxFrameBufferHandle") {vm => installGfxFrameBufferHandle(vm)}
    _registerBinding("three.renderers.common.GfxProgramHandle") {vm => installGfxProgramHandle(vm)}
    _registerBinding("three.renderers.common.GfxUniformHandle") {vm => installGfxUniformHandle(vm)}
    _registerBinding("three.renderers.common.GfxShaderHandle") {vm => installGfxShaderHandle(vm)}
    _registerBinding("three.renderers.common.GfxVertexBufferHandle") {vm => installGfxVertexBufferHandle(vm)}
    _registerBinding("three.renderers.common.GfxIndexBufferHandle") {vm => installGfxIndexBufferHandle(vm)}
    _registerBinding("three.renderers.common.GfxVertexLayoutHandle") {vm => installGfxVertexLayoutHandle(vm)}
    _registerBinding("three.renderers.common.GfxDynamicVertexBufferHandle") {
        vm => installGfxDynamicVertexBufferHandle(vm)
    }
    _registerBinding("three.renderers.common.GfxDynamicIndexBufferHandle") {vm => installGfxDynamicIndexBufferHandle(vm)}
    _registerBinding("three.renderers.common.GfxIndirectBufferHandle") {vm => installGfxIndirectBufferHandle(vm)}
    _registerBinding("three.renderers.common.GfxOcclusionQueryHandle") {vm => installGfxOcclusionQueryHandle(vm)}
    // —— three.renderers._interfaces（抽象层接口实例） ——
    _registerBinding("three.renderers._interfaces.IShaderProgram") {vm => installIShaderProgram(vm)}
    _registerBinding("three.renderers._interfaces.IUniformRegistry") {vm => installIUniformRegistry(vm)}
    // —— three.renderers.xr（XR 会话 / 控制器 / 深度感知） ——
    _registerBinding("three.renderers.xr.XRSessionState") {vm => installXRSessionState(vm)}
    _registerBinding("three.renderers.xr.XRReferenceSpaceType") {vm => installXRReferenceSpaceType(vm)}
    _registerBinding("three.renderers.xr.XRManager") {vm => installXRManager(vm)}
    _registerBinding("three.renderers.xr.XRRenderTarget") {vm => installXRRenderTarget(vm)}
    _registerBinding("three.renderers.xr.XRControllerSpace") {vm => installXRControllerSpace(vm)}
    _registerBinding("three.renderers.xr.XRController") {vm => installXRController(vm)}
    _registerBinding("three.renderers.xr.XRDepthSensing") {vm => installXRDepthSensing(vm)}
    // —— three.renderers.postprocessing（后处理链） ——
    _registerBinding("three.renderers.postprocessing.Pass") {vm => installPass(vm)}
    _registerBinding("three.renderers.postprocessing.EffectComposer") {vm => installEffectComposer(vm)}
    _registerBinding("three.renderers.postprocessing.FullScreenQuad") {vm => installFullScreenQuad(vm)}
    _registerBinding("three.renderers.postprocessing.RenderPass") {vm => installRenderPass(vm)}
    _registerBinding("three.renderers.postprocessing.ShaderPass") {vm => installShaderPass(vm)}
    _registerBinding("three.renderers.postprocessing.MaskPass") {vm => installMaskPass(vm)}
    _registerBinding("three.renderers.postprocessing.ClearMaskPass") {vm => installClearMaskPass(vm)}
    _registerBinding("three.renderers.postprocessing.ClearPass") {vm => installClearPass(vm)}
    _registerBinding("three.renderers.postprocessing.TexturePass") {vm => installTexturePass(vm)}
    _registerBinding("three.renderers.postprocessing.CubeTexturePass") {vm => installCubeTexturePass(vm)}
    _registerBinding("three.renderers.postprocessing.SavePass") {vm => installSavePass(vm)}
    _registerBinding("three.renderers.postprocessing.AfterimagePass") {vm => installAfterimagePass(vm)}
    _registerBinding("three.renderers.postprocessing.BloomPass") {vm => installBloomPass(vm)}
    _registerBinding("three.renderers.postprocessing.BokehPass") {vm => installBokehPass(vm)}
    _registerBinding("three.renderers.postprocessing.DotScreenPass") {vm => installDotScreenPass(vm)}
    _registerBinding("three.renderers.postprocessing.FilmPass") {vm => installFilmPass(vm)}
    _registerBinding("three.renderers.postprocessing.FXAAPass") {vm => installFXAAPass(vm)}
    _registerBinding("three.renderers.postprocessing.GlitchPass") {vm => installGlitchPass(vm)}
    _registerBinding("three.renderers.postprocessing.GTAOPass") {vm => installGTAOPass(vm)}
    _registerBinding("three.renderers.postprocessing.HalftonePass") {vm => installHalftonePass(vm)}
    _registerBinding("three.renderers.postprocessing.LUTPass") {vm => installLUTPass(vm)}
    _registerBinding("three.renderers.postprocessing.OutlinePass") {vm => installOutlinePass(vm)}
    _registerBinding("three.renderers.postprocessing.OutputPass") {vm => installOutputPass(vm)}
    _registerBinding("three.renderers.postprocessing.RenderPixelatedPass") {vm => installRenderPixelatedPass(vm)}
    _registerBinding("three.renderers.postprocessing.RenderTransitionPass") {vm => installRenderTransitionPass(vm)}
    _registerBinding("three.renderers.postprocessing.SAOPass") {vm => installSAOPass(vm)}
    _registerBinding("three.renderers.postprocessing.SMAAPass") {vm => installSMAAPass(vm)}
    _registerBinding("three.renderers.postprocessing.SSAARenderPass") {vm => installSSAARenderPass(vm)}
    _registerBinding("three.renderers.postprocessing.SSAOPass") {vm => installSSAOPass(vm)}
    _registerBinding("three.renderers.postprocessing.SSRPass") {vm => installSSRPass(vm)}
    _registerBinding("three.renderers.postprocessing.TAARenderPass") {vm => installTAARenderPass(vm)}
    _registerBinding("three.renderers.postprocessing.UnrealBloomPass") {vm => installUnrealBloomPass(vm)}
    _registerBinding("three.renderers.postprocessing.VolumeCloudPass") {vm => installVolumeCloudPass(vm)}
    _registerBinding("three.renderers.postprocessing.PostProcessingShaders") {vm => installPostProcessingShaders(vm)}
}

/**
 * @brief[zh-cn] 引擎 Lua 绑定统一工厂（静态工具）
 * @explain[zh-cn] 所有预绑定安装函数的统一入口。详见 installAll / install / installPackage。
 *
 * @brief[en] Unified factory for the engine Lua bindings (static utilities)
 * @explain[en] Single entry point for every pre-registered binding install function.
 * See installAll / install / installPackage.
 */
public class LuaBindingFactory {

    /**
     * @brief[zh-cn] 全量安装所有已登记绑定
     * @param[zh-cn] vm 目标虚拟机
     * @return[zh-cn] 实际新增安装的数量；重复安装/跳过的绑定不计入
     * @note[zh-cn] 可安全重复调用：同名绑定第二次调用会跳过。
     *
     * @brief[en] Installs every registered binding
     * @param[en] vm The target virtual machine
     * @return[en] The number of newly installed bindings; skipped/re-installed ones are not counted
     * @note[en] Safe to call repeatedly: a class registered twice is skipped.
     */
    public static func installAll(vm: LuaVM): Int64 {
        _ensureBindingRegistered()
        var done: Int64 = 0
        for ((name, fn) in _bindingRegistry) {
            done += LuaBindingFactory._installOne(vm, name, fn)
        }
        return done
    }

    /**
     * @brief[zh-cn] 按绑定类名精确安装单个绑定
     * @param[zh-cn] vm        目标虚拟机
     * @param[zh-cn] className 绑定类全名（如 "three.core.math.Vector3"）
     * @return[zh-cn] true = 已安装；false = 未登记该类名
     * @note[zh-cn] 重复安装同名类返回 true（已被跳过，不抛异常）。
     *
     * @brief[en] Installs a single binding by its full class name
     * @param[en] vm        The target virtual machine
     * @param[en] className The full bound class name (e.g. "three.core.math.Vector3")
     * @return[en] true = installed; false = the class name is not registered
     * @note[en] Re-installing the same class returns true (skipped, no exception thrown).
     */
    public static func install(vm: LuaVM, className: String): Bool {
        _ensureBindingRegistered()
        if (_bindingRegistry.contains(className)) {
            let fn = _bindingRegistry.get(className).getOrThrow()
            LuaBindingFactory._installOne(vm, className, fn)
            return true
        }
        return false
    }

    /**
     * @brief[zh-cn] 按包前缀批量安装绑定
     * @param[zh-cn] vm     目标虚拟机
     * @param[zh-cn] prefix 包前缀（如 "three.core.math"；空串 = 全量）
     * @return[zh-cn] 实际新增安装的数量
     *
     * @brief[en] Installs bindings by package prefix
     * @param[en] vm     The target virtual machine
     * @param[en] prefix The package prefix (e.g. "three.core.math"; empty string = all)
     * @return[en] The number of newly installed bindings
     */
    public static func installPackage(vm: LuaVM, prefix: String): Int64 {
        _ensureBindingRegistered()
        var done: Int64 = 0
        for ((name, fn) in _bindingRegistry) {
            if (prefix == "" || name.startsWith(prefix)) {
                done += LuaBindingFactory._installOne(vm, name, fn)
            }
        }
        return done
    }

    /**
     * @brief[zh-cn] 已登记的全部绑定类名（有序不定，用于清单与调试）
     *
     * @brief[en] All registered bound class names (unordered; for docs and debugging)
     */
    public static prop boundClasses: Array<String> {
        get() {
            _ensureBindingRegistered()
            var out = Array<String>(_bindingRegistry.size, {_ => ""})
            var i: Int64 = 0
            for ((name, _) in _bindingRegistry) {
                out[i] = name
                i += 1
            }
            return out
        }
    }

    /**
     * @brief[zh-cn] 已登记绑定数量
     *
     * @brief[en] The number of registered bindings
     */
    public static prop count: Int64 {
        get() {
            _ensureBindingRegistered()
            Int64(_bindingRegistry.size)
        }
    }

    // =========================================================================
    // 内部
    // =========================================================================

    /// 安装单个绑定（捕获"重复定义"异常跳过，其余异常透传）
    private static func _installOne(vm: LuaVM, name: String, fn: (LuaVM) -> Unit): Int64 {
        try {
            fn(vm)
            return 1
        } catch (e: Exception) {
            // 重复安装（defineClass 抛同名异常）视为已存在：跳过且不计入
            if (e.message.contains("duplicate class name")) {
                return 0
            }
            // 其余错误（绑定代码自身 bug）向上抛，便于定位
            throw Exception("LuaBindingFactory.install(${name}): ${e.message}")
        }
    }
}
