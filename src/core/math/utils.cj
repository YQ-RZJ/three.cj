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
 * @file[zh-cn] utils
 * @brief[zh-cn] math 工具函数
 * @explain[zh-cn] 从 three.utils 移入的数学运算相关工具函数，与 math 运算相关的工具函数（原 three.utils 的一部分），移入 math 包以便与 Vector3/Matrix4 等基础类型共存，避免 utils 包对 math 的反向依赖。
 *
 * @file[en] utils
 * @brief[en] Math utility functions
 * @explain[en] Math-related utility functions moved from three.utils, placed in the math package to coexist with basic types like Vector3/Matrix4, avoiding reverse dependency from utils package on math.
 */
package three.core.math

import std.collection.*

// =============================================================================
// 数组数学工具 — 对应 Three.js utils.js 中的 arrayMin / arrayMax / arrayNeedsUint32
// =============================================================================

/**
 * @brief[zh-cn] 查找数组最小值，空数组返回 Float64.Infinity
 * @param[zh-cn] array 输入数组
 * @return[zh-cn] 最小值
 *
 * @brief[en] Find the minimum value in an array, returns Float64.Infinity for empty arrays
 * @param[en] array Input array
 * @return[en] Minimum value
 */
public func arrayMin(array: Array<Float64>): Float64 {
    if (array.size == 0) { return Float64.Inf }
    var min = array[0]
    for (i in 1..array.size) {
        if (array[i] < min) { min = array[i] }
    }
    return min
}

/**
 * @brief[zh-cn] 查找数组最大值，空数组返回 -Float64.Infinity
 * @param[zh-cn] array 输入数组
 * @return[zh-cn] 最大值
 *
 * @brief[en] Find the maximum value in an array, returns -Float64.Infinity for empty arrays
 * @param[en] array Input array
 * @return[en] Maximum value
 */
public func arrayMax(array: Array<Float64>): Float64 {
    if (array.size == 0) { return -Float64.Inf }
    var max = array[0]
    for (i in 1..array.size) {
        if (array[i] > max) { max = array[i] }
    }
    return max
}

/**
 * @brief[zh-cn] 检查数组是否包含 >= 65535 的值（需要 Uint32 表示）
 * @param[zh-cn] array 输入数组
 * @return[zh-cn] 是否需要 Uint32
 *
 * @brief[en] Check if array contains values >= 65535 (requires Uint32 representation)
 * @param[en] array Input array
 * @return[en] Whether Uint32 is needed
 */
public func arrayNeedsUint32(array: Array<Int64>): Bool {
    var i = array.size - 1
    while (i >= 0) {
        if (array[i] >= 65535) { return true }
        i -= 1
    }
    return false
}

/**
 * @brief[zh-cn] 判断对象是否为 TypedArray（仓颉中检查是否为 Array 类型）
 * @explain[zh-cn] Three.js 中用于区分普通数组和类型化数组
 * @param[zh-cn] array 要检查的对象
 * @return[zh-cn] 是否为 TypedArray
 *
 * @brief[en] Check if an object is a TypedArray (in Cangjie, checks if it is an Array type)
 * @explain[en] In Three.js, used to distinguish between regular arrays and typed arrays
 * @param[en] array Object to check
 * @return[en] Whether the object is a TypedArray
 */
public func isTypedArray(array: Any): Bool {
    // 仓颉中 Array<Float64>/Array<Float32>/Array<Int64> 等都是 Array 类型
    // 此处通过 match 检查类型
    match (array) {
        case _: Array<Float64> => return true
        case _: Array<Float32> => return true
        case _: Array<Int64> => return true
        case _: Array<Int32> => return true
        case _: Array<Int16> => return true
        case _: Array<Int8> => return true
        case _: Array<UInt64> => return true
        case _: Array<UInt32> => return true
        case _: Array<UInt16> => return true
        case _: Array<UInt8> => return true
        case _ => return false
    }
}

// =============================================================================
// 投影矩阵工具函数 — 对应 Three.js utils.js 中的投影矩阵转换函数
// =============================================================================

/**
 * @brief[zh-cn] 将投影矩阵从 NDC 范围 [-1, 1] 转换为 [0, 1]
 * @explain[zh-cn] 此转换在使用深度纹理或期望深度值在 [0, 1] 范围内的渲染目标时常用，而非标准 OpenGL NDC 范围 [-1, 1]。此函数会原地修改投影矩阵。
 * @param[zh-cn] projectionMatrix 投影矩阵（原地修改）
 *
 * @brief[en] Convert projection matrix from NDC range [-1, 1] to [0, 1]
 * @explain[en] This conversion is commonly used when using depth textures or render targets that expect depth values in [0, 1] range, rather than the standard OpenGL NDC range [-1, 1]. This function modifies the projection matrix in place.
 * @param[en] projectionMatrix Projection matrix (modified in place)
 */
public func toNormalizedProjectionMatrix(projectionMatrix: Matrix4): Unit {
    let m = projectionMatrix.elements
    // 将 [-1, 1] 转换为 [0, 1] 投影矩阵
    m[2] = 0.5 * m[2] + 0.5 * m[3]
    m[6] = 0.5 * m[6] + 0.5 * m[7]
    m[10] = 0.5 * m[10] + 0.5 * m[11]
    m[14] = 0.5 * m[14] + 0.5 * m[15]
}

/**
 * @brief[zh-cn] 反转投影矩阵的深度范围
 * @explain[zh-cn] 此函数反转投影矩阵的深度映射，用于 reversed-Z 深度缓冲技术以提高深度精度。对于透视矩阵（m[11] === -1），深度映射带偏移反转；对于正交矩阵，使用更简单的反转。此函数会原地修改投影矩阵。
 * @param[zh-cn] projectionMatrix 投影矩阵（原地修改）
 *
 * @brief[en] Reverse the depth range of the projection matrix
 * @explain[en] This function reverses the depth mapping of the projection matrix, used for reversed-Z depth buffer technique to improve depth precision. For perspective matrices (m[11] === -1), depth mapping is reversed with offset; for orthographic matrices, a simpler reversal is used. This function modifies the projection matrix in place.
 * @param[en] projectionMatrix Projection matrix (modified in place)
 */
public func toReversedProjectionMatrix(projectionMatrix: Matrix4): Unit {
    let m = projectionMatrix.elements
    let isPerspectiveMatrix = m[11] == -1.0
    // 反转 [0, 1] 投影矩阵
    if (isPerspectiveMatrix) {
        m[10] = -m[10] - 1.0
        m[14] = -m[14]
    } else {
        m[10] = -m[10]
        m[14] = -m[14] + 1.0
    }
}

/**
 * @brief[zh-cn] 反转深度函数映射表
 * @explain[zh-cn] 当使用 reversed-Z 深度缓冲时，用于选择正确的深度函数。键为原始深度函数常量，值为反转后的深度函数常量。
 * 映射关系：NeverDepth(0)->AlwaysDepth(1), LessDepth(2)->GreaterDepth(6), EqualDepth(4)->NotEqualDepth(7), LessEqualDepth(3)->GreaterEqualDepth(5), AlwaysDepth(1)->NeverDepth(0), GreaterDepth(6)->LessDepth(2), NotEqualDepth(7)->EqualDepth(4), GreaterEqualDepth(5)->LessEqualDepth(3)
 *
 * @brief[en] Reversed depth function mapping table
 * @explain[en] Used to select the correct depth function when using reversed-Z depth buffer. Keys are original depth function constants, values are reversed depth function constants.
 * Mapping: NeverDepth(0)->AlwaysDepth(1), LessDepth(2)->GreaterDepth(6), EqualDepth(4)->NotEqualDepth(7), LessEqualDepth(3)->GreaterEqualDepth(5), AlwaysDepth(1)->NeverDepth(0), GreaterDepth(6)->LessDepth(2), NotEqualDepth(7)->EqualDepth(4), GreaterEqualDepth(5)->LessEqualDepth(3)
 */
public class ReversedDepthFuncs {
    private static var _map: HashMap<Int64, Int64> = HashMap<Int64, Int64>()

    private init() {}

    public static func get(key: Int64): Option<Int64> {
        if (_map.size == 0) { _initMap() }
        return _map.get(key)
    }

    private static func _initMap(): Unit {
        _map.add(0, 1)   // NeverDepth -> AlwaysDepth
        _map.add(2, 6)   // LessDepth -> GreaterDepth
        _map.add(4, 7)   // EqualDepth -> NotEqualDepth
        _map.add(3, 5)   // LessEqualDepth -> GreaterEqualDepth
        _map.add(1, 0)   // AlwaysDepth -> NeverDepth
        _map.add(6, 2)   // GreaterDepth -> LessDepth
        _map.add(7, 4)   // NotEqualDepth -> EqualDepth
        _map.add(5, 3)   // GreaterEqualDepth -> LessEqualDepth
    }
}
