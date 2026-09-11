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
 * @file[zh-cn] 缓冲几何体
 * @brief[zh-cn] 三维几何体的基础类，存储顶点属性与索引
 * @explain[zh-cn] 
 * BufferGeometry 是 Three.js 中最核心的几何体类，存储顶点属性（position、normal、uv、color 等）与索引。
 * 在 bgfx 渲染后端中，缓冲几何体对应 bgfx 的顶点缓冲区与索引缓冲区。
 * 关键概念：
 * - attributes: 命名顶点属性的字典，每个属性是 BufferAttribute
 * - index: 可选的索引 BufferAttribute，启用顶点复用
 * - groups: 将几何体分为多个绘制组，每组用不同材质
 * - drawRange: 限制实际渲染的顶点/索引范围
 * - boundingBox/boundingSphere: 可计算的包围盒/球，用于视锥剔除、拾取等
 *
 * @file[en] Buffer Geometry
 * @brief[en] Base class for 3D geometry, storing vertex attributes and indices
 * @explain[en] 
 * BufferGeometry is the most core geometry class in Three.js, storing vertex attributes (position, normal, uv, color, etc.) and indices.
 * In the bgfx rendering backend, buffer geometry corresponds to bgfx's vertex buffer and index buffer.
 * Key concepts:
 * - attributes: Named vertex attribute dictionary, each attribute is a BufferAttribute
 * - index: Optional index BufferAttribute, enabling vertex reuse
 * - groups: Divides geometry into multiple draw groups, each using different materials
 * - drawRange: Limits the actual rendered vertex/index range
 * - boundingBox/boundingSphere: Computable bounding box/sphere, used for frustum culling, picking, etc.
 */
package three.rendering.geometry

import three.core.math.*
import three.rendering.buffer.*
import three.rendering.interfaces.*
import three.core.interfaces.*
import three.utils.log.Logger
import three.core.interfaces.ILoadResult
import std.math.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 缓冲几何体类，存储三维几何体的顶点数据
 * @explain[zh-cn] 
 * 使用示例：
 * ```
 * let geom = BufferGeometry()
 * let positions = BufferAttribute([
 * -1.0, -1.0, 0.0,
 * 1.0, -1.0, 0.0,
 * 0.0,  1.0, 0.0
 * ], 3)
 * geom.setAttribute("position", positions)
 * geom.computeVertexNormals()
 * geom.computeBoundingSphere()
 * ```
 *
 * @brief[en] Buffer geometry class, storing vertex data of 3D geometry
 * @explain[en] 
 * Usage example:
 * ```
 * let geom = BufferGeometry()
 * let positions = BufferAttribute([
 * -1.0, -1.0, 0.0,
 * 1.0, -1.0, 0.0,
 * 0.0,  1.0, 0.0
 * ], 3)
 * geom.setAttribute("position", positions)
 * geom.computeVertexNormals()
 * geom.computeBoundingSphere()
 * ```
 */
/**
 * @brief[zh-cn] 绘制组结构，定义几何体的绘制分组
 * @explain[zh-cn] 
 *
 * @brief[en] Draw group structure, defining geometry draw groups
 * @explain[en] 
 */
public class BufferGeometryGroup {
    /**
     * @brief[zh-cn] 此绘制调用中的第一个元素（非索引几何体为第一个顶点，否则为第一个三角形索引）
     *
     * @brief[en] First element in this draw call (first vertex for non-indexed geometry, first triangle index otherwise)
     */
    public var start: Int64

    /**
     * @brief[zh-cn] 此组包含多少顶点（或索引）
     *
     * @brief[en] How many vertices (or indices) this group contains
     */
    public var count: Int64

    /**
     * @brief[zh-cn] 使用的材质数组索引，默认 0
     *
     * @brief[en] Material array index to use, default 0
     */
    public var materialIndex: Int64

    /**
     * @brief[zh-cn] 构造绘制组
     * @param[zh-cn] start 起始位置
     * count 元素数量
     * materialIndex 材质索引，默认为 0
     *
     * @brief[en] Constructs a draw group
     * @param[en] start Start position
     * count Element count
     * materialIndex Material index, default 0
     */
    public init(start: Int64, count: Int64, materialIndex!: Int64 = 0) {
        this.start = start
        this.count = count
        this.materialIndex = materialIndex
    }
}

/**
 * @brief[zh-cn] 缓冲几何体类：描述几何体数据（顶点/法线/UV 等属性）
 *
 * @brief[en] Buffer geometry class: describes geometry data (vertex/normal/UV attributes)
 */
@JsonAdapter
public open class BufferGeometry <: ILoadResult & IGeometryProvider {
    /**
     * @brief[zh-cn] 几何体类型字符串
     *
     * @brief[en] Geometry type string
     */
    public var kind: String

    /**
     * @brief[zh-cn] 几何体的 UUID
     *
     * @brief[en] UUID of the geometry
     */
    public var uuid: String

    /**
     * @brief[zh-cn] 几何体名称
     *
     * @brief[en] Geometry name
     */
    public var name: String

    /**
     * @brief[zh-cn] 索引缓冲区属性，启用顶点复用；若未设置，渲染器假设每三个连续顶点构成一个三角形
     *
     * @brief[en] Index buffer attribute enabling vertex reuse; if not set, renderer assumes every three consecutive vertices form a triangle
     */
    public var index: ?BufferAttribute

    /**
     * @brief[zh-cn] 间接绘制属性（仅 WebGPU 后端支持）
     *
     * @brief[en] Indirect draw attribute (WebGPU backend only)
     */
    public var indirect: ?BufferAttribute

    /**
     * @brief[zh-cn] 间接绘制缓冲中的偏移量（字节）
     *
     * @brief[en] Offset in the indirect draw buffer (bytes)
     */
    public var indirectOffset: Int64

    /**
     * @brief[zh-cn] 命名顶点属性字典，通过 setAttribute/getAttribute 访问
     *
     * @brief[en] Named vertex attribute dictionary, accessed via setAttribute/getAttribute
     */
    public var attributes: HashMap<String, BufferAttribute>

    /**
     * @brief[zh-cn] 形变目标属性字典；一旦几何体被渲染，形变属性数据不可更改，需要 dispose() 并重建
     *
     * @brief[en] Morph target attribute dictionary; once rendered, morph attribute data cannot be changed, need dispose() and rebuild
     */
    public var morphAttributes: HashMap<String, ArrayList<BufferAttribute>>

    /**
     * @brief[zh-cn] 控制形变目标行为：true 为相对偏移，false 为绝对位置/法线
     *
     * @brief[en] Controls morph target behavior: true for relative offsets, false for absolute positions/normals
     */
    public var morphTargetsRelative: Bool

    /**
     * @brief[zh-cn] 将几何体分为多个绘制组，每组使用不同材质，通过 addGroup/clearGroups 编辑
     *
     * @brief[en] Divides geometry into multiple draw groups, each using different materials, edited via addGroup/clearGroups
     */
    @JsonIgnore
    public var groups: ArrayList<BufferGeometryGroup>

    /**
     * @brief[zh-cn] 包围盒，可通过 computeBoundingBox() 计算
     *
     * @brief[en] Bounding box, can be computed via computeBoundingBox()
     */
    public var boundingBox: ?Box3

    /**
     * @brief[zh-cn] 包围球，可通过 computeBoundingSphere() 计算
     *
     * @brief[en] Bounding sphere, can be computed via computeBoundingSphere()
     */
    public var boundingSphere: ?Sphere

    /**
     * @brief[zh-cn] 确定要渲染的几何体部分，使用 setDrawRange() 设置
     *
     * @brief[en] Determines the part of geometry to render, set via setDrawRange()
     */
    @JsonIgnore
    public var drawRange: (Int64, Int64)

    /**
     * @brief[zh-cn] 自定义数据存储对象，不应保存函数引用
     *
     * @brief[en] Custom data storage object, should not contain function references
     */
    // 序列化忽略：userData 为运行时自定义数据（JsonValue 容器，fastjson 宏不支持）。
    public var userData: HashMap<String, Any>

    /**
     * @brief[zh-cn] 自构造以来几何体是否已被变换（如通过 applyMatrix4）
     *
     * @brief[en] Whether the geometry has been transformed since construction (e.g. via applyMatrix4)
     */
    @JsonIgnore
    private var _transformed: Bool

    /**
     * @brief[zh-cn] 构造新的缓冲几何体
     *
     * @brief[en] Constructs a new buffer geometry
     */
    public init() {
        this.kind = "BufferGeometry"
        this.uuid = MathUtils.generateUUID()
        this.name = ""
        this.index = None
        this.indirect = None
        this.indirectOffset = 0
        this.attributes = HashMap<String, BufferAttribute>()
        this.morphAttributes = HashMap<String, ArrayList<BufferAttribute>>()
        this.morphTargetsRelative = false
        this.groups = ArrayList<BufferGeometryGroup>()
        this.boundingBox = None
        this.boundingSphere = None
        this.drawRange = (0, Int64.Max)
        this.userData = HashMap<String, Any>()
        this._transformed = false
    }

    /**
     * @brief[zh-cn] 返回此几何体的索引
     * @return[zh-cn] 索引缓冲区属性；若未定义索引则返回 None
     *
     * @brief[en] Returns the index of this geometry
     * @return[en] Index buffer attribute; returns None if index is not defined
     */
    public func getIndex(): ?BufferAttribute {
        return this.index
    }

    /**
     * @brief[zh-cn] 设置此几何体的索引
     * @param[zh-cn] index 索引缓冲区属性
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Sets the index of this geometry
     * @param[en] index Index buffer attribute
     * @return[en] Reference to this instance
     */
    public func setIndex(index: BufferAttribute): BufferGeometry {
        this.index = Some(index)
        return this
    }

    /**
     * @brief[zh-cn] 设置此几何体的间接绘制属性
     * @param[zh-cn] indirect 持有间接绘制调用的属性
     * indirectOffset 间接绘制缓冲中的偏移量（字节）
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Sets the indirect draw attribute of this geometry
     * @param[en] indirect Attribute holding indirect draw calls
     * indirectOffset Offset in the indirect draw buffer (bytes)
     * @return[en] Reference to this instance
     */
    public func setIndirect(indirect: BufferAttribute, indirectOffset!: Int64 = 0): BufferGeometry {
        this.indirect = Some(indirect)
        this.indirectOffset = indirectOffset
        return this
    }

    /**
     * @brief[zh-cn] 返回此几何体的间接绘制属性
     * @return[zh-cn] 间接绘制属性；若未定义则返回 None
     *
     * @brief[en] Returns the indirect draw attribute of this geometry
     * @return[en] Indirect draw attribute; returns None if not defined
     */
    public func getIndirect(): ?BufferAttribute {
        return this.indirect
    }

    /**
     * @brief[zh-cn] 返回指定名称的属性
     * @param[zh-cn] name 属性名
     * @return[zh-cn] 对应的缓冲区属性；若不存在返回 None
     *
     * @brief[en] Returns the attribute with the given name
     * @param[en] name Attribute name
     * @return[en] Corresponding buffer attribute; returns None if not found
     */
    public func getAttribute(name: String): ?BufferAttribute {
        return this.attributes.get(name)
    }

    // ===== IGeometryProvider 接口实现 =====

    /**
     * @brief[zh-cn] 获取包围球（接口实现，返回当前 boundingSphere）
     *
     * @brief[en] Gets the bounding sphere (interface implementation, returns current boundingSphere)
     */
    public func getBoundingSphere(): Option<Sphere> {
        return this.boundingSphere
    }

    /**
     * @brief[zh-cn] 获取包围盒（接口实现，返回当前 boundingBox）
     *
     * @brief[en] Gets the bounding box (interface implementation, returns current boundingBox)
     */
    public func getBoundingBox(): Option<Box3> {
        return this.boundingBox
    }

    /**
     * @brief[zh-cn] 按名称获取顶点属性（接口实现，转为 AttributeReader 只读视图）
     *
     * @brief[en] Gets vertex attribute by name (interface implementation, converts to AttributeReader read-only view)
     */
    public func getAttributeReader(name: String): Option<AttributeReader> {
        match (this.getAttribute(name)) {
            case Some(attr) => return Some(attr)
            case None => return None
        }
    }

    /**
     * @brief[zh-cn] 为指定名称设置给定属性
     * @param[zh-cn] name 属性名
     * attribute 要设置的属性
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Sets the given attribute for the specified name
     * @param[en] name Attribute name
     * attribute Attribute to set
     * @return[en] Reference to this instance
     */
    public func setAttribute(name: String, attribute: BufferAttribute): BufferGeometry {
        this.attributes.add(name, attribute)
        return this
    }

    /**
     * @brief[zh-cn] 删除指定名称的属性
     * @param[zh-cn] name 属性名
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Deletes the attribute with the specified name
     * @param[en] name Attribute name
     * @return[en] Reference to this instance
     */
    public func deleteAttribute(name: String): BufferGeometry {
        this.attributes.remove(name)
        return this
    }

    /**
     * @brief[zh-cn] 返回此几何体是否具有指定名称的属性
     * @param[zh-cn] name 属性名
     * @return[zh-cn] 是否存在该属性
     *
     * @brief[en] Returns whether this geometry has an attribute with the specified name
     * @param[en] name Attribute name
     * @return[en] Whether the attribute exists
     */
    public func hasAttribute(name: String): Bool {
        return this.attributes.contains(name)
    }

    /**
     * @brief[zh-cn] 向此几何体添加绘制组
     * @param[zh-cn] start 此绘制调用中的第一个元素
     * count 此组包含多少顶点（或索引）
     * materialIndex 使用的材质数组索引，默认为 0
     *
     * @brief[en] Adds a draw group to this geometry
     * @param[en] start First element in this draw call
     * count How many vertices (or indices) this group contains
     * materialIndex Material array index to use, default 0
     */
    public func addGroup(start: Int64, count: Int64, materialIndex!: Int64 = 0): Unit {
        this.groups.add(BufferGeometryGroup(start, count, materialIndex: materialIndex))
    }

    /**
     * @brief[zh-cn] 清除所有绘制组
     *
     * @brief[en] Clears all draw groups
     */
    public func clearGroups(): Unit {
        this.groups.clear()
    }

    /**
     * @brief[zh-cn] 设置此几何体的绘制范围
     * @param[zh-cn] start 非索引几何体的第一个顶点，否则为第一个三角形索引
     * count 非索引几何体要渲染的顶点数，或索引几何体要渲染的索引数
     *
     * @brief[en] Sets the draw range of this geometry
     * @param[en] start First vertex for non-indexed geometry, or first triangle index otherwise
     * count Number of vertices to render for non-indexed geometry, or indices for indexed geometry
     */
    public func setDrawRange(start: Int64, count: Int64): Unit {
        this.drawRange = (start, count)
    }

    /**
     * @brief[zh-cn] 将给定的 4x4 变换矩阵应用到几何体
     * @param[zh-cn] matrix 要应用的 4x4 矩阵
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Applies the given 4x4 transformation matrix to the geometry
     * @param[en] matrix 4x4 matrix to apply
     * @return[en] Reference to this instance
     */
    public func applyMatrix4(matrix: Matrix4): BufferGeometry {
        let positionOpt = this.attributes.get("position")
        if (let Some(position) <- positionOpt) {
            position.applyMatrix4(matrix)
            position.markNeedsUpdate()
        }
        let normalOpt = this.attributes.get("normal")
        if (let Some(normal) <- normalOpt) {
            let normalMatrix = Matrix3().getNormalMatrix(matrix)
            normal.applyNormalMatrix(normalMatrix)
            normal.markNeedsUpdate()
        }
        let tangentOpt = this.attributes.get("tangent")
        if (let Some(tangent) <- tangentOpt) {
            tangent.transformDirection(matrix)
            tangent.markNeedsUpdate()
        }
        if (this.boundingBox.isSome()) {
            this.computeBoundingBox()
        }
        if (this.boundingSphere.isSome()) {
            this.computeBoundingSphere()
        }
        this._transformed = true
        return this
    }

    /**
     * @brief[zh-cn] 将给定的四元数表示的旋转应用到几何体
     * @param[zh-cn] q 要应用的四元数
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Applies the rotation represented by the given quaternion to the geometry
     * @param[en] q Quaternion to apply
     * @return[en] Reference to this instance
     */
    public func applyQuaternion(q: Quaternion): BufferGeometry {
        let m1 = Matrix4().makeRotationFromQuaternion(q)
        this.applyMatrix4(m1)
        return this
    }

    /**
     * @brief[zh-cn] 绕世界 X 轴旋转几何体
     * @param[zh-cn] angle 旋转角度（弧度）
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Rotates the geometry around the world X-axis
     * @param[en] angle Rotation angle (radians)
     * @return[en] Reference to this instance
     */
    public func rotateX(angle: Float64): BufferGeometry {
        // 绕世界 x 轴旋转几何体
        let m1 = Matrix4().makeRotationX(angle)
        this.applyMatrix4(m1)
        return this
    }

    /**
     * @brief[zh-cn] 绕世界 Y 轴旋转几何体
     * @param[zh-cn] angle 旋转角度（弧度）
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Rotates the geometry around the world Y-axis
     * @param[en] angle Rotation angle (radians)
     * @return[en] Reference to this instance
     */
    public func rotateY(angle: Float64): BufferGeometry {
        // 绕世界 y 轴旋转几何体
        let m1 = Matrix4().makeRotationY(angle)
        this.applyMatrix4(m1)
        return this
    }

    /**
     * @brief[zh-cn] 绕世界 Z 轴旋转几何体
     * @param[zh-cn] angle 旋转角度（弧度）
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Rotates the geometry around the world Z-axis
     * @param[en] angle Rotation angle (radians)
     * @return[en] Reference to this instance
     */
    public func rotateZ(angle: Float64): BufferGeometry {
        // 绕世界 z 轴旋转几何体
        let m1 = Matrix4().makeRotationZ(angle)
        this.applyMatrix4(m1)
        return this
    }

    /**
     * @brief[zh-cn] 平移几何体
     * @param[zh-cn] x x 方向偏移
     * y y 方向偏移
     * z z 方向偏移
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Translates the geometry
     * @param[en] x Offset in x direction
     * y Offset in y direction
     * z Offset in z direction
     * @return[en] Reference to this instance
     */
    public func translate(x: Float64, y: Float64, z: Float64): BufferGeometry {
        // 平移几何体
        let m1 = Matrix4().makeTranslation(x, y, z)
        this.applyMatrix4(m1)
        return this
    }

    /**
     * @brief[zh-cn] 缩放几何体
     * @param[zh-cn] x x 方向缩放
     * y y 方向缩放
     * z z 方向缩放
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Scales the geometry
     * @param[en] x Scale in x direction
     * y Scale in y direction
     * z Scale in z direction
     * @return[en] Reference to this instance
     */
    public func scale(x: Float64, y: Float64, z: Float64): BufferGeometry {
        // 缩放几何体
        let m1 = Matrix4().makeScale(x, y, z)
        this.applyMatrix4(m1)
        return this
    }

    /**
     * @brief[zh-cn] 旋转几何体使其面向 3D 空间中的某点
     * @param[zh-cn] vector 目标点
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Rotates the geometry to face a point in 3D space
     * @param[en] vector Target point
     * @return[en] Reference to this instance
     */
    public func lookAt(vector: Vector3): BufferGeometry {
        // 纯矩阵运算版（避免依赖 three.scene.objects.Object3D，消除包级循环依赖）：
        // 对照 Object3D.lookAt 的非相机分支：构造"从原点看向目标"的朝向矩阵，
        // 经四元数共轭修正后 compose 得到完整矩阵再应用。
        let pos = Vector3(0.0, 0.0, 0.0)
        let m = Matrix4()
        m.lookAt(pos, vector, Vector3(0.0, 1.0, 0.0))
        let q = Quaternion().setFromRotationMatrix(m)
        // Matrix4.lookAt 存储的旋转部分是 [x,y,z]^T（列主序下 x 轴 = (x.x, y.x, z.x)）。
        // setFromRotationMatrix 按列主序读取后得到的四元数对应转置后的旋转，
        // 共轭（negate xyz）后得到正确的世界朝向（与 Object3D.lookAt 一致）。
        q.x = -q.x
        q.y = -q.y
        q.z = -q.z
        let matrix = Matrix4().compose(pos, q, Vector3(1.0, 1.0, 1.0))
        this.applyMatrix4(matrix)
        return this
    }

    /**
     * @brief[zh-cn] 基于包围盒将几何体居中
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Centers the geometry based on its bounding box
     * @return[en] Reference to this instance
     */
    public func center(): BufferGeometry {
        this.computeBoundingBox()
        if (let Some(box) <- this.boundingBox) {
            let offset = box.getCenter().negate()
            this.translate(offset.x, offset.y, offset.z)
        }
        return this
    }

    /**
     * @brief[zh-cn] 通过给定点的数组定义几何体（创建 position 属性）
     * @explain[zh-cn] 
     * 数组可以持有 2D 或 3D 向量。使用 2D 数据时，所有顶点的 z 坐标设为 0。
     * 若用于已有 position 属性的几何体，顶点数据会被覆盖。数组长度必须匹配顶点数。
     * @param[zh-cn] points 点数组
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Defines geometry from an array of points (creates position attribute)
     * @explain[en] 
     * The array can hold 2D or 3D vectors. When using 2D data, all vertex z coordinates are set to 0.
     * If used on a geometry with an existing position attribute, vertex data will be overwritten. Array length must match vertex count.
     * @param[en] points Array of points
     * @return[en] Reference to this instance
     */
    public func setFromPoints(points: Array<Vector3>): BufferGeometry {
        let positionOpt = this.attributes.get("position")
        if (positionOpt.isNone()) {
            let position = ArrayList<Float64>()
            for (i in 0..points.size) {
                let point = points[i]
                position.add(point.x)
                position.add(point.y)
                position.add(point.z)
            }
            let arr = Array<Float64>(position.size, { i => position[i] })
            this.setAttribute("position", BufferAttribute(arr, 3, normalized: false))
        } else {
            if (let Some(positionAttribute) <- positionOpt) {
                let l = min(points.size, positionAttribute.count)
                for (i in 0..l) {
                    let point = points[i]
                    positionAttribute.setXYZ(i, point.x, point.y, point.z)
                }
                if (points.size > positionAttribute.count) {
                    Logger.warn(["BufferGeometry", "Buffer size too small for points data. Use .dispose() and create a new geometry."])
                }
                positionAttribute.markNeedsUpdate()
            }
        }
        return this
    }

    /**
     * @brief[zh-cn] 计算几何体的包围盒并更新 boundingBox 成员
     * @explain[zh-cn] 
     * 引擎不会自动计算包围盒；必须由应用主动调用。
     * 若几何体顶点被修改，可能需要重新计算包围盒。
     *
     * @brief[en] Computes the bounding box and updates the boundingBox member
     * @explain[en] 
     * The engine does not automatically compute the bounding box; it must be called explicitly by the application.
     * If geometry vertices are modified, the bounding box may need to be recomputed.
     */
    public func computeBoundingBox(): Unit {
        if (this.boundingBox.isNone()) {
            this.boundingBox = Some(Box3())
        }
        let positionOpt = this.attributes.get("position")
        let morphAttributesPositionOpt = this.morphAttributes.get("position")
        if (let Some(position) <- positionOpt) {
            if (let Some(box) <- this.boundingBox) {
                // 从 BufferAttribute 计算包围盒
                let v = Vector3()
                box.makeEmpty()
                for (i in 0..position.count) {
                    v.set(position.getX(i), position.getY(i), position.getZ(i))
                    box.expandByPoint(v)
                }
                // 处理形变属性（如果存在）
                if (let Some(morphAttributesPosition) <- morphAttributesPositionOpt) {
                    let tmpBox = Box3()
                    for (i in 0..morphAttributesPosition.size) {
                        let morphAttribute = morphAttributesPosition[i]
                        tmpBox.makeEmpty()
                        for (j in 0..morphAttribute.count) {
                            v.set(morphAttribute.getX(j), morphAttribute.getY(j), morphAttribute.getZ(j))
                            tmpBox.expandByPoint(v)
                        }
                        if (this.morphTargetsRelative) {
                            let v1 = box.min.add(tmpBox.min)
                            box.expandByPoint(v1)
                            let v2 = box.max.add(tmpBox.max)
                            box.expandByPoint(v2)
                        } else {
                            box.expandByPoint(tmpBox.min)
                            box.expandByPoint(tmpBox.max)
                        }
                    }
                }
            }
        } else {
            if (let Some(box) <- this.boundingBox) {
                box.makeEmpty()
            }
        }
    }

    /**
     * @brief[zh-cn] 计算几何体的包围球并更新 boundingSphere 成员
     * @explain[zh-cn] 
     * 引擎在需要时（如射线投射或视锥剔除）自动计算包围球。
     * 若几何体顶点被修改，可能需要重新计算包围球。
     *
     * @brief[en] Computes the bounding sphere and updates the boundingSphere member
     * @explain[en] 
     * The engine automatically computes the bounding sphere when needed (e.g., for raycasting or frustum culling).
     * If geometry vertices are modified, the bounding sphere may need to be recomputed.
     */
    public func computeBoundingSphere(): Unit {
        if (this.boundingSphere.isNone()) {
            this.boundingSphere = Some(Sphere())
        }
        let positionOpt = this.attributes.get("position")
        if (let Some(position) <- positionOpt) {
            if (let Some(sphere) <- this.boundingSphere) {
                // 首先，找到包围球的中心
                let center = sphere.center
                let box = Box3()
                let v = Vector3()
                box.makeEmpty()
                for (i in 0..position.count) {
                    v.set(position.getX(i), position.getY(i), position.getZ(i))
                    box.expandByPoint(v)
                }
                // 处理形变属性（如果存在）
                let morphAttributesPositionOpt = this.morphAttributes.get("position")
                if (let Some(morphAttributesPosition) <- morphAttributesPositionOpt) {
                    let boxMorphTargets = Box3()
                    for (i in 0..morphAttributesPosition.size) {
                        let morphAttribute = morphAttributesPosition[i]
                        boxMorphTargets.makeEmpty()
                        for (j in 0..morphAttribute.count) {
                            v.set(morphAttribute.getX(j), morphAttribute.getY(j), morphAttribute.getZ(j))
                            boxMorphTargets.expandByPoint(v)
                        }
                        if (this.morphTargetsRelative) {
                            let v1 = box.min.add(boxMorphTargets.min)
                            box.expandByPoint(v1)
                            let v2 = box.max.add(boxMorphTargets.max)
                            box.expandByPoint(v2)
                        } else {
                            box.expandByPoint(boxMorphTargets.min)
                            box.expandByPoint(boxMorphTargets.max)
                        }
                    }
                }
                box.getCenter(center)
                // 其次，尝试找到一个半径更小的包围球
                // 最佳情况下比包围盒的包围球小 sqrt(3) 倍
                var maxRadiusSq = 0.0
                for (i in 0..position.count) {
                    let v = Vector3()
                    v.set(position.getX(i), position.getY(i), position.getZ(i))
                    maxRadiusSq = max(maxRadiusSq, center.distanceToSquared(v))
                }
                // 处理形变属性（如果存在）
                if (let Some(morphAttributesPosition) <- morphAttributesPositionOpt) {
                    for (i in 0..morphAttributesPosition.size) {
                        let morphAttribute = morphAttributesPosition[i]
                        let morphTargetsRelative = this.morphTargetsRelative
                        for (j in 0..morphAttribute.count) {
                            let v = Vector3().set(morphAttribute.getX(j), morphAttribute.getY(j), morphAttribute.getZ(j))
                            if (morphTargetsRelative) {
                                let offset = Vector3().set(position.getX(j), position.getY(j), position.getZ(j))
                                v.add(offset)
                            }
                            maxRadiusSq = max(maxRadiusSq, center.distanceToSquared(v))
                        }
                    }
                }
                sphere.radius = sqrt(maxRadiusSq)
            }
        }
    }

    /**
     * @brief[zh-cn] 计算并添加此几何体的切线属性
     * @explain[zh-cn] 
     * 计算仅支持索引几何体，且必须定义 position、normal、uv 属性。
     * 使用切线空间法线贴图时，优先使用 BufferGeometryUtils#computeMikkTSpaceTangents 算法。
     *
     * @brief[en] Computes and adds tangent attributes for this geometry
     * @explain[en] 
     * Computation only supports indexed geometry, and position, normal, uv attributes must be defined.
     * When using tangent space normal mapping, prefer the BufferGeometryUtils#computeMikkTSpaceTangents algorithm.
     */
    public func computeTangents(): Unit {
        let indexOpt = this.index
        let attributes = this.attributes
        // 基于 http://www.terathon.com/code/tangent.html（每顶点切线）
        if (indexOpt.isNone() || !attributes.contains("position") || !attributes.contains("normal") || !attributes.contains("uv")) {
            // 缺少必需属性（index、position、normal 或 uv）
            return
        }
        let index = indexOpt.getOrThrow()
        // attributes.get 返回 Option<BufferAttribute>，前面 contains 已确保存在，故 getOrThrow 取值
        let positionAttribute = attributes.get("position").getOrThrow()
        let normalAttribute = attributes.get("normal").getOrThrow()
        let uvAttribute = attributes.get("uv").getOrThrow()
        // 复用或新建 tangent 属性（itemSize=4）
        var tangentAttributeOpt = this.getAttribute("tangent")
        if (tangentAttributeOpt.isNone() || tangentAttributeOpt.getOrThrow().count != positionAttribute.count) {
            let arr = Array<Float64>(4 * positionAttribute.count, { _ => 0.0 })
            let ta = BufferAttribute(arr, 4, normalized: false)
            this.setAttribute("tangent", ta)
            tangentAttributeOpt = Some(ta)
        }
        let tangentAttribute = tangentAttributeOpt.getOrThrow()
        // tan1/tan2：每顶点累积的 sdir / tdir
        let nVerts = positionAttribute.count
        let tan1 = Array<Vector3>(nVerts, { _ => Vector3() })
        let tan2 = Array<Vector3>(nVerts, { _ => Vector3() })
        // 复用临时向量，避免在循环内重复分配
        let vA = Vector3(); let vB = Vector3(); let vC = Vector3()
        let uvA = Vector2(); let uvB = Vector2(); let uvC = Vector2()
        let sdir = Vector3(); let tdir = Vector3()
        // handleTriangle：根据三角形顶点索引 a/b/c 累加 sdir/tdir 到 tan1/tan2
        func handleTriangle(a: Int64, b: Int64, c: Int64): Unit {
            vA.set(positionAttribute.getX(a), positionAttribute.getY(a), positionAttribute.getZ(a))
            vB.set(positionAttribute.getX(b), positionAttribute.getY(b), positionAttribute.getZ(b))
            vC.set(positionAttribute.getX(c), positionAttribute.getY(c), positionAttribute.getZ(c))
            uvA.set(uvAttribute.getX(a), uvAttribute.getY(a))
            uvB.set(uvAttribute.getX(b), uvAttribute.getY(b))
            uvC.set(uvAttribute.getX(c), uvAttribute.getY(c))
            vB.sub(vA)
            vC.sub(vA)
            uvB.sub(uvA)
            uvC.sub(uvA)
            let r = 1.0 / (uvB.x * uvC.y - uvC.x * uvB.y)
            // 静默忽略退化 UV 三角形（共点或共线）
            if (r.isNaN() || r == Float64.Inf || r == -Float64.Inf) {
                return
            }
            sdir.copy(vB).multiplyScalar(uvC.y).addScaledVector(vC, -uvB.y).multiplyScalar(r)
            tdir.copy(vC).multiplyScalar(uvB.x).addScaledVector(vB, -uvC.x).multiplyScalar(r)
            tan1[a].add(sdir)
            tan1[b].add(sdir)
            tan1[c].add(sdir)
            tan2[a].add(tdir)
            tan2[b].add(tdir)
            tan2[c].add(tdir)
        }
        // 处理所有 groups（无 group 时退化为单个覆盖全部索引的 group）
        var groups = this.groups
        if (groups.size == 0) {
            groups = ArrayList<BufferGeometryGroup>()
            groups.add(BufferGeometryGroup(0, index.count))
        }
        for (i in 0..groups.size) {
            let group = groups[i]
            let start = group.start
            let count = if (group.count == 0) { index.count } else { group.count }
            var j = start
            let jl = start + count
            while (j < jl) {
                handleTriangle(
                    Int64(index.getX(j + 0)),
                    Int64(index.getX(j + 1)),
                    Int64(index.getX(j + 2))
                )
                j += 3
            }
        }
        // handleVertex：Gram-Schmidt 正交化 + 计算手性 w
        let tmp = Vector3(); let tmp2 = Vector3()
        let n = Vector3(); let n2 = Vector3()
        func handleVertex(v: Int64): Unit {
            n.set(normalAttribute.getX(v), normalAttribute.getY(v), normalAttribute.getZ(v))
            n2.copy(n)
            let t = tan1[v]
            // Gram-Schmidt 正交化
            tmp.copy(t)
            tmp.sub(n.multiplyScalar(n.dot(t))).normalize()
            // 计算手性
            tmp2.crossVectors(n2, t)
            let test = tmp2.dot(tan2[v])
            let w = if (test < 0.0) { -1.0 } else { 1.0 }
            tangentAttribute.setXYZW(v, tmp.x, tmp.y, tmp.z, w)
        }
        for (i in 0..groups.size) {
            let group = groups[i]
            let start = group.start
            let count = if (group.count == 0) { index.count } else { group.count }
            var j = start
            let jl = start + count
            while (j < jl) {
                handleVertex(Int64(index.getX(j + 0)))
                handleVertex(Int64(index.getX(j + 1)))
                handleVertex(Int64(index.getX(j + 2)))
                j += 3
            }
        }
    }

    /**
     * @brief[zh-cn] 为给定顶点数据计算顶点法线
     * @explain[zh-cn] 
     * 对索引几何体，方法将每个顶点法线设为共享该顶点的所有面法线的平均值。
     * 对非索引几何体，顶点不共享，方法将每个顶点法线设为与面法线相同。
     *
     * @brief[en] Computes vertex normals for the given vertex data
     * @explain[en] 
     * For indexed geometry, the method sets each vertex normal to the average of all face normals sharing that vertex.
     * For non-indexed geometry, vertices are not shared, and the method sets each vertex normal to the face normal.
     */
    public func computeVertexNormals(): Unit {
        let indexOpt = this.index
        let positionOpt = this.attributes.get("position")
        if (let Some(positionAttribute) <- positionOpt) {
            var normalAttributeOpt = this.attributes.get("normal")
            if (normalAttributeOpt.isNone()) {
                let arr = Array<Float64>(positionAttribute.count * 3, { _ => 0.0 })
                let normalAttribute = BufferAttribute(arr, 3, normalized: false)
                this.setAttribute("normal", normalAttribute)
                normalAttributeOpt = Some(normalAttribute)
            } else if (let Some(n) <- normalAttributeOpt) {
                if (n.count != positionAttribute.count) {
                    let arr = Array<Float64>(positionAttribute.count * 3, { _ => 0.0 })
                    let normalAttribute = BufferAttribute(arr, 3, normalized: false)
                    this.setAttribute("normal", normalAttribute)
                    normalAttributeOpt = Some(normalAttribute)
                } else {
                // 重置现有法线为零
                if (let Some(normalAttribute) <- normalAttributeOpt) {
                    for (i in 0..normalAttribute.count) {
                        normalAttribute.setXYZ(i, 0.0, 0.0, 0.0)
                    }
                }
            }
            let pA = Vector3()
            let pB = Vector3()
            let pC = Vector3()
            let nA = Vector3()
            let nB = Vector3()
            let nC = Vector3()
            let cb = Vector3()
            let ab = Vector3()
            // 索引元素
            if (let Some(index) <- indexOpt) {
                var i = 0
                while (i + 2 < index.count) {
                    let vA = Int64(index.getX(i + 0))
                    let vB = Int64(index.getX(i + 1))
                    let vC = Int64(index.getX(i + 2))
                    pA.set(positionAttribute.getX(vA), positionAttribute.getY(vA), positionAttribute.getZ(vA))
                    pB.set(positionAttribute.getX(vB), positionAttribute.getY(vB), positionAttribute.getZ(vB))
                    pC.set(positionAttribute.getX(vC), positionAttribute.getY(vC), positionAttribute.getZ(vC))
                    cb.subVectors(pC, pB)
                    ab.subVectors(pA, pB)
                    cb.cross(ab)
                    if (let Some(normalAttribute) <- normalAttributeOpt) {
                        nA.set(normalAttribute.getX(vA), normalAttribute.getY(vA), normalAttribute.getZ(vA))
                        nB.set(normalAttribute.getX(vB), normalAttribute.getY(vB), normalAttribute.getZ(vB))
                        nC.set(normalAttribute.getX(vC), normalAttribute.getY(vC), normalAttribute.getZ(vC))
                        nA.add(cb)
                        nB.add(cb)
                        nC.add(cb)
                        normalAttribute.setXYZ(vA, nA.x, nA.y, nA.z)
                        normalAttribute.setXYZ(vB, nB.x, nB.y, nB.z)
                        normalAttribute.setXYZ(vC, nC.x, nC.y, nC.z)
                    }
                    i += 3
                }
            } else {
                // 非索引元素（互不连接的三角形汤）
                var i = 0
                while (i + 2 < positionAttribute.count) {
                    pA.set(positionAttribute.getX(i + 0), positionAttribute.getY(i + 0), positionAttribute.getZ(i + 0))
                    pB.set(positionAttribute.getX(i + 1), positionAttribute.getY(i + 1), positionAttribute.getZ(i + 1))
                    pC.set(positionAttribute.getX(i + 2), positionAttribute.getY(i + 2), positionAttribute.getZ(i + 2))
                    cb.subVectors(pC, pB)
                    ab.subVectors(pA, pB)
                    cb.cross(ab)
                    if (let Some(normalAttribute) <- normalAttributeOpt) {
                        normalAttribute.setXYZ(i + 0, cb.x, cb.y, cb.z)
                        normalAttribute.setXYZ(i + 1, cb.x, cb.y, cb.z)
                        normalAttribute.setXYZ(i + 2, cb.x, cb.y, cb.z)
                    }
                    i += 3
                }
            }
            this.normalizeNormals()
            if (let Some(normalAttribute) <- normalAttributeOpt) {
                normalAttribute.markNeedsUpdate()
            }
        }
    }

    }
    
    /**
     * @brief[zh-cn] 确保几何体中每个法线向量长度为 1
     * @explain[zh-cn] 
     * 这将修正几何体表面的光照。
     *
     * @brief[en] Ensures each normal vector in the geometry has unit length
     * @explain[en] 
     * This corrects the lighting on the geometry surface.
     */
    public func normalizeNormals(): Unit {
        let normalsOpt = this.attributes.get("normal")
        if (let Some(normals) <- normalsOpt) {
            let v = Vector3()
            for (i in 0..normals.count) {
                v.set(normals.getX(i), normals.getY(i), normals.getZ(i))
                v.normalize()
                normals.setXYZ(i, v.x, v.y, v.z)
            }
        }
    }

    /**
     * @brief[zh-cn] 返回此索引几何体的非索引版本
     * @explain[zh-cn] 
     * 如果几何体已经是非索引的，则此方法是 NOOP。
     * @return[zh-cn] 此索引几何体的非索引版本
     *
     * @brief[en] Returns a non-indexed version of this indexed geometry
     * @explain[en] 
     * If the geometry is already non-indexed, this method is a NOOP.
     * @return[en] Non-indexed version of this indexed geometry
     */
    public func toNonIndexed(): BufferGeometry {
        // 转换 BufferAttribute 的内部函数
        if (this.index.isNone()) {
            // BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed.
            return this
        }
        let geometry2 = BufferGeometry()
        if (let Some(idx) <- this.index) {
            let indices = idx.array
            // 属性
            let attributes = this.attributes
            for (name in attributes.keys()) {
                if (let Some(attribute) <- attributes.get(name)) {
                    let newAttribute = convertBufferAttribute(attribute, indices)
                    geometry2.setAttribute(name, newAttribute)
                }
            }
            // 形变属性
            let morphAttributes = this.morphAttributes
            for (name in morphAttributes.keys()) {
                if (let Some(morphArray) <- morphAttributes.get(name)) {
                    let newArr = ArrayList<BufferAttribute>()
                    for (i in 0..morphArray.size) {
                        let attribute = morphArray[i]
                        let newAttribute = convertBufferAttribute(attribute, indices)
                        newArr.add(newAttribute)
                    }
                    geometry2.morphAttributes.add(name, newArr)
                }
            }
            geometry2.morphTargetsRelative = this.morphTargetsRelative
            // 绘制组
            let groups = this.groups
            for (i in 0..groups.size) {
                let group = groups[i]
                geometry2.addGroup(group.start, group.count, materialIndex: group.materialIndex)
            }
        }
        return geometry2
    }

    /**
     * @brief[zh-cn] 返回本几何体的生成参数
     * @explain[zh-cn] 
     * 对应 JS: this.parameters。仅几何体生成器子类覆写此方法返回非 None 值；
     * 基类默认返回 None（表示无生成参数）。
     * @return[zh-cn] 生成参数 HashMap，无参数时返回 None
     *
     * @brief[en] Returns the generation parameters of this geometry
     * @explain[en] 
     * Corresponds to JS: this.parameters. Only geometry generator subclasses override this method to return non-None values;
     * the base class defaults to returning None (indicating no generation parameters).
     * @return[en] Generation parameters HashMap, returns None when no parameters
     */
    public open func getParameters(): ?HashMap<String, Any> {
        return None
    }

    /**
     * @brief[zh-cn] 返回从此实例复制值的新几何体
     * @return[zh-cn] 此实例的克隆
     *
     * @brief[en] Returns a new geometry with values copied from this instance
     * @return[en] Clone of this instance
     */
    public func clone(): BufferGeometry {
        let g = BufferGeometry()
        return g.copy(this)
    }

    /**
     * @brief[zh-cn] 将给定几何体的值复制到此实例
     * @param[zh-cn] source 要复制的几何体
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Copies the values of the given geometry to this instance
     * @param[en] source Geometry to copy from
     * @return[en] Reference to this instance
     */
    public func copy(source: BufferGeometry): BufferGeometry {
        // 重置
        this.index = None
        this.attributes = HashMap<String, BufferAttribute>()
        this.morphAttributes = HashMap<String, ArrayList<BufferAttribute>>()
        this.groups = ArrayList<BufferGeometryGroup>()
        this.boundingBox = None
        this.boundingSphere = None
        // name
        this.name = source.name
        // index
        if (let Some(idx) <- source.index) {
            this.setIndex(idx.clone())
        }
        // attributes
        let attributes = source.attributes
        for (name in attributes.keys()) {
            if (let Some(attribute) <- attributes.get(name)) {
                this.setAttribute(name, attribute.clone())
            }
        }
        // morph attributes
        let morphAttributes = source.morphAttributes
        for (name in morphAttributes.keys()) {
            if (let Some(arr) <- morphAttributes.get(name)) {
                let newArr = ArrayList<BufferAttribute>()
                for (i in 0..arr.size) {
                    newArr.add(arr[i].clone())
                }
                this.morphAttributes.add(name, newArr)
            }
        }
        this.morphTargetsRelative = source.morphTargetsRelative
        // 绘制组
        let groups = source.groups
        for (i in 0..groups.size) {
            let group = groups[i]
            this.addGroup(group.start, group.count, materialIndex: group.materialIndex)
        }
        // 包围盒
        if (let Some(box) <- source.boundingBox) {
            this.boundingBox = Some(box.clone())
        }
        // 包围球
        if (let Some(sphere) <- source.boundingSphere) {
            this.boundingSphere = Some(sphere.clone())
        }
        // 绘制范围
        this.drawRange = source.drawRange
        // 用户数据
        this.userData = HashMap<String, Any>()
        for (key in source.userData.keys()) {
            if (let Some(v) <- source.userData.get(key)) {
                this.userData.add(key, v)
            }
        }
        // 变换标志
        this._transformed = source._transformed
        return this
    }

    /**
     * @brief[zh-cn] 释放此实例分配的 GPU 相关资源
     * @explain[zh-cn] 
     * 当此实例不再使用时调用此方法。
     *
     * @brief[en] Releases GPU-related resources allocated by this instance
     * @explain[en] 
     * Call this method when this instance is no longer in use.
     */
    public func dispose(): Unit {
        // 触发 dispose 事件
        this.attributes.clear()
        this.index = None
    }

    /**
     * @brief[zh-cn] 内部辅助：将 BufferAttribute 按 indices 数组转换为非索引属性
     *
     * @brief[en] Internal helper: converts BufferAttribute to non-indexed attribute by indices array
     */
    private func convertBufferAttribute(attribute: BufferAttribute, indices: Array<Float64>): BufferAttribute {
        let array = attribute.array
        let itemSize = attribute.itemSize
        let normalized = attribute.normalized
        let array2 = Array<Float64>(indices.size * itemSize, { _ => 0.0 })
        var index2 = 0
        for (i in 0..indices.size) {
            var index = 0
            // Ignore: convertBufferAttribute 内部辅助，按 indices * itemSize 取值的实现正确，仅注释解释算法。
            index = Int64(indices[i]) * itemSize
            for (j in 0..itemSize) {
                array2[index2] = array[index + j]
                index2 += 1
            }
        }
        return BufferAttribute(array2, itemSize, normalized: normalized)
    }
}
