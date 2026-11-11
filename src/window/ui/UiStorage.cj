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
 * @file[zh-cn] UiStorage.cj — ImGui 持久化存储
 * @brief[zh-cn] 封装 ImGuiStorage，提供类型安全的 key-value 读写接口
 * @explain[zh-cn] 用法示例：
 *   let storage = UiStorage.getWindowStorage()
 *   storage.setInt("myKey", 42)
 *   let val = storage.getInt("myKey", 0)  // 默认值 0
 *
 * @file[en] UiStorage.cj — ImGui Persistent Storage
 * @brief[en] Wraps ImGuiStorage with type-safe key-value read/write interface
 * @explain[en] Usage example:
 *   let storage = UiStorage.getWindowStorage()
 *   storage.setInt("myKey", 42)
 *   let val = storage.getInt("myKey", 0)  // default 0
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.utils.memory.PtrArray
import three.utils.memory.VoidPtr

// =============================================================================
// UiStorage — ImGui 持久化存储
// ImGui Persistent Storage
// =============================================================================

/**
 * @brief[zh-cn] ImGui 持久化 key-value 存储
 * @explain[zh-cn] 与 ImGui INI 文件自动关联。Int/Bool/Float 值按 key 存储，
 *         支持引用返回（修改引用值会在下一帧自动保存）。
 *
 * @brief[en] ImGui persistent key-value storage
 * @explain[en] Automatically associated with ImGui INI files. Int/Bool/Float values stored by key,
 *         supports reference return (modifying reference values auto-saves on next frame).
 */
public class UiStorage {
    private var _storage: CPointer<Unit>

    /**
     * @brief[zh-cn] 以底层 ImGuiStorage 指针构造
     * @param[zh-cn] storagePtr 底层 ImGuiStorage 指针封装
     *
     * @brief[en] Constructs from the underlying ImGuiStorage pointer
     * @param[en] storagePtr Wrapper of the underlying ImGuiStorage pointer
     */
    public init(storagePtr: VoidPtr) { this._storage = storagePtr.value }

    /**
     * @brief[zh-cn] 获取当前窗口的 ImGuiStorage
     * @return[zh-cn] 当前窗口关联的存储对象
     *
     * @brief[en] Gets the current window's ImGuiStorage
     * @return[en] Storage object associated with the current window
     */
    public static func getWindowStorage(): UiStorage {
        return UiStorage(Box(igGetStateStorage_cj()))
    }

    /**
     * @brief[zh-cn] 设置当前窗口的 ImGuiStorage
     * @param[zh-cn] storage 要设置的存储对象
     *
     * @brief[en] Sets the current window's ImGuiStorage
     * @param[en] storage Storage object to set
     */
    public static func setWindowStorage(storage: UiStorage): Unit {
        igSetStateStorage_cj(storage._storage)
    }

    /**
     * @brief[zh-cn] 清空所有数据
     *
     * @brief[en] Clears all data
     */
    public func clear(): Unit {
        if (!this._storage.isNull()) { ImGuiStorage_Clear_cj(this._storage) }
    }

    // ===== Int =====

    /**
     * @brief[zh-cn] 获取整数值
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] defaultVal 默认值
     * @return[zh-cn] 存储值；不存在时返回默认值
     *
     * @brief[en] Gets an integer value
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] defaultVal Default value
     * @return[en] Stored value; returns default if not found
     */
    public func getInt(key: UInt32, defaultVal!: Int32 = 0): Int32 {
        if (this._storage.isNull()) { return defaultVal }
        return ImGuiStorage_GetInt_cj(this._storage, key, defaultVal)
    }

    /**
     * @brief[zh-cn] 设置整数值
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] val 要存储的整数值
     *
     * @brief[en] Sets an integer value
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] val Integer value to store
     */
    public func setInt(key: UInt32, val: Int32): Unit {
        if (!this._storage.isNull()) { ImGuiStorage_SetInt_cj(this._storage, key, val) }
    }

    // ===== Bool =====

    /**
     * @brief[zh-cn] 获取布尔值
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] defaultVal 默认值，默认 false
     * @return[zh-cn] 存储值；不存在时返回默认值
     *
     * @brief[en] Gets a boolean value
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] defaultVal Default value, defaults to false
     * @return[en] Stored value; returns default if not found
     */
    public func getBool(key: UInt32, defaultVal!: Bool = false): Bool {
        if (this._storage.isNull()) { return defaultVal }
        return ImGuiStorage_GetBool_cj(this._storage, key, if (defaultVal) { 1 } else { 0 }) != 0
    }

    /**
     * @brief[zh-cn] 设置布尔值
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] val 要存储的布尔值
     *
     * @brief[en] Sets a boolean value
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] val Boolean value to store
     */
    public func setBool(key: UInt32, val: Bool): Unit {
        if (!this._storage.isNull()) { ImGuiStorage_SetBool_cj(this._storage, key, if (val) { 1 } else { 0 }) }
    }

    // ===== Float =====

    /**
     * @brief[zh-cn] 获取浮点值
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] defaultVal 默认值，默认 0.0
     * @return[zh-cn] 存储值；不存在时返回默认值
     *
     * @brief[en] Gets a float value
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] defaultVal Default value, defaults to 0.0
     * @return[en] Stored value; returns default if not found
     */
    public func getFloat(key: UInt32, defaultVal!: Float32 = 0.0f32): Float32 {
        if (this._storage.isNull()) { return defaultVal }
        return ImGuiStorage_GetFloat_cj(this._storage, key, defaultVal)
    }

    /**
     * @brief[zh-cn] 设置浮点值
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] val 要存储的浮点值
     *
     * @brief[en] Sets a float value
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] val Float value to store
     */
    public func setFloat(key: UInt32, val: Float32): Unit {
        if (!this._storage.isNull()) { ImGuiStorage_SetFloat_cj(this._storage, key, val) }
    }

    // ===== VoidPtr =====

    /**
     * @brief[zh-cn] 获取 void* 值
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @return[zh-cn] 存储的 void* 指针；不存在时返回空指针
     *
     * @brief[en] Gets a void* value
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @return[en] Stored void* pointer; null pointer if not found
     */
    public func getVoidPtr(key: UInt32): VoidPtr {
        if (this._storage.isNull()) { return Box(CPointer<Unit>()) }
        return Box(ImGuiStorage_GetVoidPtr_cj(this._storage, key))
    }

    /**
     * @brief[zh-cn] 设置 void* 值
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] val 要存储的 void* 指针
     *
     * @brief[en] Sets a void* value
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] val void* pointer to store
     */
    public func setVoidPtr(key: UInt32, val: VoidPtr): Unit {
        if (!this._storage.isNull()) { ImGuiStorage_SetVoidPtr_cj(this._storage, key, val.value) }
    }

    // ===== Ref（引用——修改引用值自动持久化） =====
    // ===== Ref (reference — modifying ref value auto-persists) =====

    /**
     * @brief[zh-cn] 获取整数引用（不存在则插入默认值）
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] defaultVal 默认值，默认 0
     * @return[zh-cn] 指向存储位置的引用数组（修改引用值会自动持久化）
     *
     * @brief[en] Gets an integer reference (inserts default if not found)
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] defaultVal Default value, defaults to 0
     * @return[en] Reference array to the stored location (modifying it auto-persists)
     */
    public func getIntRef(key: UInt32, defaultVal!: Int32 = 0): PtrArray<Int32> {
        if (this._storage.isNull()) { return PtrArray<Int32>(CPointer<Int32>()) }
        return PtrArray<Int32>(ImGuiStorage_GetIntRef_cj(this._storage, key, defaultVal))
    }

    /**
     * @brief[zh-cn] 获取布尔引用
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] defaultVal 默认值，默认 false
     * @return[zh-cn] 指向存储位置的引用数组（修改引用值会自动持久化）
     *
     * @brief[en] Gets a boolean reference
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] defaultVal Default value, defaults to false
     * @return[en] Reference array to the stored location (modifying it auto-persists)
     */
    public func getBoolRef(key: UInt32, defaultVal!: Bool = false): PtrArray<Int32> {
        if (this._storage.isNull()) { return PtrArray<Int32>(CPointer<Int32>()) }
        return PtrArray<Int32>(ImGuiStorage_GetBoolRef_cj(this._storage, key, if (defaultVal) { 1 } else { 0 }))
    }

    /**
     * @brief[zh-cn] 获取浮点引用
     * @param[zh-cn] key 数据键（ImGui 内部用 ID 哈希）
     * @param[zh-cn] defaultVal 默认值，默认 0.0
     * @return[zh-cn] 指向存储位置的引用数组（修改引用值会自动持久化）
     *
     * @brief[en] Gets a float reference
     * @param[en] key Data key (ImGui uses ID hash internally)
     * @param[en] defaultVal Default value, defaults to 0.0
     * @return[en] Reference array to the stored location (modifying it auto-persists)
     */
    public func getFloatRef(key: UInt32, defaultVal!: Float32 = 0.0f32): PtrArray<Float32> {
        if (this._storage.isNull()) { return PtrArray<Float32>(CPointer<Float32>()) }
        return PtrArray<Float32>(ImGuiStorage_GetFloatRef_cj(this._storage, key, defaultVal))
    }

    // ===== 批量操作 =====
    // ===== Batch Operations =====

    /**
     * @brief[zh-cn] 将所有整数值设为同一值
     * @param[zh-cn] val 要设置的值
     *
     * @brief[en] Sets all integer values to the same value
     * @param[en] val Value to set
     */
    public func setAllInt(val: Int32): Unit {
        if (!this._storage.isNull()) { ImGuiStorage_SetAllInt_cj(this._storage, val) }
    }

    /**
     * @brief[zh-cn] 按 key 排序（优化查找性能）
     *
     * @brief[en] Sorts by key (optimizes lookup performance)
     */
    public func buildSortByKey(): Unit {
        if (!this._storage.isNull()) { ImGuiStorage_BuildSortByKey_cj(this._storage) }
    }
}
