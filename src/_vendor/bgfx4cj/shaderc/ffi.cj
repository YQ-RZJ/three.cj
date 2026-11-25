/**
 * @file shaderc CFFI 函数声明
 * @brief shaderc C API 的所有 foreign 函数声明
 * @explain 本文件包含 shaderc shader 编译器的 CFFI 绑定。
 *         核心函数 sc_compile 从内存编译 shader 源码，输出 bgfx 二进制 shader。
 * @note 所有输出内存由 API 分配，调用方通过 sc_result_free 释放。
 * @link libs/libshaderc_capi.a
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
foreign func sc_compile(
    _varying_def: CPointer<Unit>,
    _varying_size: UInt32,
    _shader_source: CPointer<Unit>,
    _shader_size: UInt32,
    _options: CPointer<ScOptions>,
    _out_result: CPointer<ScResult>
): Int32

/**
 * @brief 释放 sc_compile 的结果内存
 * @param _result sc_compile 返回的结果指针
 */
foreign func sc_result_free(_result: CPointer<ScResult>): Unit

/**
 * @brief 获取支持的 profile 列表
 * @param _count profile 数量输出指针
 * @return profile 名称字符串数组指针
 */
foreign func sc_get_profiles(_count: CPointer<UInt32>): CPointer<CPointer<UInt8>>

/**
 * @brief 获取版本号
 * @param _major 主版本号输出指针
 * @param _minor 次版本号输出指针
 */
foreign func sc_version(_major: CPointer<Int32>, _minor: CPointer<Int32>): Unit