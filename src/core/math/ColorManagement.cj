/**
 * @file[zh-cn] ColorManagement
 * @brief[zh-cn] 颜色空间管理
 * @explain[zh-cn] 定义颜色空间转换和常量，提供 sRGB 和线性 sRGB 之间的转换功能。参考 Three.js ColorManagement 实现。使用 String 类型标识颜色空间，与 constants.cj 中定义的常量一致。
 *
 * @file[en] ColorManagement
 * @brief[en] Color space management
 * @explain[en] Defines color space conversion and constants, providing conversion between sRGB and linear sRGB. Referenced from Three.js ColorManagement implementation. Uses String type for color space identification, consistent with constants defined in constants.cj.
 */
package three.core.math

import std.math.*
import std.collection.*
import three.utils.constants.*

/**
 * @brief[zh-cn] 颜色空间定义，包含原色坐标、白点、传输函数、变换矩阵等信息
 *
 * @brief[en] Color space definition, containing primary coordinates, white point, transfer function, transformation matrix, etc.
 */
public class ColorSpaceDefinition {
    /**
     * @brief[zh-cn] 原色色度坐标 [rx ry gx gy bx by]
     *
     * @brief[en] Primary chromaticity coordinates [rx ry gx gy bx by]
     */
    public var primaries: Array<Float64>
    /**
     * @brief[zh-cn] 参考白点 [x y]
     *
     * @brief[en] Reference white point [x y]
     */
    public var whitePoint: Array<Float64>
    /**
     * @brief[zh-cn] 传输函数标识
     *
     * @brief[en] Transfer function identifier
     */
    public var transfer: String
    /**
     * @brief[zh-cn] RGB 到 XYZ 变换矩阵
     *
     * @brief[en] RGB to XYZ transformation matrix
     */
    public var toXYZ: Matrix3
    /**
     * @brief[zh-cn] XYZ 到 RGB 变换矩阵
     *
     * @brief[en] XYZ to RGB transformation matrix
     */
    public var fromXYZ: Matrix3
    /**
     * @brief[zh-cn] RGB 亮度系数
     *
     * @brief[en] RGB luminance coefficients
     */
    public var luminanceCoefficients: Array<Float64>
    /**
     * @brief[zh-cn] 工作颜色空间配置（可选）
     *
     * @brief[en] Working color space configuration (optional)
     */
    public var workingColorSpaceConfig: ?ColorSpaceWorkingConfig
    /**
     * @brief[zh-cn] 输出颜色空间配置（可选）
     *
     * @brief[en] Output color space configuration (optional)
     */
    public var outputColorSpaceConfig: ?ColorSpaceOutputConfig

    public init(
        primaries: Array<Float64>,
        whitePoint: Array<Float64>,
        transfer: String,
        toXYZ: Matrix3,
        fromXYZ: Matrix3,
        luminanceCoefficients: Array<Float64>,
        workingColorSpaceConfig!: ?ColorSpaceWorkingConfig = None,
        outputColorSpaceConfig!: ?ColorSpaceOutputConfig = None
    ) {
        this.primaries = primaries
        this.whitePoint = whitePoint
        this.transfer = transfer
        this.toXYZ = toXYZ
        this.fromXYZ = fromXYZ
        this.luminanceCoefficients = luminanceCoefficients
        this.workingColorSpaceConfig = workingColorSpaceConfig
        this.outputColorSpaceConfig = outputColorSpaceConfig
    }
}

/**
 * @brief[zh-cn] 工作颜色空间配置
 *
 * @brief[en] Working color space configuration
 */
public class ColorSpaceWorkingConfig {
    /**
     * @brief[zh-cn] 解包颜色空间
     *
     * @brief[en] Unpack color space
     */
    public var unpackColorSpace: String

    public init(unpackColorSpace: String) {
        this.unpackColorSpace = unpackColorSpace
    }
}

/**
 * @brief[zh-cn] 输出颜色空间配置
 *
 * @brief[en] Output color space configuration
 */
public class ColorSpaceOutputConfig {
    /**
     * @brief[zh-cn] 绘图缓冲区颜色空间
     *
     * @brief[en] Drawing buffer color space
     */
    public var drawingBufferColorSpace: String
    /**
     * @brief[zh-cn] 色调映射模式
     *
     * @brief[en] Tone mapping mode
     */
    public var toneMappingMode: String

    public init(drawingBufferColorSpace: String, toneMappingMode!: String = "standard") {
        this.drawingBufferColorSpace = drawingBufferColorSpace
        this.toneMappingMode = toneMappingMode
    }
}

/**
 * @brief[zh-cn] 颜色空间管理类，提供颜色空间之间的转换功能
 * @explain[zh-cn] 支持的颜色空间通过 define 方法注册，默认注册了 sRGB 和线性 sRGB。颜色空间标识使用 String 类型，与 constants.cj 中的常量一致。
 *
 * @brief[en] Color space management class, providing color space conversion functionality
 * @explain[en] Supported color spaces are registered via the define method, with sRGB and linear sRGB registered by default. Color space identifiers use String type, consistent with constants in constants.cj.
 */
public class ColorManagement {
    /**
     * @brief[zh-cn] 是否启用颜色空间管理
     *
     * @brief[en] Whether color space management is enabled
     */
    public static var enabled: Bool = true

    /**
     * @brief[zh-cn] 当前工作颜色空间（默认为线性 sRGB）
     *
     * @brief[en] Current working color space (default is linear sRGB)
     */
    public static var workingColorSpace: String = LinearSRGBColorSpace

    /**
     * @brief[zh-cn] 已注册的颜色空间定义
     *
     * @brief[en] Registered color space definitions
     */
    public static var spaces: HashMap<String, ColorSpaceDefinition> = HashMap<String, ColorSpaceDefinition>()

    // ===== 预定义变换矩阵 =====

    /**
     * @brief[zh-cn] 线性 Rec.709 到 XYZ 变换矩阵
     *
     * @brief[en] Linear Rec.709 to XYZ transformation matrix
     */
    public static let LINEAR_REC709_TO_XYZ: Matrix3 = Matrix3().set(
        0.4123908, 0.3575843, 0.1804808,
        0.2126390, 0.7151687, 0.0721923,
        0.0193308, 0.1191948, 0.9505322
    )

    /**
     * @brief[zh-cn] XYZ 到线性 Rec.709 变换矩阵
     *
     * @brief[en] XYZ to linear Rec.709 transformation matrix
     */
    public static let XYZ_TO_LINEAR_REC709: Matrix3 = Matrix3().set(
        3.2409699, -1.5373832, -0.4986108,
        -0.9692436, 1.8759675, 0.0415551,
        0.0556301, -0.2039770, 1.0569715
    )

    // ===== Rec.709 常量 =====

    /**
     * @brief[zh-cn] Rec.709 原色色度坐标
     *
     * @brief[en] Rec.709 primary chromaticity coordinates
     */
    public static let REC709_PRIMARIES: Array<Float64> = [0.640, 0.330, 0.300, 0.600, 0.150, 0.060]

    /**
     * @brief[zh-cn] Rec.709 亮度系数
     *
     * @brief[en] Rec.709 luminance coefficients
     */
    public static let REC709_LUMINANCE_COEFFICIENTS: Array<Float64> = [0.2126, 0.7152, 0.0722]

    /**
     * @brief[zh-cn] D65 白点
     *
     * @brief[en] D65 white point
     */
    public static let D65: Array<Float64> = [0.3127, 0.3290]

    /**
     * @brief[zh-cn] 初始化默认颜色空间定义
     * @explain[zh-cn] 注册 sRGB 和线性 sRGB 颜色空间
     *
     * @brief[en] Initialize default color space definitions
     * @explain[en] Register sRGB and linear sRGB color spaces
     */
    public static func initDefaults(): Unit {
        // 线性 sRGB 颜色空间
        spaces.add(LinearSRGBColorSpace, ColorSpaceDefinition(
            REC709_PRIMARIES,
            D65,
            LinearTransfer,
            LINEAR_REC709_TO_XYZ,
            XYZ_TO_LINEAR_REC709,
            REC709_LUMINANCE_COEFFICIENTS,
            workingColorSpaceConfig: ColorSpaceWorkingConfig(SRGBColorSpace),
            outputColorSpaceConfig: ColorSpaceOutputConfig(SRGBColorSpace)
        ))

        // sRGB 颜色空间
        spaces.add(SRGBColorSpace, ColorSpaceDefinition(
            REC709_PRIMARIES,
            D65,
            SRGBTransfer,
            LINEAR_REC709_TO_XYZ,
            XYZ_TO_LINEAR_REC709,
            REC709_LUMINANCE_COEFFICIENTS,
            outputColorSpaceConfig: ColorSpaceOutputConfig(SRGBColorSpace)
        ))
    }

    /**
     * @brief[zh-cn] 注册颜色空间定义
     * @param[zh-cn] colorSpaces 颜色空间名称到定义的映射
     *
     * @brief[en] Register color space definitions
     * @param[en] colorSpaces Mapping from color space name to definition
     */
    public static func define(colorSpaces: HashMap<String, ColorSpaceDefinition>): Unit {
        for ((name, def) in colorSpaces) {
            spaces.add(name, def)
        }
    }

    /**
     * @brief[zh-cn] 比较两个数组是否相等
     *
     * @brief[en] Compare whether two arrays are equal
     */
    private static func arraysEqual(a: Array<Float64>, b: Array<Float64>): Bool {
        if (a.size != b.size) { return false }
        for (i in 0..a.size) {
            if (a[i] != b[i]) { return false }
        }
        return true
    }

    /**
     * @brief[zh-cn] 在颜色空间之间转换颜色
     * @param[zh-cn] color 要转换的颜色
     * sourceColorSpace 源颜色空间
     * targetColorSpace 目标颜色空间
     * @return[zh-cn] 转换后的颜色
     *
     * @brief[en] Convert color between color spaces
     * @param[en] color Color to convert
     * sourceColorSpace Source color space
     * targetColorSpace Target color space
     * @return[en] Converted color
     */
    public static func convert(color: Color, sourceColorSpace: String, targetColorSpace: String): Color {
        if (!enabled || sourceColorSpace == targetColorSpace || sourceColorSpace == "" || targetColorSpace == "") {
            return color
        }

        let srcSpace = spaces.get(sourceColorSpace)
        let dstSpace = spaces.get(targetColorSpace)

        // 如果源颜色空间使用 sRGB 传输函数，先转换到线性空间
        if (let Some(src) <- srcSpace) {
            if (src.transfer == SRGBTransfer) {
                color.r = sRGBToLinear(color.r)
                color.g = sRGBToLinear(color.g)
                color.b = sRGBToLinear(color.b)
            }
        }

        // 如果源和目标颜色空间的原色不同，通过 XYZ 中转
        if (let Some(src) <- srcSpace) {
            if (let Some(dst) <- dstSpace) {
                if (!arraysEqual(src.primaries, dst.primaries)) {
                    color.applyMatrix3(src.toXYZ)
                    color.applyMatrix3(dst.fromXYZ)
                }
            }
        }

        // 如果目标颜色空间使用 sRGB 传输函数，从线性空间转换
        if (let Some(dst) <- dstSpace) {
            if (dst.transfer == SRGBTransfer) {
                color.r = linearToSRGB(color.r)
                color.g = linearToSRGB(color.g)
                color.b = linearToSRGB(color.b)
            }
        }

        return color
    }

    /**
     * @brief[zh-cn] 将颜色从工作颜色空间转换到目标颜色空间
     * @param[zh-cn] color 要转换的颜色
     * targetColorSpace 目标颜色空间
     * @return[zh-cn] 转换后的颜色
     *
     * @brief[en] Convert color from working color space to target color space
     * @param[en] color Color to convert
     * targetColorSpace Target color space
     * @return[en] Converted color
     */
    public static func workingToColorSpace(color: Color, targetColorSpace: String): Color {
        return convert(color, workingColorSpace, targetColorSpace)
    }

    /**
     * @brief[zh-cn] 将颜色从源颜色空间转换到工作颜色空间
     * @param[zh-cn] color 要转换的颜色
     * sourceColorSpace 源颜色空间
     * @return[zh-cn] 转换后的颜色
     *
     * @brief[en] Convert color from source color space to working color space
     * @param[en] color Color to convert
     * sourceColorSpace Source color space
     * @return[en] Converted color
     */
    public static func colorSpaceToWorking(color: Color, sourceColorSpace: String): Color {
        return convert(color, sourceColorSpace, workingColorSpace)
    }

    /**
     * @brief[zh-cn] 获取指定颜色空间的原色色度坐标
     * @param[zh-cn] colorSpace 颜色空间标识
     * @return[zh-cn] 原色色度坐标数组
     *
     * @brief[en] Get primary chromaticity coordinates of the specified color space
     * @param[en] colorSpace Color space identifier
     * @return[en] Primary chromaticity coordinates array
     */
    public static func getPrimaries(colorSpace: String): Array<Float64> {
        if (let Some(space) <- spaces.get(colorSpace)) {
            return space.primaries
        }
        return REC709_PRIMARIES
    }

    /**
     * @brief[zh-cn] 获取指定颜色空间的传输函数
     * @param[zh-cn] colorSpace 颜色空间标识
     * @return[zh-cn] 传输函数标识
     *
     * @brief[en] Get the transfer function of the specified color space
     * @param[en] colorSpace Color space identifier
     * @return[en] Transfer function identifier
     */
    public static func getTransfer(colorSpace: String): String {
        if (colorSpace == NoColorSpace) {
            return LinearTransfer
        }
        if (let Some(space) <- spaces.get(colorSpace)) {
            return space.transfer
        }
        return LinearTransfer
    }

    /**
     * @brief[zh-cn] 获取指定颜色空间的色调映射模式
     * @param[zh-cn] colorSpace 颜色空间标识
     * @return[zh-cn] 色调映射模式（"standard" 或 "extended"）
     *
     * @brief[en] Get the tone mapping mode of the specified color space
     * @param[en] colorSpace Color space identifier
     * @return[en] Tone mapping mode ("standard" or "extended")
     */
    public static func getToneMappingMode(colorSpace: String): String {
        if (let Some(space) <- spaces.get(colorSpace)) {
            if (let Some(config) <- space.outputColorSpaceConfig) {
                return config.toneMappingMode
            }
        }
        return "standard"
    }

    /**
     * @brief[zh-cn] 获取指定颜色空间的亮度系数
     * @param[zh-cn] target 目标向量，用于存储结果
     * colorSpace 颜色空间标识，默认为工作颜色空间
     * @return[zh-cn] 目标向量
     *
     * @brief[en] Get luminance coefficients of the specified color space
     * @param[en] target Target vector for storing the result
     * colorSpace Color space identifier, defaults to working color space
     * @return[en] Target vector
     */
    public static func getLuminanceCoefficients(target: Vector3, colorSpace!: String = workingColorSpace): Vector3 {
        if (let Some(space) <- spaces.get(colorSpace)) {
            let coeffs = space.luminanceCoefficients
            target.x = coeffs[0]
            target.y = coeffs[1]
            target.z = coeffs[2]
        }
        return target
    }

    /**
     * @brief[zh-cn] 获取从源颜色空间到目标颜色空间的变换矩阵
     * @param[zh-cn] targetMatrix 目标矩阵，用于存储结果
     * sourceColorSpace 源颜色空间
     * targetColorSpace 目标颜色空间
     * @return[zh-cn] 目标矩阵
     *
     * @brief[en] Get transformation matrix from source color space to target color space
     * @param[en] targetMatrix Target matrix for storing the result
     * sourceColorSpace Source color space
     * targetColorSpace Target color space
     * @return[en] Target matrix
     */
    public static func getMatrix(targetMatrix: Matrix3, sourceColorSpace: String, targetColorSpace: String): Matrix3 {
        if (let Some(src) <- spaces.get(sourceColorSpace)) {
            if (let Some(dst) <- spaces.get(targetColorSpace)) {
                targetMatrix.copy(src.toXYZ)
                targetMatrix.multiply(dst.fromXYZ)
            }
        }
        return targetMatrix
    }

    /**
     * @brief[zh-cn] 获取指定颜色空间的绘图缓冲区颜色空间
     * @param[zh-cn] colorSpace 颜色空间标识
     * @return[zh-cn] 绘图缓冲区颜色空间
     *
     * @brief[en] Get the drawing buffer color space of the specified color space
     * @param[en] colorSpace Color space identifier
     * @return[en] Drawing buffer color space
     */
    public static func getDrawingBufferColorSpace(colorSpace: String): String {
        if (let Some(space) <- spaces.get(colorSpace)) {
            if (let Some(config) <- space.outputColorSpaceConfig) {
                return config.drawingBufferColorSpace
            }
        }
        return SRGBColorSpace
    }

    /**
     * @brief[zh-cn] 获取指定颜色空间的解包颜色空间
     * @param[zh-cn] colorSpace 颜色空间标识，默认为工作颜色空间
     * @return[zh-cn] 解包颜色空间
     *
     * @brief[en] Get the unpack color space of the specified color space
     * @param[en] colorSpace Color space identifier, defaults to working color space
     * @return[en] Unpack color space
     */
    public static func getUnpackColorSpace(colorSpace!: String = workingColorSpace): String {
        if (let Some(space) <- spaces.get(colorSpace)) {
            if (let Some(config) <- space.workingColorSpaceConfig) {
                return config.unpackColorSpace
            }
        }
        return SRGBColorSpace
    }

    // ===== 传输函数 =====

    /**
     * @brief[zh-cn] sRGB 分量转线性 sRGB
     * @param[zh-cn] c sRGB 颜色分量（0.0 ~ 1.0）
     * @return[zh-cn] 线性 sRGB 颜色分量
     *
     * @brief[en] Convert sRGB component to linear sRGB
     * @param[en] c sRGB color component (0.0 ~ 1.0)
     * @return[en] Linear sRGB color component
     */
    public static func sRGBToLinear(c: Float64): Float64 {
        if (c < 0.04045) { return c * 0.0773993808 }
        return pow(c * 0.9478672986 + 0.0521327014, 2.4)
    }

    /**
     * @brief[zh-cn] 线性 sRGB 分量转 sRGB
     * @param[zh-cn] c 线性 sRGB 颜色分量（0.0 ~ 1.0）
     * @return[zh-cn] sRGB 颜色分量
     *
     * @brief[en] Convert linear sRGB component to sRGB
     * @param[en] c Linear sRGB color component (0.0 ~ 1.0)
     * @return[en] sRGB color component
     */
    public static func linearToSRGB(c: Float64): Float64 {
        if (c < 0.0031308) { return c * 12.92 }
        return 1.055 * pow(c, 0.41666) - 0.055
    }

    // ===== 已弃用方法（兼容） =====

    /**
     * @brief[zh-cn] 已弃用，已重命名为 workingToColorSpace
     *
     * @brief[en] Deprecated, renamed to workingToColorSpace
     *
     * @deprecated 已重命名为 workingToColorSpace
     */
    public static func fromWorkingColorSpace(color: Color, targetColorSpace: String): Color {
        return workingToColorSpace(color, targetColorSpace)
    }

    /**
     * @brief[zh-cn] 已弃用，已重命名为 colorSpaceToWorking
     *
     * @brief[en] Deprecated, renamed to colorSpaceToWorking
     *
     * @deprecated 已重命名为 colorSpaceToWorking
     */
    public static func toWorkingColorSpace(color: Color, sourceColorSpace: String): Color {
        return colorSpaceToWorking(color, sourceColorSpace)
    }

    /**
     * @brief[zh-cn] 静态初始化块，注册默认颜色空间
     *
     * @brief[en] Static initialization block, register default color spaces
     */
    static init() {
        initDefaults()
    }
}
