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
 * @file[zh-cn] InstancedMesh 实例化网格
 * @brief[zh-cn] 将同一几何/材质渲染 count 次的渲染对象，每次带独立变换矩阵/颜色
 * @explain[zh-cn] 用于森林（树）、草地（草）、粒子群等大量重复几何；远比逐个 Mesh 高效。
 * 各实例的位置/旋转/缩放由 instanceMatrix（每实例 16 个 Float64）控制；
 * instanceColor 可选，控制每实例颜色；morphTexture 控制 morph target 的实例化。
 * 继承 Mesh；raycast 处理每实例独立变换后的几何相交。
 *
 * @file[en] InstancedMesh  Instanced mesh
 * @brief[en] Renders the same geometry/material count times, each with independent transform matrix/color
 * @explain[en] Used for forests (trees), grass, particle swarms and other large-scale repeated geometry; far more efficient than individual Meshes.
 * Each instance's position/rotation/scale is controlled by instanceMatrix (16 Float64 per instance);
 * instanceColor is optional, controlling per-instance color; morphTexture controls morph target instancing.
 * Inherits Mesh; raycast handles per-instance independent transform geometry intersection.
 */
package three.scene.entity

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.rendering.cameras.*
import three.utils.constants.*
import three.rendering.textures.DataTexture
import three.utils.memory.AutoFreePtr
import std.collection.*

/**
 * @brief[zh-cn] 实例化网格，将同一几何/材质渲染多次，每次带独立变换矩阵/颜色
 *
 * @brief[en] Instanced mesh that renders the same geometry/material multiple times with independent transform/color
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Mesh]
public class InstancedMesh <: Mesh {

    /**
     * @brief[zh-cn] 实例变换矩阵缓冲（每实例 16 个 Float64，column-major）
     *
     * @brief[en] Instance transform matrix buffer (16 Float64 per instance, column-major)
     */
    public var instanceMatrix: InstancedBufferAttribute

    // 实例颜色缓冲（可选，None 表示无独立颜色，用材质颜色）。
    @JsonIgnore
    public var instanceColor: Option<InstancedBufferAttribute>

    // morph target 贴图（可选，用于实例化 morph target 的纹理存储）。
    
    @JsonIgnore
    public var morphTexture: Option<DataTexture>

    // 包围盒（可选，computeBoundingBox 后填充）。
    @JsonIgnore
    public var boundingBox: Option<Box3>

    // 包围球（可选，computeBoundingSphere 后填充）。
    @JsonIgnore
    public var boundingSphere: Option<Sphere>

    // 构造一个新的实例化网格。
    // geometry - 顶点/索引几何。
    // material - 材质。
    // count - 实例数量。
    public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material(), count!: Int64 = 0) {
        super(geometry: geometry, material: material)
        this.count = count
        this.instanceMatrix = InstancedBufferAttribute(Array<Float64>(count * 16, { _ => 0.0 }), 16)
        this.instanceColor = None
        this.morphTexture = None
        this.boundingBox = None
        this.boundingSphere = None
        for (i in 0..count) { this.setMatrixAt(i, Matrix4()) }
    }

    // 设置指定实例的变换矩阵。
    // index - 实例索引。
    // matrix - 变换矩阵。
    public func setMatrixAt(index: Int64, matrix: Matrix4): Unit {
        matrix.toArray(this.instanceMatrix.array, offset: index * 16)
    }

    // 取指定实例的变换矩阵到目标矩阵。
    // index - 实例索引。
    // matrix - 接收结果的目标矩阵。
    public func getMatrixAt(index: Int64, matrix: Matrix4): Matrix4 {
        return matrix.fromArray(this.instanceMatrix.array, offset: index * 16)
    }

    // 设置指定实例的颜色。
    // index - 实例索引。
    // color - 颜色。
    public func setColorAt(index: Int64, color: Color): Unit {
        match (this.instanceColor) {
            case Some(ic) => color.toArray(ic.array, offset: index * 3)
            case None =>
                let ic = InstancedBufferAttribute(Array<Float64>(this.instanceMatrix.count * 3, { _ => 1.0 }), 3)
                color.toArray(ic.array, offset: index * 3)
                this.instanceColor = Some(ic)
        }
    }

    // 取指定实例的颜色到目标颜色。
    // index - 实例索引。
    // color - 接收结果的目标颜色。
    public func getColorAt(index: Int64, color: Color): Color {
        match (this.instanceColor) {
            case Some(ic) => return color.fromArray(ic.array, offset: index * 3)
            case None => return color.set(1.0, 1.0, 1.0)
        }
    }

    // 计算包围盒。与 JS side 一致：遍历所有实例变换矩阵，取每实例 translation（elements[12..14]）
    // expand 到 boundingBox；几何本身包围盒由 Mesh.computeBoundingBox 处理（此处仅实例位置）。
    public func computeBoundingBox(): Unit {
        match (this.boundingBox) {
            case Some(box) => box.makeEmpty()
            case None => this.boundingBox = Some(Box3())
        }
        match (this.boundingBox) {
            case Some(box) =>
                for (i in 0..this.count) {
                    let m = Matrix4()
                    this.getMatrixAt(i, m)
                    box.expandByPoint(Vector3(m.elements[12], m.elements[13], m.elements[14]))
                }
            case None => ()
        }
    }

    // 计算包围球。与 JS side 一致：先 computeBoundingBox，再用 box.getBoundingSphere 填充。
    public func computeBoundingSphere(): Unit {
        match (this.boundingSphere) {
            case Some(sphere) => sphere.makeEmpty()
            case None => this.boundingSphere = Some(Sphere())
        }
        this.computeBoundingBox()
        // 仓颉 match 不支持元组双值块，故用嵌套 match 替代 JS side 的 (box, sphere) 双 match。
        match (this.boundingBox) {
            case Some(box) =>
                match (this.boundingSphere) {
                    case Some(sphere) => box.getBoundingSphere(sphere)
                    case None => ()
                }
            case None => ()
        }
    }

    // 设置指定实例的 morph target 形态。与 JS side 一致：将 morph influences 数组写入 morphTexture。
    
    //           morphBaseInfluence = morphTargetsRelative ? 1 : 1 - morphInfluencesSum，写入 dataIndex 起首位，
    //           其后接 objectInfluences 全量。
    // 仓颉侧 DataTexture 接受 Array<UInt8>，故将 Float64 视图转 IEEE754 字节（同 Skeleton.computeBoneTexture 模式）。
    // index - 实例索引。
    // influences - morph target 影响系数数组（即 JS 的 object.morphTargetInfluences）。
    public func setMorphAt(index: Int64, influences: Array<Float64>): Unit {
        let objectInfluences = influences
        let len = Int64(objectInfluences.size) + 1 // morphBaseInfluence + all influences

        
        match (this.morphTexture) {
            case None =>
                // 首次惰性创建：len * count 像素，每像素 1 float（RedFormat 单通道 + FloatType）
                // 仓颉侧 DataTexture(data: Array<UInt8>, width, height, format, type)
                let totalFloats = len * this.count
                let bytes = Array<UInt8>(totalFloats * 4, { _ => 0u8 })
                this.morphTexture = Some(DataTexture(bytes, len, this.count, format: RedFormat, `type`: FloatType))
            case Some(_) => ()
        }

        
        var morphInfluencesSum = 0.0
        for (i in 0..objectInfluences.size) {
            morphInfluencesSum += objectInfluences[i]
        }
        let morphBaseInfluence = if (this.geometry.morphTargetsRelative) { 1.0 } else { 1.0 - morphInfluencesSum }

        
        // 仓颉侧 morphTexture.source.data 是 Array<UInt8>，按 IEEE754 little-endian 逐 float 写 4 字节
        match (this.morphTexture) {
            case Some(tex) =>
                let data = tex.source.data
                let dataIndex = len * index
                // 写 morphBaseInfluence 到 dataIndex 位
                let baseBytes = float64ToFloat32Bytes(morphBaseInfluence)
                let baseOffset = dataIndex * 4
                for (k in 0..4) { data[baseOffset + k] = baseBytes[k] }
                // 写 objectInfluences 到 dataIndex + 1 起续位
                for (i in 0..objectInfluences.size) {
                    let infBytes = float64ToFloat32Bytes(objectInfluences[i])
                    let infOffset = (dataIndex + 1 + Int64(i)) * 4
                    for (k in 0..4) { data[infOffset + k] = infBytes[k] }
                }
                tex.source.needsUpdate = true
            case None => ()
        }
    }

    // 取指定实例的 morph target 形态到目标数组。与 JS side 一致：从 morphTexture 读回 influences。
    
    // 仓颉侧 morphTexture.source.data 是 IEEE754 字节视图，逐 4 字节 reinterpret 回 Float32→Float64。
    // index - 实例索引。
    // influences - 接收结果的目标数组（长度需 ≥ objectInfluences.length，本实现按目标数组长度读回）。
    public func getMorphAt(index: Int64, influences: Array<Float64>): Array<Float64> {
        match (this.morphTexture) {
            case Some(tex) =>
                let data = tex.source.data
                let len = Int64(influences.size) + 1
                let dataIndex = len * index + 1 // Skip the baseInfluenceSum at the beginning
                for (i in 0..influences.size) {
                    // 4 字节 IEEE754 little-endian → Float32 → Float64
                    let offset = (dataIndex + Int64(i)) * 4
                    let bits = UInt32(data[offset]) | (UInt32(data[offset + 1]) << 8) | (UInt32(data[offset + 2]) << 16) | (UInt32(data[offset + 3]) << 24)
                    influences[i] = float32BitsToFloat64(bits)
                }
            case None => ()
        }
        return influences
    }

    // 更新 morph target 字典与影响系数。与 Mesh.updateMorphTargets 一致，
    // 但 morph target 数据存储在 morphTexture 中（每实例独立）。
    
    public override func updateMorphTargets(): Unit {
        // 与 JS side 一致：空实现。morphTexture 在 setMorphAt 首次调用时惰性创建，无需此处预建。
    }

    // 射线相交检测。与 JS side 一致：逐实例应用其变换矩阵后与 Mesh.raycast 类似处理。
    
    // raycaster - 射线发射器。
    // intersects - 命中结果累加数组。
    public override func raycast(raycaster: Raycaster, intersects: ArrayList<Intersection>): Unit {
        let matrixWorld = this.matrixWorld
        let raycastTimes = this.count

        
        // 仓颉侧实例化临时 Mesh 复用 Mesh.raycast（避免重复实现 triangle intersect）
        let mesh = Mesh(geometry: this.geometry, material: this.material)
        mesh.geometry = this.geometry
        mesh.material = this.material
        

        // test with bounding sphere first
        
        match (this.boundingSphere) {
            case None => this.computeBoundingSphere()
            case Some(_) => ()
        }
        let sphere = Sphere()
        match (this.boundingSphere) {
            case Some(bs) =>
                sphere.copy(bs)
                sphere.applyMatrix4(matrixWorld)
                if (raycaster.ray.intersectsSphere(sphere) == false) { return }
            case None => return
        }

        // now test each instance
        let instanceLocalMatrix = Matrix4()
        let instanceWorldMatrix = Matrix4()
        let instanceIntersects = ArrayList<Intersection>()
        for (instanceId in 0..raycastTimes) {
            // calculate the world matrix for each instance
            this.getMatrixAt(instanceId, instanceLocalMatrix)
            instanceWorldMatrix.multiplyMatrices(matrixWorld, instanceLocalMatrix)
            // the mesh represents this single instance
            mesh.matrixWorld = instanceWorldMatrix
            instanceIntersects.clear()
            mesh.raycast(raycaster, instanceIntersects)
            // process the result of raycast
            for (i in 0..instanceIntersects.size) {
                let intersect = instanceIntersects[i]
                intersect.instanceId = instanceId
                intersect.obj = Some(this)
                intersects.add(intersect)
            }
        }
    }

    // 将给定实例化网格实例的值复制到本实例。
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: InstancedMesh =>
                this.instanceMatrix.copy(s.instanceMatrix)
                this.instanceColor = s.instanceColor
                this.count = s.count
            case _ => ()
        }
        return this
    }

    // 返回一个与本实例值相同的新实例化网格实例。
    public override func clone(): Object3D {
        let obj = InstancedMesh()
        return obj.copy(this, true)
    }

    // 释放本实例分配的 GPU 相关资源。
    public func dispose(): Unit {
        this.dispatchEvent(Event("dispose"))
        this.morphTexture = None
    }
}

// Float64 → Float32 IEEE754 little-endian 4 字节视图（同 Skeleton.computeBoneTexture 模式）。
// 用 LibC.malloc<Float32> 写入后以 CPointer<UInt32> reinterpret 读回位模式，再拆 4 字节。
private func float64ToFloat32Bytes(val: Float64): Array<UInt8> {
    let f = Float32(val)
    let bits = unsafe {
        let holder = AutoFreePtr<Float32>(LibC.malloc<Float32>())
        holder.get().write(f)
        let result = CPointer<UInt32>(holder.get()).read()
        holder.dispose()
        result
    }
    return Array<UInt8>(4, { k =>
        UInt8((bits >> (UInt32(k) * 8u32)) & 0xFFu32)
    })
}

// UInt32 IEEE754 位模式 → Float32 → Float64（反向 reinterpret）。
private func float32BitsToFloat64(bits: UInt32): Float64 {
    let f32 = unsafe {
        let holder = AutoFreePtr<UInt32>(LibC.malloc<UInt32>())
        holder.get().write(bits)
        let result = CPointer<Float32>(holder.get()).read()
        holder.dispose()
        result
    }
    return Float64(f32)
}
