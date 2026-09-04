/**
 * @file[zh-cn] PositionalAudio 辅助对象
 * @brief[zh-cn] 3D 位置音频可视化辅助对象
 * @explain[zh-cn]
 * 可视化 PositionalAudio 的关键空间属性：
 * - 位置点（小坐标轴/十字）
 * - 方向性锥体（coneInnerAngle / coneOuterAngle）
 * - 参考距离球（refDistance）与最大衰减距离球（maxDistance）
 * - 速度向量（velocity，用于多普勒效应调试）
 * 调用 update() 同步被观察音频源的最新状态。
 *
 * @note[zh-cn] Three.cj 使用左手坐标系、CCW 点序；本 helper 在左手系内绘制，
 * 音频源的朝向对应左手系 +Z 方向（与 PositionalAudio.updateMatrixWorld 同步到 OpenAL 的方向一致）。
 */
package three.rendering.helpers

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.audio.source.PositionalAudio
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 3D 位置音频辅助对象
 * @explain[zh-cn]
 * 用线框锥体表示方向性 coneInnerAngle/coneOuterAngle，
 * 用线框球表示 refDistance/maxDistance，用箭头表示 velocity。
 */
public class PositionalAudioHelper <: Object3D {
    /// 被可视化的 3D 位置音频源
    public var audio: PositionalAudio

    /// 自定义颜色（默认黄色）
    public var color: UInt32

    /// 内锥线框
    public var innerCone: LineSegments

    /// 外锥线框
    public var outerCone: LineSegments

    /// 参考距离球
    public var refSphere: Mesh

    /// 最大距离球
    public var maxSphere: Mesh

    /// 速度箭头
    public var velocityArrow: ArrowHelper

    /**
     * @brief[zh-cn] 构造 PositionalAudio 辅助对象
     * @param[zh-cn] audio 要可视化的 PositionalAudio
     * color 辅助对象颜色，默认 0xffff00
     */
    public init(audio: PositionalAudio, color!: UInt32 = 0xffff00) {
        super()
        this.audio = audio
        this.color = color
        this.kind = "PositionalAudioHelper"
        this.matrixAutoUpdate = false

        let innerGeom = _buildConeGeometry(32)
        let innerMat = LineBasicMaterial()
        innerMat.color.copy(Color(color))
        this.innerCone = LineSegments(geometry: innerGeom, material: innerMat)
        this.children.add(this.innerCone)

        let outerGeom = _buildConeGeometry(32)
        let outerMat = LineBasicMaterial()
        outerMat.color.copy(Color(color))
        outerMat.opacity = 0.6
        outerMat.transparent = true
        this.outerCone = LineSegments(geometry: outerGeom, material: outerMat)
        this.children.add(this.outerCone)

        let refMat = MeshBasicMaterial()
        refMat.color.copy(Color(color))
        refMat.wireframe = true
        refMat.opacity = 0.5
        refMat.transparent = true
        this.refSphere = Mesh(geometry: SphereGeometry(radius: 1.0, widthSegments: 16, heightSegments: 12),
                              material: refMat)
        this.children.add(this.refSphere)

        let maxMat = MeshBasicMaterial()
        maxMat.color.copy(Color(color))
        maxMat.wireframe = true
        maxMat.opacity = 0.25
        maxMat.transparent = true
        this.maxSphere = Mesh(geometry: SphereGeometry(radius: 1.0, widthSegments: 16, heightSegments: 12),
                              material: maxMat)
        this.children.add(this.maxSphere)

        this.velocityArrow = ArrowHelper(dir: Vector3(0.0, 0.0, 1.0),
                                         origin: Vector3(0.0, 0.0, 0.0),
                                         length: 1.0, color: color)
        this.velocityArrow.setLength(0.0, 0.0, 0.0)
        this.children.add(this.velocityArrow)

        this.update()
    }

    /**
     * @brief[zh-cn] 同步音频源状态并更新可视化
     */
    public func update(): Unit {
        this.audio.updateWorldMatrix(true, false, false)

        match (this.parent) {
            case Some(p) =>
                p.updateWorldMatrix(true, false, false)
                let inv = Matrix4().copy(p.matrixWorld).invert()
                this.matrix.copy(inv).multiply(this.audio.matrixWorld)
            case None =>
                this.matrix.copy(this.audio.matrixWorld)
        }
        this.matrixWorldNeedsUpdate = true

        let innerAngle = this.audio.coneInnerAngle * 0.5
        let outerAngle = this.audio.coneOuterAngle * 0.5
        let coneLen = 2.0

        let innerWidth = coneLen * tan(innerAngle * PI / 180.0)
        this.innerCone.scale.set(innerWidth, innerWidth, coneLen)
        this.innerCone.visible = this.audio.coneInnerAngle < 360.0

        let outerWidth = coneLen * tan(outerAngle * PI / 180.0)
        this.outerCone.scale.set(outerWidth, outerWidth, coneLen)
        this.outerCone.visible = this.audio.coneOuterAngle < 360.0

        this.refSphere.scale.set(this.audio.refDistance, this.audio.refDistance, this.audio.refDistance)
        this.refSphere.visible = this.audio.refDistance > 0.0001

        let showMax = this.audio.maxDistance > 0.0001 && this.audio.maxDistance < 100000.0
        this.maxSphere.scale.set(this.audio.maxDistance, this.audio.maxDistance, this.audio.maxDistance)
        this.maxSphere.visible = showMax

        let vel = this.audio.velocity
        let vlen = vel.length()
        if (vlen > 0.0001) {
            let dir = vel.clone().normalize()
            let len = min(vlen, 5.0)
            this.velocityArrow.setDirection(dir)
            this.velocityArrow.setLength(len, len * 0.2, len * 0.04)
            this.velocityArrow.visible = true
        } else {
            this.velocityArrow.visible = false
        }
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     */
    public func dispose(): Unit {
        this.innerCone.geometry.dispose()
        this.innerCone.material.dispose()
        this.outerCone.geometry.dispose()
        this.outerCone.material.dispose()
        this.refSphere.geometry.dispose()
        this.refSphere.material.dispose()
        this.maxSphere.geometry.dispose()
        this.maxSphere.material.dispose()
        this.velocityArrow.dispose()
    }

    /// 构建锥体线框几何（顶点指向 +Z，与 SpotLightHelper 一致）
    private static func _buildConeGeometry(segments: Int64): BufferGeometry {
        let positions = ArrayList<Float64>()

        // 5 条从顶点发出的侧线
        positions.add(0.0); positions.add(0.0); positions.add(0.0)
        positions.add(0.0); positions.add(0.0); positions.add(1.0)
        positions.add(0.0); positions.add(0.0); positions.add(0.0)
        positions.add(1.0); positions.add(0.0); positions.add(1.0)
        positions.add(0.0); positions.add(0.0); positions.add(0.0)
        positions.add(-1.0); positions.add(0.0); positions.add(1.0)
        positions.add(0.0); positions.add(0.0); positions.add(0.0)
        positions.add(0.0); positions.add(1.0); positions.add(1.0)
        positions.add(0.0); positions.add(0.0); positions.add(0.0)
        positions.add(0.0); positions.add(-1.0); positions.add(1.0)

        // 底面圆环
        let l = segments
        for (i in 0..l) {
            let j = i + 1
            let p1 = (Float64(i) / Float64(l)) * PI * 2.0
            let p2 = (Float64(j) / Float64(l)) * PI * 2.0
            positions.add(cos(p1)); positions.add(sin(p1)); positions.add(1.0)
            positions.add(cos(p2)); positions.add(sin(p2)); positions.add(1.0)
        }

        let geometry = BufferGeometry()
        geometry.setAttribute("position", BufferAttribute(positions.toArray(), 3))
        return geometry
    }
}
