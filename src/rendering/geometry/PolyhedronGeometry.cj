/**
 * @file[zh-cn] 多面体几何体
 * @brief[zh-cn] 多面体几何体基类，将顶点数组投影到球面并细分到指定细节级别
 * @explain[zh-cn] 
 * 多面体是三维空间中具有平坦面的立体。本类接收顶点数组，将其投影到球面，
 * 然后按所需细节级别细分。
 * 多面体几何体基类，通过顶点和面索引生成几何体数据。
 * 八面体(OctahedronGeometry)、四面体(TetrahedronGeometry)、
 * 二十面体(IcosahedronGeometry)、十二面体(DodecahedronGeometry)
 * 均基于此类。
 *
 * @file[en] Polyhedron Geometry
 * @brief[en] Polyhedron geometry base class, projecting vertex arrays onto a sphere and subdividing to specified detail level
 * @explain[en] 
 * A polyhedron is a solid in 3D space with flat faces. This class receives a vertex array,
 * projects it onto a sphere, and subdivides it to the desired detail level.
 * Polyhedron geometry base class that generates geometry data from vertices and face indices.
 * OctahedronGeometry, TetrahedronGeometry, IcosahedronGeometry, and DodecahedronGeometry
 * are all based on this class.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 多面体几何体类，将顶点数组投影到球面并细分到指定细节级别
 * @explain[zh-cn] 
 * 八面体、四面体、二十面体、十二面体均基于此类。
 * @param[zh-cn] vertices 描述基础形状的平铺顶点数组
 * indices 描述基础形状的平铺索引数组
 * radius 形状的半径，默认为 1.0
 * detail 细分级别，值越大形状越光滑，默认为 0
 *
 * @brief[en] Polyhedron geometry class, projecting vertex arrays onto a sphere and subdividing to specified detail level
 * @explain[en] 
 * Octahedron, tetrahedron, icosahedron, and dodecahedron are all based on this class.
 * @param[en] vertices Flattened vertex array describing the base shape
 * indices Flattened index array describing the base shape
 * radius Shape radius, default 1.0
 * detail Subdivision level, higher values produce smoother shapes, default 0
 */
public open class PolyhedronGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 保存构造参数，实例化后修改不影响几何体
     *
     * @brief[en] Stores construction parameters; modifying after instantiation does not affect the geometry
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造多面体几何体
     * @param[zh-cn] vertices 描述基础形状的平铺顶点数组
     * indices 描述基础形状的平铺索引数组
     * radius 形状的半径，默认为 1.0
     * detail 细分级别，默认为 0
     *
     * @brief[en] Constructs a polyhedron geometry
     * @param[en] vertices Flattened vertex array describing the base shape
     * indices Flattened index array describing the base shape
     * radius Shape radius, default 1.0
     * detail Subdivision level, default 0
     */
    public init(vertices!: Array<Float64> = Array<Float64>(), indices!: Array<Int64> = Array<Int64>(), radius!: Float64 = 1.0, detail!: Int64 = 0) {
        super()
        this.kind = "PolyhedronGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("vertices", vertices)
        this.parameters.add("indices", indices)
        this.parameters.add("radius", radius)
        this.parameters.add("detail", detail)

        // 默认缓冲数据
        let vertexBuffer = ArrayList<Float64>()
        let uvBuffer = ArrayList<Float64>()

        // 细分创建顶点缓冲数据
        _subdivide(detail, vertices, indices, vertexBuffer)

        // 所有顶点应位于半径为 radius 的球面上
        _applyRadius(radius, vertexBuffer)

        // 生成 UV 数据
        _generateUVs(vertexBuffer, uvBuffer)

        // 构建非索引几何体
        let posArr = Array<Float64>(vertexBuffer.size, { i => vertexBuffer[i] })
        let normArr = Array<Float64>(vertexBuffer.size, { i => 0.0 })
        // 法线从顶点位置计算（归一化方向）
        for (i in 0..vertexBuffer.size / 3) {
            let x = posArr[i * 3]; let y = posArr[i * 3 + 1]; let z = posArr[i * 3 + 2]
            let len = sqrt(x * x + y * y + z * z)
            if (len > 0.0) {
                normArr[i * 3] = x / len; normArr[i * 3 + 1] = y / len; normArr[i * 3 + 2] = z / len
            }
        }
        let uvArr = Array<Float64>(uvBuffer.size, { i => uvBuffer[i] })
        let idxArr = Array<Float64>(vertexBuffer.size / 3, { i => Float64(i) })

        let (attrs, idxAttr) = _buildPolyhedronAttributes(posArr, normArr, uvArr, idxArr)
        // open 类构造器不能 this 方法调用（setAttribute/setIndex）——字段直接赋值
        this.attributes = attrs
        this.index = Some(idxAttr)
    }

    /**
     * @param[zh-cn] detail 细分级别
     * @param[zh-cn] vertices 顶点数组
     * @param[zh-cn] indices 索引数组
     * @param[zh-cn] vertexBuffer 输出顶点缓冲
     *
     * 按指定细节级别细分所有面
     *
     * @param[en] detail Subdivision level
     * @param[en] vertices Vertex array
     * @param[en] indices Index array
     * @param[en] vertexBuffer Output vertex buffer
     *
     * Subdivide all faces at the specified detail level
     */
    private static func _subdivide(detail: Int64, vertices: Array<Float64>, indices: Array<Int64>, vertexBuffer: ArrayList<Float64>): Unit {
        if (detail == 0) {
            // 不细分：直接输出原始三角形顶点
            for (i in 0..indices.size / 3) {
                let a = indices[i * 3] * 3
                let b = indices[i * 3 + 1] * 3
                let c = indices[i * 3 + 2] * 3
                vertexBuffer.add(vertices[a]); vertexBuffer.add(vertices[a + 1]); vertexBuffer.add(vertices[a + 2])
                vertexBuffer.add(vertices[b]); vertexBuffer.add(vertices[b + 1]); vertexBuffer.add(vertices[b + 2])
                vertexBuffer.add(vertices[c]); vertexBuffer.add(vertices[c + 1]); vertexBuffer.add(vertices[c + 2])
            }
        } else {
            // 有细分：对每个三角形面进行递归细分
            for (i in 0..indices.size / 3) {
                let a = indices[i * 3]; let b = indices[i * 3 + 1]; let c = indices[i * 3 + 2]
                let v1 = Vector3(vertices[a * 3], vertices[a * 3 + 1], vertices[a * 3 + 2])
                let v2 = Vector3(vertices[b * 3], vertices[b * 3 + 1], vertices[b * 3 + 2])
                let v3 = Vector3(vertices[c * 3], vertices[c * 3 + 1], vertices[c * 3 + 2])
                _subdivideFace(detail, v1, v2, v3, vertexBuffer)
            }
        }
    }

    /**
     * 细分单个三角形面
     * 将三角形细分为 detail 级别的子三角形网格
     */
    private static func _subdivideFace(detail: Int64, a: Vector3, b: Vector3, c: Vector3, vertexBuffer: ArrayList<Float64>): Unit {
        let cols = detail + 1
        // 生成细分顶点网格
        let v = Array<Array<Vector3>>(cols, { _ => Array<Vector3>(cols, { _ => Vector3() }) })
        for (i in 0..cols) {
            let ai = a.clone().lerp(c, Float64(i) / Float64(detail))
            let bi = b.clone().lerp(c, Float64(i) / Float64(detail))
            let row = cols - i
            for (j in 0..row) {
                v[i][j] = ai.clone().lerp(bi, Float64(j) / Float64(max(1, row - 1)))
            }
        }
        // 生成三角形
        for (i in 0..detail) {
            for (j in 0..detail - i) {
                let p1 = v[i][j]; let p2 = v[i + 1][j]; let p3 = v[i][j + 1]
                vertexBuffer.add(p1.x); vertexBuffer.add(p1.y); vertexBuffer.add(p1.z)
                vertexBuffer.add(p2.x); vertexBuffer.add(p2.y); vertexBuffer.add(p2.z)
                vertexBuffer.add(p3.x); vertexBuffer.add(p3.y); vertexBuffer.add(p3.z)
                if (j + 1 < detail - i) {
                    let p4 = v[i + 1][j + 1]
                    vertexBuffer.add(p2.x); vertexBuffer.add(p2.y); vertexBuffer.add(p2.z)
                    vertexBuffer.add(p4.x); vertexBuffer.add(p4.y); vertexBuffer.add(p4.z)
                    vertexBuffer.add(p3.x); vertexBuffer.add(p3.y); vertexBuffer.add(p3.z)
                }
            }
        }
    }

    /**
     * 将顶点投影到半径为 radius 的球面上
     */
    private static func _applyRadius(radius: Float64, vertexBuffer: ArrayList<Float64>): Unit {
        for (i in 0..vertexBuffer.size / 3) {
            let x = vertexBuffer[i * 3]; let y = vertexBuffer[i * 3 + 1]; let z = vertexBuffer[i * 3 + 2]
            let len = sqrt(x * x + y * y + z * z)
            if (len > 0.0) {
                vertexBuffer[i * 3] = x / len * radius
                vertexBuffer[i * 3 + 1] = y / len * radius
                vertexBuffer[i * 3 + 2] = z / len * radius
            }
        }
    }

    /**
     * 生成 UV 坐标
     * 使用球面映射计算 UV：u = 方位角 / 2π, v = 极角 / π
     */
    private static func _generateUVs(vertexBuffer: ArrayList<Float64>, uvBuffer: ArrayList<Float64>): Unit {
        for (i in 0..vertexBuffer.size / 3) {
            let x = vertexBuffer[i * 3]; let y = vertexBuffer[i * 3 + 1]; let z = vertexBuffer[i * 3 + 2]
            let len = sqrt(x * x + y * y + z * z)
            let nx = x / len; let ny = y / len; let nz = z / len
            let u = 0.5 + atan2(nz, nx) / (2.0 * PI)
            let v = 0.5 - asin(ny) / PI
            uvBuffer.add(u); uvBuffer.add(v)
        }
    }

    /**
     * @param[zh-cn] data 包含序列化几何体数据的 JSON 对象
     * @return[zh-cn] 新的 PolyhedronGeometry 实例
     *
     * 从 JSON 数据创建实例的工厂方法
     *
     * @param[en] data JSON object containing serialized geometry data
     * @return[en] New PolyhedronGeometry instance
     *
     * Factory method to create an instance from JSON data
     */
    public static func fromJSON(data: HashMap<String, Any>): PolyhedronGeometry {
        var verts: Array<Float64> = Array<Float64>()
        var idxs: Array<Int64> = Array<Int64>()
        var r: Float64 = 1.0
        var d: Int64 = 0
        match (data.get("vertices")) { case Some(v: Array<Float64>) => verts = v; case _ => () }
        match (data.get("indices")) { case Some(v: Array<Int64>) => idxs = v; case _ => () }
        match (data.get("radius")) { case Some(v: Float64) => r = v; case _ => () }
        match (data.get("detail")) { case Some(v: Int64) => d = v; case _ => () }
        return PolyhedronGeometry(vertices: verts, indices: idxs, radius: r, detail: d)
    }

    /// open 类构造器不能 this 方法调用——构建数据由静态方法计算（Float32BufferAttribute 构造非 this）
    static func _buildPolyhedronAttributes(posArr: Array<Float64>, normArr: Array<Float64>, uvArr: Array<Float64>, idxArr: Array<Float64>): (HashMap<String, BufferAttribute>, BufferAttribute) {
        let attrs = HashMap<String, BufferAttribute>()
        attrs.add("position", Float32BufferAttribute(posArr, 3))
        attrs.add("normal", Float32BufferAttribute(normArr, 3))
        attrs.add("uv", Float32BufferAttribute(uvArr, 2))
        return (attrs, Float32BufferAttribute(idxArr, 1))
    }
}