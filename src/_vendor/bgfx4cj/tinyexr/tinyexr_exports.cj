/**
 * @file tinyexr 公共函数包装
 * @brief tinyexr C API 的仓颉安全包装函数
 * @explain 本文件为每个 tinyexr foreign 函数提供 `_cj` 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中，以满足仓颉 FFI 要求。
 * @note 包括 EXR 图像加载、保存、版本解析、头部解析和多部分图像操作。
 */
protected package three._vendor.bgfx4cj.tinyexr

/**
 * @brief 加载 EXR 图像文件
 * @param out_rgba 输出 RGBA 数据指针
 * @param width 宽度
 * @param height 高度
 * @param filename 文件名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func LoadEXR_cj(out_rgba: CPointer<CPointer<Float32>>, width: CPointer<Int32>, height: CPointer<Int32>, filename: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        LoadEXR(out_rgba, width, height, filename, err)
    }
}

/**
 * @brief 加载 EXR 图像指定图层
 * @param out_rgba 输出 RGBA 数据指针
 * @param width 宽度
 * @param height 高度
 * @param filename 文件名
 * @param layer_name 图层名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func LoadEXRWithLayer_cj(out_rgba: CPointer<CPointer<Float32>>, width: CPointer<Int32>, height: CPointer<Int32>, filename: CString, layer_name: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        LoadEXRWithLayer(out_rgba, width, height, filename, layer_name, err)
    }
}

/**
 * @brief 获取 EXR 文件图层列表
 * @param filename 文件名
 * @param layer_names 图层名数组指针
 * @param num_layers 图层数量
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func EXRLayers_cj(filename: CString, layer_names: CPointer<CPointer<CString>>, num_layers: CPointer<Int32>, err: CPointer<CString>): Int32 {
    return unsafe {
        EXRLayers(filename, layer_names, num_layers, err)
    }
}

/**
 * @brief 检查文件是否为 EXR 格式
 * @param filename 文件名
 * @return Int32 返回值描述
 */
public func IsEXR_cj(filename: CString): Int32 {
    return unsafe {
        IsEXR(filename)
    }
}

/**
 * @brief 保存 EXR 图像文件
 * @param data 数据指针
 * @param width 宽度
 * @param height 高度
 * @param components 分量数
 * @param save_as_fp16 是否保存为 FP16
 * @param filename 文件名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func SaveEXR_cj(data: CPointer<Float32>, width: Int32, height: Int32, components: Int32, save_as_fp16: Int32, filename: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        SaveEXR(data, width, height, components, save_as_fp16, filename, err)
    }
}

/**
 * @brief 获取 EXR 图像 mip 等级数量
 * @param exr_image EXR 图像指针
 * @return Int32 返回值描述
 */
public func EXRNumLevels_cj(exr_image: CPointer<EXRImage>): Int32 {
    return unsafe {
        EXRNumLevels(exr_image)
    }
}

/**
 * @brief 初始化 EXR 头部
 * @param exr_header EXR 头部指针
 */
public func InitEXRHeader_cj(exr_header: CPointer<EXRHeader>): Unit {
    unsafe {
        InitEXRHeader(exr_header)
    }
}

/**
 * @brief 设置 EXR 名称属性
 * @param exr_header EXR 头部指针
 * @param name 名称字符串
 */
public func EXRSetNameAttr_cj(exr_header: CPointer<EXRHeader>, name: CString): Unit {
    unsafe {
        EXRSetNameAttr(exr_header, name)
    }
}

/**
 * @brief 初始化 EXR 图像
 * @param exr_image EXR 图像指针
 */
public func InitEXRImage_cj(exr_image: CPointer<EXRImage>): Unit {
    unsafe {
        InitEXRImage(exr_image)
    }
}

/**
 * @brief 释放 EXR 头部
 * @param exr_header EXR 头部指针
 * @return Int32 返回值描述
 */
public func FreeEXRHeader_cj(exr_header: CPointer<EXRHeader>): Int32 {
    return unsafe {
        FreeEXRHeader(exr_header)
    }
}

/**
 * @brief 释放 EXR 图像
 * @param exr_image EXR 图像指针
 * @return Int32 返回值描述
 */
public func FreeEXRImage_cj(exr_image: CPointer<EXRImage>): Int32 {
    return unsafe {
        FreeEXRImage(exr_image)
    }
}

/**
 * @brief 释放 EXR 错误消息
 * @param msg 错误消息
 */
public func FreeEXRErrorMessage_cj(msg: CString): Unit {
    unsafe {
        FreeEXRErrorMessage(msg)
    }
}

/**
 * @brief 从文件解析 EXR 版本
 * @param `version` 版本号
 * @param filename 文件名
 * @return Int32 返回值描述
 */
public func ParseEXRVersionFromFile_cj(`version`: CPointer<EXRVersion>, filename: CString): Int32 {
    return unsafe {
        ParseEXRVersionFromFile(`version`, filename)
    }
}

/**
 * @brief 从内存解析 EXR 版本
 * @param `version` 版本号
 * @param `memory` memory
 * @param `size` size
 * @return Int32 返回值描述
 */
public func ParseEXRVersionFromMemory_cj(`version`: CPointer<EXRVersion>, `memory`: CPointer<UInt8>, `size`: UIntNative): Int32 {
    return unsafe {
        ParseEXRVersionFromMemory(`version`, `memory`, `size`)
    }
}

/**
 * @brief 从文件解析 EXR 头部
 * @param header EXR 头部指针
 * @param `version` 版本号
 * @param filename 文件名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func ParseEXRHeaderFromFile_cj(header: CPointer<EXRHeader>, `version`: CPointer<EXRVersion>, filename: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        ParseEXRHeaderFromFile(header, `version`, filename, err)
    }
}

/**
 * @brief 从内存解析 EXR 头部
 * @param header EXR 头部指针
 * @param `version` 版本号
 * @param `memory` memory
 * @param `size` size
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func ParseEXRHeaderFromMemory_cj(header: CPointer<EXRHeader>, `version`: CPointer<EXRVersion>, `memory`: CPointer<UInt8>, `size`: UIntNative, err: CPointer<CString>): Int32 {
    return unsafe {
        ParseEXRHeaderFromMemory(header, `version`, `memory`, `size`, err)
    }
}

/**
 * @brief 从文件解析多部分 EXR 头部
 * @param headers 头部数组指针
 * @param num_headers 头部数量
 * @param `version` 版本号
 * @param filename 文件名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func ParseEXRMultipartHeaderFromFile_cj(headers: CPointer<CPointer<CPointer<EXRHeader>>>, num_headers: CPointer<Int32>, `version`: CPointer<EXRVersion>, filename: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        ParseEXRMultipartHeaderFromFile(headers, num_headers, `version`, filename, err)
    }
}

/**
 * @brief 从内存解析多部分 EXR 头部
 * @param headers 头部数组指针
 * @param num_headers 头部数量
 * @param `version` 版本号
 * @param `memory` memory
 * @param `size` size
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func ParseEXRMultipartHeaderFromMemory_cj(headers: CPointer<CPointer<CPointer<EXRHeader>>>, num_headers: CPointer<Int32>, `version`: CPointer<EXRVersion>, `memory`: CPointer<UInt8>, `size`: UIntNative, err: CPointer<CString>): Int32 {
    return unsafe {
        ParseEXRMultipartHeaderFromMemory(headers, num_headers, `version`, `memory`, `size`, err)
    }
}

/**
 * @brief 从文件加载 EXR 图像
 * @param image 图像指针
 * @param header EXR 头部指针
 * @param filename 文件名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func LoadEXRImageFromFile_cj(image: CPointer<EXRImage>, header: CPointer<EXRHeader>, filename: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        LoadEXRImageFromFile(image, header, filename, err)
    }
}

/**
 * @brief 从内存加载 EXR 图像
 * @param image 图像指针
 * @param header EXR 头部指针
 * @param `memory` memory
 * @param `size` size
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func LoadEXRImageFromMemory_cj(image: CPointer<EXRImage>, header: CPointer<EXRHeader>, `memory`: CPointer<UInt8>, `size`: UIntNative, err: CPointer<CString>): Int32 {
    return unsafe {
        LoadEXRImageFromMemory(image, header, `memory`, `size`, err)
    }
}

/**
 * @brief 从文件加载多部分 EXR 图像
 * @param images 图像数组指针
 * @param headers 头部数组指针
 * @param num_parts 部分数量
 * @param filename 文件名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func LoadEXRMultipartImageFromFile_cj(images: CPointer<EXRImage>, headers: CPointer<CPointer<EXRHeader>>, num_parts: UInt32, filename: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        LoadEXRMultipartImageFromFile(images, headers, num_parts, filename, err)
    }
}

/**
 * @brief 从内存加载多部分 EXR 图像
 * @param images 图像数组指针
 * @param headers 头部数组指针
 * @param num_parts 部分数量
 * @param `memory` memory
 * @param `size` size
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func LoadEXRMultipartImageFromMemory_cj(images: CPointer<EXRImage>, headers: CPointer<CPointer<EXRHeader>>, num_parts: UInt32, `memory`: CPointer<UInt8>, `size`: UIntNative, err: CPointer<CString>): Int32 {
    return unsafe {
        LoadEXRMultipartImageFromMemory(images, headers, num_parts, `memory`, `size`, err)
    }
}

/**
 * @brief 保存 EXR 图像到文件
 * @param image 图像指针
 * @param exr_header EXR 头部指针
 * @param filename 文件名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func SaveEXRImageToFile_cj(image: CPointer<EXRImage>, exr_header: CPointer<EXRHeader>, filename: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        SaveEXRImageToFile(image, exr_header, filename, err)
    }
}

/**
 * @brief 保存 EXR 图像到内存
 * @param image 图像指针
 * @param exr_header EXR 头部指针
 * @param `memory` memory
 * @param err 错误信息输出
 * @return UIntNative 返回值描述
 */
public func SaveEXRImageToMemory_cj(image: CPointer<EXRImage>, exr_header: CPointer<EXRHeader>, `memory`: CPointer<CPointer<UInt8>>, err: CPointer<CString>): UIntNative {
    return unsafe {
        SaveEXRImageToMemory(image, exr_header, `memory`, err)
    }
}

/**
 * @brief 保存多部分 EXR 图像到文件
 * @param images 图像数组指针
 * @param exr_headers EXR 头部数组指针
 * @param num_parts 部分数量
 * @param filename 文件名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func SaveEXRMultipartImageToFile_cj(images: CPointer<EXRImage>, exr_headers: CPointer<CPointer<EXRHeader>>, num_parts: UInt32, filename: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        SaveEXRMultipartImageToFile(images, exr_headers, num_parts, filename, err)
    }
}

/**
 * @brief 保存多部分 EXR 图像到内存
 * @param images 图像数组指针
 * @param exr_headers EXR 头部数组指针
 * @param num_parts 部分数量
 * @param `memory` memory
 * @param err 错误信息输出
 * @return UIntNative 返回值描述
 */
public func SaveEXRMultipartImageToMemory_cj(images: CPointer<EXRImage>, exr_headers: CPointer<CPointer<EXRHeader>>, num_parts: UInt32, `memory`: CPointer<CPointer<UInt8>>, err: CPointer<CString>): UIntNative {
    return unsafe {
        SaveEXRMultipartImageToMemory(images, exr_headers, num_parts, `memory`, err)
    }
}

/**
 * @brief 加载深度 EXR 图像
 * @param out_image 输出图像指针
 * @param filename 文件名
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func LoadDeepEXR_cj(out_image: CPointer<DeepImage>, filename: CString, err: CPointer<CString>): Int32 {
    return unsafe {
        LoadDeepEXR(out_image, filename, err)
    }
}

/**
 * @brief 从内存加载 EXR 图像
 * @param out_rgba 输出 RGBA 数据指针
 * @param width 宽度
 * @param height 高度
 * @param `memory` memory
 * @param `size` size
 * @param err 错误信息输出
 * @return Int32 返回值描述
 */
public func LoadEXRFromMemory_cj(out_rgba: CPointer<CPointer<Float32>>, width: CPointer<Int32>, height: CPointer<Int32>, `memory`: CPointer<UInt8>, `size`: UIntNative, err: CPointer<CString>): Int32 {
    return unsafe {
        LoadEXRFromMemory(out_rgba, width, height, `memory`, `size`, err)
    }
}