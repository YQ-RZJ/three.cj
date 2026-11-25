/**
 * @file geometryc CFFI 函数声明
 * @brief geometryc C API 的所有 foreign 函数声明
 * @explain 本文件包含 geometryc 几何体编译器的 CFFI 绑定。
 *         核心函数 gc_convert 从内存解析 glTF/OBJ，输出 bgfx 二进制几何数据。
 * @note 所有输出内存由 API 分配，调用方通过 gc_result_free 释放。
 * @link libs/libgeometryc_capi.a
 */
protected package three._vendor.bgfx4cj.geometryc

// =============================================================================
// Core API
// =============================================================================

/**
 * @brief 从内存解析 glTF/OBJ 并输出 bgfx 二进制几何数据
 * @param _input_data 文件内容数据指针
 * @param _input_size 数据大小（字节）
 * @param _input_ext 文件扩展名："gltf"、"glb" 或 "obj"
 * @param _base_path 用于解析 glTF 外部 .bin 缓冲的基路径（可为 NULL）
 * @param _config 配置指针（NULL = 默认值）
 * @param _out_result 输出结果指针
 * @return 0=成功，负数=错误码
 */
foreign func gc_convert(
    _input_data: CPointer<Unit>,
    _input_size: UInt32,
    _input_ext: CPointer<UInt8>,
    _base_path: CPointer<UInt8>,
    _config: CPointer<GcConfig>,
    _out_result: CPointer<GcResult>
): Int32

/**
 * @brief 释放 gc_convert 的结果内存
 * @param _result gc_convert 返回的结果指针
 */
foreign func gc_result_free(_result: CPointer<GcResult>): Unit

/**
 * @brief 获取版本号
 * @param _major 主版本号输出指针
 * @param _minor 次版本号输出指针
 */
foreign func gc_version(_major: CPointer<Int32>, _minor: CPointer<Int32>): Unit