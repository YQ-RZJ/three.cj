/**
 * @file shaderc 公共函数包装
 * @brief shaderc C API 的仓颉安全包装函数
 * @explain 本文件为每个 shaderc foreign 函数提供 _cj 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中，以满足仓颉 FFI 要求。
 * @note sc_compile 输入为内存指针，输出通过 ScResult 结构体返回。
 *       调用方必须在使用完毕后调用 sc_result_free_cj 释放内存。
 */
protected package three._vendor.bgfx4cj.shaderc

// =============================================================================
// Core API
// =============================================================================

/**
 * @brief 从内存编译 shader
 * @param _varying_def varying.def.sc 内容指针（可为 NULL）
 * @param _varying_size varying 数据大小（字节）
 * @param _shader_source shader 源码指针
 * @param _shader_size shader 源码大小（字节）
 * @param _options 编译选项指针（必须非 NULL）
 * @param _out_result 输出结果指针
 * @return 0=成功，负数=错误码
 */
public func sc_compile_cj(
    _varying_def: CPointer<Unit>,
    _varying_size: UInt32,
    _shader_source: CPointer<Unit>,
    _shader_size: UInt32,
    _options: CPointer<ScOptions>,
    _out_result: CPointer<ScResult>
): Int32 {
    return unsafe {
        sc_compile(_varying_def, _varying_size, _shader_source, _shader_size, _options, _out_result)
    }
}

/**
 * @brief 释放 sc_compile 的结果内存
 * @param _result sc_compile 返回的结果指针
 */
public func sc_result_free_cj(_result: CPointer<ScResult>): Unit {
    unsafe {
        sc_result_free(_result)
    }
}

/**
 * @brief 获取支持的 profile 列表
 * @param _count profile 数量输出指针
 * @return profile 名称字符串数组指针
 */
public func sc_get_profiles_cj(_count: CPointer<UInt32>): CPointer<CPointer<UInt8>> {
    return unsafe {
        sc_get_profiles(_count)
    }
}

/**
 * @brief 获取版本号
 * @param _major 主版本号输出指针（可为 NULL）
 * @param _minor 次版本号输出指针（可为 NULL）
 */
public func sc_version_cj(_major: CPointer<Int32>, _minor: CPointer<Int32>): Unit {
    unsafe {
        sc_version(_major, _minor)
    }
}