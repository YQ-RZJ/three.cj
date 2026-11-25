/**
 * @file geometryc 类型定义
 * @brief geometryc C API 的枚举、不透明类型和结构体定义
 * @explain 本文件包含 geometryc 几何体编译器的 CFFI 类型定义，
 *         包括坐标系统枚举、配置结构体、图元信息和转换结果。
 * @note 值类型通过 @C 标注确保 C 内存布局兼容。
 */
protected package three._vendor.bgfx4cj.geometryc

// =============================================================================
// Enums
// =============================================================================

/**
 * @brief 坐标系统枚举
 * @explain 定义输出几何体的坐标系（惯用手、向上方向和向前方向）。
 */
public enum CoordSystem {
    /** @brief 左手系，Y 轴向上，Z 轴向前 */
    | LhUpY
    /** @brief 左手系，Z 轴向上，Y 轴向前 */
    | LhUpZ
    /** @brief 右手系，Y 轴向上，Z 轴向前 */
    | RhUpY
    /** @brief 右手系，Z 轴向上，Y 轴向前 */
    | RhUpZ

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case LhUpY => 0
            case LhUpZ => 1
            case RhUpY => 2
            case RhUpZ => 3
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): CoordSystem {
        match (v) {
            case 0 => LhUpY
            case 1 => LhUpZ
            case 2 => RhUpY
            case 3 => RhUpZ
            case _ => LhUpY
        }
    }
}

// =============================================================================
// Value structs (C-compatible layout via @C annotation)
// =============================================================================

/**
 * @brief 几何体转换配置
 * @explain 控制几何体解析和转换的参数，包括缩放、顶点打包、坐标系统等。
 *         传入 NULL 时使用默认值（scale=1.0, coord=LH_UP_Y, 不压缩）。
 */
@C
public struct GcConfig {
    /** @brief 顶点缩放因子（默认 1.0） */
    public var scale: Float32 = 1.0f32
    /** @brief 法线打包模式：0 = float3, 1 = Uint8（默认 0） */
    public var packNormal: UInt8 = 0
    /** @brief UV 打包模式：0 = float2, 1 = Half（默认 0） */
    public var packUv: UInt8 = 0
    /** @brief 是否逆时针绕序 */
    public var ccw: Bool = false
    /** @brief 是否翻转 V 坐标 */
    public var flipV: Bool = false
    /** @brief 是否计算切线 */
    public var hasTangent: Bool = false
    /** @brief 是否生成重心坐标 */
    public var hasBarycentric: Bool = false
    /** @brief 是否压缩顶点/索引缓冲 */
    public var compress: Bool = false
    /** @brief 坐标系统（默认 LhUpY） */
    public var coordSystem: UInt32 = 0
    public init() {}
}

/**
 * @brief 图元信息
 * @explain 描述一个几何体图元（对应一个材质/组）的顶点和索引范围。
 */
@C
public struct GcPrimitive {
    /** @brief 起始顶点索引 */
    public var startVertex: UInt32 = 0
    /** @brief 起始索引偏移 */
    public var startIndex: UInt32 = 0
    /** @brief 顶点数量 */
    public var numVertices: UInt32 = 0
    /** @brief 索引数量 */
    public var numIndices: UInt32 = 0
    /** @brief 材质/组名称指针（指向 result 内部，不单独释放） */
    public var name: CPointer<UInt8> = CPointer<UInt8>()
    public init() {}
}

/**
 * @brief 转换结果
 * @explain geometryc 转换后的输出数据，包含完整的 bgfx 二进制几何体数据。
 */
@C
public struct GcResult {
    /** @brief 完整二进制输出数据指针 */
    public var data: CPointer<Unit> = CPointer<Unit>()
    /** @brief 输出数据大小（字节） */
    public var size: UInt32 = 0
    /** @brief 顶点总数 */
    public var numVertices: UInt32 = 0
    /** @brief 索引总数 */
    public var numIndices: UInt32 = 0
    /** @brief 图元组数 */
    public var numPrimitives: UInt32 = 0
    /** @brief 图元数组指针（size = numPrimitives） */
    public var primitives: CPointer<GcPrimitive> = CPointer<GcPrimitive>()
    public init() {}
}