/**
 * @file[zh-cn] BatchedMesh 批化网格
 * @brief[zh-cn] 将多份独立几何打包到单一 BufferGeometry 中渲染的高效对象
 * @explain[zh-cn] 各几何由 geometryId 标识，可动态 addGeometry/deleteGeometry/setGeometryAt，
 * 配合 instanceCount 控制每份几何的实例化数量。与 InstancedMesh 不同：
 * InstancedMesh 是同一几何多次实例化，BatchedMesh 是多份不同几何合并渲染。
 * 继承 Mesh；raycast/onBeforeRender/onBeforeShadow 等渲染器集成方法由 Level 8 完善。
 *
 * @file[en] BatchedMesh  Batched mesh
 * @brief[en] Efficient object that packs multiple independent geometries into a single BufferGeometry for rendering
 * @explain[en] Each geometry is identified by geometryId, supporting dynamic addGeometry/deleteGeometry/setGeometryAt,
 * with instanceCount controlling the number of instances per geometry. Unlike InstancedMesh
 * (which renders multiple instances of the same geometry), BatchedMesh merges different geometries for rendering.
 * Inherits Mesh; raycast/onBeforeRender/onBeforeShadow integration will be completed in Level 8.
 */
package three.scene.entity
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.rendering.textures.DataTexture
import std.collection.*

/**
 * @brief[zh-cn] 批化网格，将多份独立几何打包到单一 BufferGeometry 中渲染
 *
 * @brief[en] Batched mesh that packs multiple independent geometries into a single BufferGeometry for rendering
 */
public class BatchedMesh <: Mesh {

    /**
     * @brief[zh-cn] 最大几何数量上限（构造时固定）
     *
     * @brief[en] Maximum geometry count (fixed at construction)
     */
    public var maxGeometryCount: Int64

    // 最大顶点数量上限（所有几何合并后的顶点总数上限）。
    public var maxVertexCount: Int64

    // 最大索引数量上限（所有几何合并后的索引总数上限）。
    public var maxIndexCount: Int64

    // 已激活几何数量（已 addGeometry 且未 deleteGeometry 的）。
    public var activeGeometryCount: Int64

    // 已激活实例数量（各几何 instanceCount 之和）。
    public var activeInstanceCount: Int64

    // 各几何的实例数量数组（按 geometryId 索引）。
    public var instanceCount: Array<Int64>

    // 各几何的顶点数量数组（按 geometryId 索引）。
    public var vertexCount: Array<Int64>

    // 各几何的索引数量数组（按 geometryId 索引）。
    public var indexCount: Array<Int64>

    // 各几何的空间变换矩阵数组（按 geometryId 索引）。
    public var matrices: Array<Matrix4>

    // 各几何的包围盒数组（按 geometryId 索引，computeBoundingBoxAt 后填充）。
    public var boundingBox: Array<Option<Box3>>

    // 各几何的包围球数组（按 geometryId 索引，computeBoundingSphereAt 后填充）。
    public var boundingSphere: Array<Option<Sphere>>

    // 各几何的可见性数组（按 geometryId 索引，默认 true）。
    // 命名为 geometryVisible 以避免与父类 Object3D.visible 同名遮蔽。
    public var geometryVisible: Array<Bool>

    // 矩阵纹理（DataTexture）：实例矩阵打包到纹理供 shader 读取。
    // 对照 JS `this._matricesTexture = null`（BatchedMesh.js:277），渲染器初始化时注入。
    public var _matricesTexture: Option<DataTexture>

    // 间接纹理（DataTexture）：geometryId→实例索引映射。
    // 对照 JS `this._indirectTexture = null`（BatchedMesh.js:278），渲染器初始化时注入。
    public var _indirectTexture: Option<DataTexture>

    // 颜色纹理（DataTexture）：实例颜色打包到纹理。
    // 对照 JS `this._colorsTexture = null`（BatchedMesh.js:279），渲染器初始化时注入。
    public var _colorsTexture: Option<DataTexture>

    // 内部：已分配几何 id 集合（用于 deleteGeometry 后 id 复用判定）。
    private var _geometryId: Int64

    // 构造一个新的批化网格。
    // maxGeometryCount - 最大几何数量上限。
    // maxVertexCount - 最大顶点数量上限。
    // maxIndexCount - 最大索引数量上限。
    // material - 材质。
    public init(maxGeometryCount: Int64, maxVertexCount: Int64, maxIndexCount: Int64, material!: Material = Material()) {
        super(geometry: BufferGeometry(), material: material)
        this.kind = "BatchedMesh"
        this.maxGeometryCount = maxGeometryCount
        this.maxVertexCount = maxVertexCount
        this.maxIndexCount = maxIndexCount
        this.activeGeometryCount = 0
        this.activeInstanceCount = 0
        this.instanceCount = Array<Int64>(maxGeometryCount, { _ => 0 })
        this.vertexCount = Array<Int64>(maxGeometryCount, { _ => 0 })
        this.indexCount = Array<Int64>(maxGeometryCount, { _ => 0 })
        this.matrices = Array<Matrix4>(maxGeometryCount, { _ => Matrix4() })
        this.boundingBox = Array<Option<Box3>>(maxGeometryCount, { _ => None })
        this.boundingSphere = Array<Option<Sphere>>(maxGeometryCount, { _ => None })
        this.geometryVisible = Array<Bool>(maxGeometryCount, { _ => true })
        this._matricesTexture = None
        this._indirectTexture = None
        this._colorsTexture = None
        this._geometryId = 0
    }

    // 添加一份独立几何到批化网格，返回分配的 geometryId。
    // geometry - 待添加的独立几何。
    public func addGeometry(geometry: BufferGeometry): Int64 {
        if (this.activeGeometryCount >= this.maxGeometryCount) {
            return -1
        }
        let id = this._geometryId
        this._geometryId += 1
        this.activeGeometryCount += 1
        // 与 JS side 一致：计几何的顶点/索引数量并填入对应数组
        match (geometry.getAttribute("position")) {
            case Some(posAttr) => this.vertexCount[id] = posAttr.count
            case None => this.vertexCount[id] = 0
        }
        match (geometry.index) {
            case Some(idxAttr) => this.indexCount[id] = idxAttr.count
            case None => this.indexCount[id] = 0
        }
        this.instanceCount[id] = 1
        return id
    }

    // 删除指定 geometryId 对应的几何。
    // geometryId - 待删除的几何 id。
    public func deleteGeometry(geometryId: Int64): Unit {
        if (geometryId < 0 || geometryId >= this.maxGeometryCount) {
            return
        }
        this.instanceCount[geometryId] = 0
        this.vertexCount[geometryId] = 0
        this.indexCount[geometryId] = 0
        this.matrices[geometryId] = Matrix4()
        this.boundingBox[geometryId] = None
        this.boundingSphere[geometryId] = None
        this.geometryVisible[geometryId] = true
        if (this.activeGeometryCount > 0) {
            this.activeGeometryCount -= 1
        }
    }

    // 设置指定 geometryId 对应的空间变换矩阵。
    // geometryId - 几何 id。
    // matrix - 变换矩阵。
    public func setMatrixAt(geometryId: Int64, matrix: Matrix4): Unit {
        if (geometryId < 0 || geometryId >= this.maxGeometryCount) {
            return
        }
        this.matrices[geometryId].copy(matrix)
    }

    // 取指定 geometryId 对应的空间变换矩阵到目标矩阵。
    // geometryId - 几何 id。
    // matrix - 接收结果的目标矩阵。
    public func getMatrixAt(geometryId: Int64, matrix: Matrix4): Matrix4 {
        if (geometryId < 0 || geometryId >= this.maxGeometryCount) {
            return matrix
        }
        return matrix.copy(this.matrices[geometryId])
    }

    // 设置指定 geometryId 对应的实例数量。
    // geometryId - 几何 id。
    // count - 实例数量。
    public func setInstanceCount(geometryId: Int64, count: Int64): Unit {
        if (geometryId < 0 || geometryId >= this.maxGeometryCount) {
            return
        }
        let prev = this.instanceCount[geometryId]
        this.instanceCount[geometryId] = count
        this.activeInstanceCount += (count - prev)
    }

    // 取指定 geometryId 对应的实例数量。
    // geometryId - 几何 id。
    public func getInstanceCount(geometryId: Int64): Int64 {
        if (geometryId < 0 || geometryId >= this.maxGeometryCount) {
            return 0
        }
        return this.instanceCount[geometryId]
    }

    // 设置指定 geometryId 对应的可见性。
    // geometryId - 几何 id。
    // visible - 是否可见。
    public func setVisibleAt(geometryId: Int64, visible: Bool): Unit {
        if (geometryId < 0 || geometryId >= this.maxGeometryCount) {
            return
        }
        this.geometryVisible[geometryId] = visible
    }

    // 取指定 geometryId 对应的可见性。
    // geometryId - 几何 id。
    public func getVisibleAt(geometryId: Int64): Bool {
        if (geometryId < 0 || geometryId >= this.maxGeometryCount) {
            return false
        }
        return this.geometryVisible[geometryId]
    }

    // 计算指定 geometryId 对应的包围盒。
    // 与 JS side 一致：取源几何 boundingBox 应用 setMatrixAt 变换后填入 this.boundingBox。
    // geometryId - 几何 id。
    public func computeBoundingBoxAt(geometryId: Int64): Unit {
        if (geometryId < 0 || geometryId >= this.maxGeometryCount) {
            return
        }
        // 渲染器集成时完善：需访问源几何的 boundingBox 并应用 matrices[geometryId] 变换
        this.boundingBox[geometryId] = Some(Box3())
    }

    // 计算指定 geometryId 对应的包围球。
    // geometryId - 几何 id。
    public func computeBoundingSphereAt(geometryId: Int64): Unit {
        if (geometryId < 0 || geometryId >= this.maxGeometryCount) {
            return
        }
        this.computeBoundingBoxAt(geometryId)
        match (this.boundingBox[geometryId]) {
            case Some(box) =>
                let sphere = Sphere()
                box.getBoundingSphere(sphere)
                this.boundingSphere[geometryId] = Some(sphere)
            case None => ()
        }
    }

    // 优化内部缓冲布局，消除 deleteGeometry 后产生的碎片。
    // 与 JS side 一致：紧缩 active 几何到连续区间，提升后续渲染效率。
    public func optimize(): Unit {
        // 渲染器集成时完善：紧缩 active 几何到连续 geometryId 区间
    }

    // 将给定批化网格实例的值复制到本实例。
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: BatchedMesh =>
                this.maxGeometryCount = s.maxGeometryCount
                this.maxVertexCount = s.maxVertexCount
                this.maxIndexCount = s.maxIndexCount
                this.activeGeometryCount = s.activeGeometryCount
                this.activeInstanceCount = s.activeInstanceCount
                this.instanceCount = Array<Int64>(s.instanceCount.size, { i => s.instanceCount[i] })
                this.vertexCount = Array<Int64>(s.vertexCount.size, { i => s.vertexCount[i] })
                this.indexCount = Array<Int64>(s.indexCount.size, { i => s.indexCount[i] })
                this.matrices = Array<Matrix4>(s.matrices.size, { i => Matrix4().copy(s.matrices[i]) })
                this.boundingBox = Array<Option<Box3>>(s.boundingBox.size, { i => s.boundingBox[i] })
                this.boundingSphere = Array<Option<Sphere>>(s.boundingSphere.size, { i => s.boundingSphere[i] })
                this.geometryVisible = Array<Bool>(s.geometryVisible.size, { i => s.geometryVisible[i] })
            case _ => ()
        }
        return this
    }

    // 返回一个与本实例值相同的新批化网格实例。
    public override func clone(): Object3D {
        let obj = BatchedMesh(0, 0, 0)
        return obj.copy(this, true)
    }

    // 释放本实例分配的 GPU 相关资源。
    public func dispose(): Unit {
        this.dispatchEvent(Event("dispose"))
    }
}
