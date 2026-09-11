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
 * @file[zh-cn] PtrArray 指针底层数组 —— 支持与仓颉 Array 互转的 C 内存数组
 * @brief[zh-cn] 提供底层持有 C 连续内存（CPointer<T>）的数组类型，支持与仓颉 Array 互转
 * @explain[zh-cn] 设计动机：仓颉 Array/ArrayList 的存储由运行时管理，无法直接取得连续内存指针
 * 供 bgfx FFI（bgfx_*_cj）使用。本类型底层持有 LibC.malloc 分配的连续内存
 * （CPointer<T>），提供 get/set/size 等数组常用功能，并支持：
 * - fromArray / 构造器：从仓颉 Array 拷贝数据（一次性上传）
 * - toArray()：把 C 内存数据读回仓颉 Array
 * 供 renderer 高阶 API（setUniform / setTransform / makeRef 等）作为数据载体，
 * 外部无须接触裸指针；内存由内部 AutoFreePtr 自动释放。
 *
 * @file[en] PtrArray  Pointer-backed array: a C-memory array interoperable with Cangjie Array
 * @brief[en] Provides an array type backed by contiguous C memory (CPointer<T>) that can be
 * converted to and from Cangjie Array
 * @explain[en] Motivation: Cangjie Array/ArrayList storage is managed by the runtime and
 * cannot yield a contiguous memory pointer for bgfx FFI (bgfx_*_cj). This type
 * holds contiguous memory allocated by LibC.malloc (CPointer<T>) and offers
 * array-style features such as get/set/size, plus:
 * - fromArray / constructor: copies data from a Cangjie Array (one-shot upload)
 * - toArray(): reads C-memory data back into a Cangjie Array
 * It serves as the data carrier for higher-level renderer APIs (setUniform /
 * setTransform / makeRef etc.) without exposing raw pointers; memory is freed
 * automatically by the internal AutoFreePtr.
 *
 * @package three.utils.memory
 */
package three.utils.memory

// =============================================================================
// PtrArray — 指针底层数组
// =============================================================================

/**
 * @brief[zh-cn] 指针底层数组
 * @explain[zh-cn] 底层持有连续 C 内存（CPointer<T>），提供数组常用功能（size/get/set），
 * 支持与仓颉 Array 互转（构造器 / toArray）。元素类型 T 须满足 CType 约束
 * （UInt8/UInt16/UInt32/Float32/Float64 等基础类型），与 CPointer<T> 一致。
 * 生命周期：内部由 AutoFreePtr 管理，dispose() 手动释放或 GC 回收时自动释放。
 * @param[zh-cn] T 元素类型，须满足 CType 约束
 *
 * @brief[en] Pointer-backed array
 * @explain[en] Backed by contiguous C memory (CPointer<T>), offering array-style features
 * (size/get/set) and conversion to/from Cangjie Array (constructor / toArray).
 * Element type T must satisfy the CType constraint (basic types such as
 * UInt8/UInt16/UInt32/Float32/Float64), matching CPointer<T>.
 * Lifecycle: managed internally by AutoFreePtr; released manually via dispose()
 * or automatically by the GC.
 * @param[en] T Element type, must satisfy the CType constraint
 */
public class PtrArray<T> where T <: CType {
    private var holder: AutoFreePtr<T>
    private var length: Int64

    /**
     * @brief[zh-cn] 构造指定长度的空数组（内存清零）
     * @param[zh-cn] size 元素个数
     *
     * @brief[en] Constructs an empty array of the given length (memory zeroed)
     * @param[en] size Number of elements
     */
    public init(size: Int64) {
        this.holder = AutoFreePtr<T>(unsafe { LibC.malloc<T>(count: size) })
        this.length = size
    }

    /**
     * @brief[zh-cn] 从仓颉 Array 拷贝构造（一次性把数据上传到连续内存）
     * @param[zh-cn] values 源数据
     *
     * @brief[en] Constructs from a Cangjie Array (one-shot data upload to contiguous memory)
     * @param[en] values Source data
     */
    public init(values: Array<T>) {
        this.length = Int64(values.size)
        this.holder = AutoFreePtr<T>(unsafe { LibC.malloc<T>(count: this.length) })
        for (i in 0..values.size) {
            unsafe { this.holder.get().write(i, values[i]) }
        }
    }

    /**
     * @brief[zh-cn] 元素个数
     * @return[zh-cn] 元素个数
     *
     * @brief[en] Number of elements
     * @return[en] Number of elements
     */
    public func size(): Int64 {
        return this.length
    }

    /**
     * @brief[zh-cn] 读取指定下标元素
     * @param[zh-cn] index 下标
     * @return[zh-cn] 元素值
     *
     * @brief[en] Reads the element at the given index
     * @param[en] index Index
     * @return[en] The element value
     */
    public func get(index: Int64): T {
        return unsafe { this.holder.get().read(index) }
    }

    /**
     * @brief[zh-cn] 写入指定下标元素
     * @param[zh-cn] index 下标
     * value 元素值
     *
     * @brief[en] Writes the element at the given index
     * @param[en] index Index
     * value The element value
     */
    public func set(index: Int64, value: T): Unit {
        unsafe { this.holder.get().write(index, value) }
    }

    /**
     * @brief[zh-cn] 获取底层连续内存指针（供 bgfx FFI 使用；调用方不接管所有权）
     * @return[zh-cn] CPointer<T>
     *
     * @brief[en] Returns the underlying contiguous memory pointer (for bgfx FFI; caller does not take ownership)
     * @return[en] CPointer<T>
     */
    public func data(): CPointer<T> {
        return this.holder.get()
    }

    /**
     * @brief[zh-cn] 把 C 内存数据读回仓颉 Array
     * @return[zh-cn] 拷贝出的 Array<T>
     *
     * @brief[en] Reads the C-memory data back into a Cangjie Array
     * @return[en] The copied Array<T>
     */
    public func toArray(): Array<T> {
        let out = Array<T>(this.length, { i => unsafe { this.holder.get().read(i) } })
        return out
    }

    /**
     * @brief[zh-cn] 手动释放底层内存（GC 回收时也会自动释放，此方法用于及时回收）
     *
     * @brief[en] Manually frees the underlying memory (GC will also free it; use this for timely release)
     */
    public func dispose(): Unit {
        this.holder.dispose()
        this.length = 0;
    }
}
