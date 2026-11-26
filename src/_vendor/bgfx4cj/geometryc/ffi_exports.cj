/**
 * @file geometryc 公共函数包装
 * @brief geometryc C API 的仓颉安全包装函数
 * @explain 本文件为每个 geometryc foreign 函数提供 _cj 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中，以满足仓颉 FFI 要求。
 * @note gc_convert 输入数据为内存指针，输出通过 GcResult 结构体返回。
 *       调用方必须在使用完毕后调用 gc_result_free_cj 释放内存。
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
public func gc_convert_cj(
    _input_data: CPointer<Unit>,
    _input_size: UInt32,
    _input_ext: CPointer<UInt8>,
    _base_path: CPointer<UInt8>,
    _config: CPointer<GcConfig>,
    _out_result: CPointer<GcResult>
): Int32 {
    return unsafe {
        gc_convert(_input_data, _input_size, _input_ext, _base_path, _config, _out_result)
    }
}

/**
 * @brief 释放 gc_convert 的结果内存
 * @param _result gc_convert 返回的结果指针
 */
public func gc_result_free_cj(_result: CPointer<GcResult>): Unit {
    unsafe {
        gc_result_free(_result)
    }
}

/**
 * @brief 获取版本号
 * @param _major 主版本号输出指针（可为 NULL）
 * @param _minor 次版本号输出指针（可为 NULL）
 */
public func gc_version_cj(_major: CPointer<Int32>, _minor: CPointer<Int32>): Unit {
    unsafe {
        gc_version(_major, _minor)
    }
}