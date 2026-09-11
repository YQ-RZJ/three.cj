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
 * @file[zh-cn] Jolt 调试渲染桥接（three.physics.debug 子包）
 * @brief[zh-cn] 把 Jolt DebugRenderer 的绘制指令桥接为线段/三角形缓存，
 * 供上层（如 LineSegments 网格或即时渲染）消费
 * @explain[zh-cn] 实现 JPHDebugRendererProcs 三回调（drawLine/drawTriangle/drawText3D）。
 * CFunc 无捕获，经静态 _activeRenderer 中转到收集器；所有坐标已转换为 three 左手系。
 * 每帧调用 nextFrame() 前先清空缓存；缓存读取建议在物理线程外进行（读时注意同步）。
 *
 * @file[en] Jolt debug-render bridge (three.physics.debug sub-package)
 * @brief[en] Bridges Jolt DebugRenderer draw commands into line/triangle caches for
 * consumption by upper layers (LineSegments meshes or immediate rendering)
 * @explain[en] Implements the three JPHDebugRendererProcs callbacks (drawLine /
 * drawTriangle / drawText3D). CFunc has no capture, so it relays through the static
 * _activeRenderer to the collector; all coordinates are converted to the three
 * left-handed system. Clear the cache before nextFrame() each frame; read the cache
 * outside the physics thread (mind synchronization while reading).
 */
package three.physics.debug

import std.collection.ArrayList
import three.core.math.*
import three.physics.*
import three.physics.interfaces.*
import three.physics.backend.*
import three.physics.world.*
import jolt4cj.jolt.*
import three.utils.log.Logger

// =============================================================================
// PhysicsDebugLine / PhysicsDebugTriangle 调试图元
// =============================================================================

/**
 * @brief[zh-cn] 调试线段（three 左手系）
 *
 * @brief[en] Debug line segment (three left-handed)
 */
public struct PhysicsDebugLine {
    /**
     * @brief[zh-cn] 起点
     *
     * @brief[en] Start point
     */
    public var from: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 终点
     *
     * @brief[en] End point
     */
    public var to: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 颜色（0xRRGGBBAA）
     *
     * @brief[en] Color (0xRRGGBBAA)
     */
    public var color: UInt32 = 0xFFFFFFFF

    public init() {}
}

/**
 * @brief[zh-cn] 调试三角形（three 左手系）
 *
 * @brief[en] Debug triangle (three left-handed)
 */
public struct PhysicsDebugTriangle {
    /**
     * @brief[zh-cn] 顶点 1
     *
     * @brief[en] Vertex 1
     */
    public var v1: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 顶点 2
     *
     * @brief[en] Vertex 2
     */
    public var v2: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 顶点 3
     *
     * @brief[en] Vertex 3
     */
    public var v3: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 颜色（0xRRGGBBAA）
     *
     * @brief[en] Color (0xRRGGBBAA)
     */
    public var color: UInt32 = 0xFFFFFFFF

    public init() {}
}

// =============================================================================
// PhysicsDebugRenderer 调试渲染器
// =============================================================================

/**
 * @brief[zh-cn] Jolt 调试渲染器桥接
 * @explain[zh-cn] 注册 JPHDebugRendererProcs 回调收集绘制指令；beginFrame →
 * drawBodies/drawConstraints → nextFrame 完成一帧采集，之后读取 lines/triangles。
 * 持有期间必须在 PhysicsWorld.stop() 前调用 dispose()。
 *
 * @brief[en] Jolt debug-renderer bridge
 * @explain[en] Registers JPHDebugRendererProcs callbacks to collect draw commands;
 * one capture pass = beginFrame → drawBodies/drawConstraints → nextFrame, then read
 * lines/triangles. Must call dispose() before PhysicsWorld.stop() while alive.
 */
public class PhysicsDebugRenderer {
    /// 活动收集器（CFunc 无捕获，经静态字段中转；仅物理线程内访问）
    internal static var _active: Option<PhysicsDebugRenderer> = None

    private var _renderer: CPointer<Unit> = CPointer<Unit>()
    private var _procs: CPointer<JPHDebugRendererProcs> = CPointer<JPHDebugRendererProcs>()
    private var _disposed: Bool = false

    /// 本帧收集的线段（物理线程内写入）
    internal var lines: ArrayList<PhysicsDebugLine> = ArrayList<PhysicsDebugLine>()
    /// 本帧收集的三角形（物理线程内写入）
    internal var triangles: ArrayList<PhysicsDebugTriangle> = ArrayList<PhysicsDebugTriangle>()

    /**
     * @brief[zh-cn] 构造并注册调试渲染器回调
     *
     * @brief[en] Creates the bridge and registers the debug-renderer callbacks
     */
    public init() {
        let procs = unsafe { LibC.malloc<JPHDebugRendererProcs>() }
        unsafe {
            var p = procs.read()
            p.drawLine = {
                ud: CPointer<Unit>, from: CPointer<JPHVec3>, to: CPointer<JPHVec3>,
                color: UInt32 => PhysicsDebugRenderer._onDrawLine(ud, from, to, color)
            }
            p.drawTriangle = {
                ud: CPointer<Unit>, v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>,
                v3: CPointer<JPHVec3>, color: UInt32, castShadow: UInt32 =>
                PhysicsDebugRenderer._onDrawTriangle(ud, v1, v2, v3, color)
            }
            // 文本绘制无对应图元，忽略
            p.drawText3D = {
                ud: CPointer<Unit>, position: CPointer<JPHVec3>, str: CPointer<UInt8>,
                color: UInt32, height: Float32 => ()
            }
            procs.write(p)
        }
        JPH_DebugRenderer_SetProcs_cj(procs)
        this._procs = procs
        this._renderer = JPH_DebugRenderer_Create_cj(CPointer<Unit>())
        if (this._renderer.isNull()) {
            Logger.error(["PhysicsDebugRenderer", "创建 Jolt DebugRenderer 失败"])
        }
    }

    /**
     * @brief[zh-cn] 渲染器是否有效
     *
     * @brief[en] Whether the renderer is valid
     */
    public prop isValid: Bool {
        get() {
            !this._disposed && !this._renderer.isNull()
        }
    }

    /**
     * @brief[zh-cn] 本帧收集的线段数量
     *
     * @brief[en] Number of line segments collected this frame
     */
    public prop lineCount: Int64 {
        get() {
            this.lines.size
        }
    }

    /**
     * @brief[zh-cn] 采集一帧调试图元：绘制全部刚体形状（线框 + 着色可选）
     * @param[zh-cn] world 物理世界
     * wireframe 是否线框（默认 true）
     *
     * @brief[en] Captures one frame of debug primitives: draws all body shapes
     * (wireframe and/or shaded)
     * @param[en] world The physics world
     * wireframe Wireframe or not (default true)
     */
    public func drawBodies(world: PhysicsWorld, wireframe!: Bool = true): Unit {
        if (!this.isValid) {
            return
        }
        let r = this._renderer
        world.execPhysics({
            =>
            match (world.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (!system.isNull()) {
                        let settings = unsafe { LibC.malloc<JPHDrawSettings>() }
                        unsafe {
                            JPH_DrawSettings_InitDefault_cj(settings)
                            var s = settings.read()
                            s.drawShape = true
                            s.drawShapeWireframe = wireframe
                            settings.write(s)
                        }
                        PhysicsDebugRenderer._active = Some(this)
                        JPH_PhysicsSystem_DrawBodies_cj(system, settings, r, CPointer<Unit>())
                        PhysicsDebugRenderer._active = None
                        unsafe { LibC.free(settings) }
                    }
                case _ => ()
            }
        })
    }

    /**
     * @brief[zh-cn] 采集一帧调试图元：绘制全部约束
     * @param[zh-cn] world 物理世界
     *
     * @brief[en] Captures one frame of debug primitives: draws all constraints
     * @param[en] world The physics world
     */
    public func drawConstraints(world: PhysicsWorld): Unit {
        if (!this.isValid) {
            return
        }
        let r = this._renderer
        world.execPhysics({
            =>
            match (world.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (!system.isNull()) {
                        PhysicsDebugRenderer._active = Some(this)
                        JPH_PhysicsSystem_DrawConstraints_cj(system, r)
                        PhysicsDebugRenderer._active = None
                    }
                case _ => ()
            }
        })
    }

    /**
     * @brief[zh-cn] 结束本帧采集（触发 Jolt NextFrame，清空内部状态）
     *
     * @brief[en] Ends this capture pass (triggers Jolt NextFrame, clears internal state)
     */
    public func nextFrame(): Unit {
        if (!this.isValid) {
            return
        }
        JPH_DebugRenderer_NextFrame_cj(this._renderer)
    }

    /**
     * @brief[zh-cn] 清空已收集的图元缓存
     *
     * @brief[en] Clears the collected primitive cache
     */
    public func clear(): Unit {
        this.lines.clear()
        this.triangles.clear()
    }

    /**
     * @brief[zh-cn] 销毁渲染器（释放回调表与 Jolt 实例）
     *
     * @brief[en] Disposes the renderer (releases the procs table and the Jolt instance)
     */
    public func dispose(): Unit {
        if (this._disposed) {
            return
        }
        this._disposed = true
        if (!this._renderer.isNull()) {
            JPH_DebugRenderer_Destroy_cj(this._renderer)
            this._renderer = CPointer<Unit>()
        }
        if (!this._procs.isNull()) {
            unsafe { LibC.free(this._procs) }
            this._procs = CPointer<JPHDebugRendererProcs>()
        }
    }

    // =========================================================================
    // CFunc 回调分发（无捕获，经静态 _active 中转；坐标系转换见 JoltNative）
    // =========================================================================

    /// Jolt 右手系 → three 左手系（z 取反）
    private static func _lh(v: JPHVec3): Vector3 {
        Vector3(Float64(v.x), Float64(v.y), Float64(-v.z))
    }

    internal static func _onDrawLine(ud: CPointer<Unit>, from: CPointer<JPHVec3>,
        to: CPointer<JPHVec3>, color: UInt32): Unit {
        match (_active) {
            case Some(r) =>
                if (!from.isNull() && !to.isNull()) {
                    let f = unsafe { from.read() }
                    let t = unsafe { to.read() }
                    var line = PhysicsDebugLine()
                    line.from = _lh(f)
                    line.to = _lh(t)
                    line.color = color
                    r.lines.add(line)
                }
            case None => ()
        }
    }

    internal static func _onDrawTriangle(ud: CPointer<Unit>, v1: CPointer<JPHVec3>,
        v2: CPointer<JPHVec3>, v3: CPointer<JPHVec3>, color: UInt32): Unit {
        match (_active) {
            case Some(r) =>
                if (!v1.isNull() && !v2.isNull() && !v3.isNull()) {
                    let a = unsafe { v1.read() }
                    let b = unsafe { v2.read() }
                    let c = unsafe { v3.read() }
                    var tri = PhysicsDebugTriangle()
                    tri.v1 = _lh(a)
                    tri.v2 = _lh(b)
                    tri.v3 = _lh(c)
                    tri.color = color
                    r.triangles.add(tri)
                }
            case None => ()
        }
    }
}
