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
 * @file[zh-cn] AudioListener 辅助对象
 * @brief[zh-cn] 音频监听器可视化辅助对象
 * @explain[zh-cn]
 * 可视化 AudioListener 在场景中的位置与朝向：
 * - 头部坐标轴（右/上/前）
 * - 前方向箭头（+Z）
 * - 上方向半弧标记
 * 调用 update() 同步监听器的最新世界变换。
 *
 * @note[zh-cn] Three.cj 使用左手坐标系、CCW 点序；本 helper 在左手系内绘制，
 * 前方向与 AudioListener.updateMatrixWorld 同步到 OpenAL 的方向一致（取左手系 +Z）。
 *
 * @file[en] AudioListener Helper
 * @brief[en] Visualization helper object for the audio listener
 * @explain[en]
 * Visualizes the position and orientation of the AudioListener in the scene:
 * - Head axes (right/up/front)
 * - Forward direction arrow (+Z)
 * - Up-direction half-arc marker
 * Call update() to sync the listener's latest world transform.
 *
 * @note[en] Three.cj uses a left-handed coordinate system with CCW winding; this helper
 * draws within the left-handed system. The forward direction matches the direction that
 * AudioListener.updateMatrixWorld syncs to OpenAL (left-handed +Z).
 */
package three.rendering.helpers

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.audio.listener.AudioListener
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 音频监听器辅助对象
 * @explain[zh-cn]
 * 用头部坐标轴 + 前方向箭头 + 上方向标记可视化音频监听器的位姿。
 *
 * @brief[en] Audio listener helper object
 * @explain[en]
 * Visualizes the audio listener's pose with head axes, a forward arrow and an up marker.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Object3D]
public class AudioListenerHelper <: Object3D {
    /// 被可视化的音频监听器
    @JsonIgnore
    public var listener: AudioListener

    /// 头部坐标轴
    @JsonIgnore
    public var axes: AxesHelper

    /// 前方向箭头（+Z）
    @JsonIgnore
    public var forwardArrow: ArrowHelper

    /// 上方向标记弧线
    @JsonIgnore
    public var upArc: LineSegments

    /**
     * @brief[zh-cn] 构造 AudioListener 辅助对象
     * @param[zh-cn] listener 要可视化的 AudioListener
     * size 头部坐标轴尺寸，默认 1.0
     *
     * @brief[en] Constructs an AudioListener helper
     * @param[en] listener The AudioListener to visualize
     * size Head axis size, default 1.0
     */
    public init() {
        this(AudioListener())
    }
    public init(listener: AudioListener, size!: Float64 = 1.0) {
        super()
        this.listener = listener
        this.matrixAutoUpdate = false

        this.axes = AxesHelper(size: size)
        this.children.add(this.axes)

        this.forwardArrow = ArrowHelper(dir: Vector3(0.0, 0.0, 1.0),
                                        origin: Vector3(0.0, 0.0, 0.0),
                                        length: size, color: 0x4444ff)
        this.children.add(this.forwardArrow)

        let arcGeom = BufferGeometry()
        let arcPositions = _buildUpArc(size * 0.3)
        arcGeom.setAttribute("position", BufferAttribute(arcPositions, 3))
        let arcMat = LineBasicMaterial()
        arcMat.color.copy(Color(0x44ff44))
        this.upArc = LineSegments(geometry: arcGeom, material: arcMat)
        this.children.add(this.upArc)

        this.update()
    }

    /**
     * @brief[zh-cn] 同步监听器状态并更新可视化
     *
     * @brief[en] Syncs the listener state and updates the visualization
     */
    public func update(): Unit {
        this.listener.updateWorldMatrix(true, false, false)

        match (this.parent) {
            case Some(p) =>
                p.updateWorldMatrix(true, false, false)
                let inv = Matrix4().copy(p.matrixWorld).invert()
                this.matrix.copy(inv).multiply(this.listener.matrixWorld)
            case None =>
                this.matrix.copy(this.listener.matrixWorld)
        }
        this.matrixWorldNeedsUpdate = true
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Releases GPU resources
     */
    public func dispose(): Unit {
        this.axes.dispose()
        this.forwardArrow.dispose()
        this.upArc.geometry.dispose()
        this.upArc.material.dispose()
    }

    /// 构建上方向半弧（XZ 平面，Y 轴朝上，左手系 CCW）
    private static func _buildUpArc(radius: Float64): Array<Float64> {
        let positions = ArrayList<Float64>()
        let segments: Int64 = 16
        for (i in 0..=segments) {
            let t = Float64(i) / Float64(segments)
            let angle = t * PI
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            if (i > 0) {
                positions.add(x); positions.add(y); positions.add(0.0)
            }
            positions.add(x); positions.add(y); positions.add(0.0)
        }
        // 去掉最后一个重复的起点（Loop 末尾会多一个）
        if (positions.size > 0) {
            positions.remove(positions.size - 1..positions.size)
        }
        return positions.toArray()
    }
}
