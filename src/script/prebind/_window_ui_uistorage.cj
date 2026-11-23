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
 * @file[zh-cn] window_ui_uistorage UiStorage.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiStorage 绑定为 Lua 类型 three.window.ui.UiStorage
 * @explain[zh-cn] 覆盖：静态 getWindowStorage()/setWindowStorage(storage)，实例方法
 * clear、getInt/setInt、getBool/setBool、getFloat/setFloat、getIntRef/getBoolRef/getFloatRef、
 * setAllInt、buildSortByKey。适配约定：
 * - 脚本侧不提供 constructor（源码构造参数为 VoidPtr），实例只能经 getWindowStorage() 获取；
 * - key 为 UInt32，按 UInt32(数字 & 0xFFFFFFFF) 回写；Int32 以 Int64(...) 返回、Int32(...) 回写；
 *   Float32 以 Float64(...) 返回、Float32(...) 回写；Bool 以 Lua 布尔返回、prebindBool 读取；
 * - getIntRef/getBoolRef 返回 PtrArray<Int32>，经 prebindRegister 注册为
 *   three.utils.memory.PtrArrayInt32；getFloatRef 返回 PtrArray<Float32>，注册为
 *   three.utils.memory.PtrArrayFloat32。
 * 跳过成员及原因：
 * - getVoidPtr()/setVoidPtr() 以 VoidPtr 收发裸指针，不属于脚本接口，跳过；
 * - private 字段 _storage 不暴露。
 *
 * @file[en] window_ui_uistorage  Lua binding of UiStorage.cj (three.script.prebind)
 * @brief[en] Binds three.window.ui.UiStorage as the Lua type three.window.ui.UiStorage
 * @explain[en] Coverage: static getWindowStorage()/setWindowStorage(storage); instance methods
 * clear, getInt/setInt, getBool/setBool, getFloat/setFloat, getIntRef/getBoolRef/getFloatRef,
 * setAllInt and buildSortByKey. Conventions:
 * - No constructor is exposed (the source constructor takes a VoidPtr); instances come from
 *   getWindowStorage() only;
 * - Keys are UInt32 written back as UInt32(number & 0xFFFFFFFF); Int32 is returned as Int64(...) and
 *   written back with Int32(...); Float32 is returned as Float64(...) and written back with
 *   Float32(...); Bool is returned as a Lua boolean and read through prebindBool;
 * - getIntRef/getBoolRef return PtrArray<Int32> and are registered as
 *   three.utils.memory.PtrArrayInt32; getFloatRef returns PtrArray<Float32> and is registered as
 *   three.utils.memory.PtrArrayFloat32.
 * Skipped members and reasons:
 * - getVoidPtr()/setVoidPtr() exchange raw pointers as VoidPtr and are not a script API — skipped;
 * - The private field _storage is not exposed.
 */
package three.script.prebind

import three.utils.memory.PtrArray
import three.window.ui.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取 UInt32 形式的存储 key（越界取 0，超出 32 位部分截断）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @return[zh-cn] key 数值
 *
 * @brief[en] Reads a storage key as UInt32 (0 when out of range; high bits beyond 32 are truncated)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @return[en] The key value
 */
private func _prebindUisKey(args: Array<LuaValue>, idx: Int64): UInt32 {
    return UInt32(prebindInt(args, idx) & 0xFFFFFFFF)
}

/**
 * @brief[zh-cn] 安装 UiStorage 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiStorage）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiStorage
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiStorage)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiStorage(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiStorage")

    // ===== 静态读写当前窗口存储 / Static current-window storage access =====
    b.staticMethod("getWindowStorage") {
        _ => [prebindRegister(UiStorage.getWindowStorage(), "three.window.ui.UiStorage")]
    }
    b.staticMethod("setWindowStorage") {
        args =>
            UiStorage.setWindowStorage(prebindAs<UiStorage>(args, 0))
            []
    }

    b.method("clear") {
        ref, _ =>
            ref.cast<UiStorage>().clear()
            []
    }

    // ===== Int =====
    b.method("getInt") {
        ref, args => [LuaValue.of(
            Int64(ref.cast<UiStorage>().getInt(_prebindUisKey(args, 0), defaultVal: Int32(prebindInt(args, 1)))))]
    }
    b.method("setInt") {
        ref, args =>
            ref.cast<UiStorage>().setInt(_prebindUisKey(args, 0), Int32(prebindInt(args, 1)))
            []
    }

    // ===== Bool =====
    b.method("getBool") {
        ref, args => [LuaValue.of(ref.cast<UiStorage>().getBool(_prebindUisKey(args, 0), defaultVal: prebindBool(args, 1)))]
    }
    b.method("setBool") {
        ref, args =>
            ref.cast<UiStorage>().setBool(_prebindUisKey(args, 0), prebindBool(args, 1))
            []
    }

    // ===== Float =====
    b.method("getFloat") {
        ref, args => [LuaValue.of(
            Float64(ref
                .cast<UiStorage>()
                .getFloat(_prebindUisKey(args, 0), defaultVal: Float32(prebindNum(args, 1, default: 0.0)))))]
    }
    b.method("setFloat") {
        ref, args =>
            ref.cast<UiStorage>().setFloat(_prebindUisKey(args, 0), Float32(prebindNum(args, 1, default: 0.0)))
            []
    }

    // ===== Ref（引用，修改后自动持久化） / Ref (auto-persisted on modify) =====
    b.method("getIntRef") {
        ref, args => [prebindRegister(
            ref.cast<UiStorage>().getIntRef(_prebindUisKey(args, 0), defaultVal: Int32(prebindInt(args, 1))),
            "three.utils.memory.PtrArrayInt32")]
    }
    b.method("getBoolRef") {
        ref, args => [prebindRegister(
            ref.cast<UiStorage>().getBoolRef(_prebindUisKey(args, 0), defaultVal: prebindBool(args, 1)),
            "three.utils.memory.PtrArrayInt32")]
    }
    b.method("getFloatRef") {
        ref, args => [prebindRegister(
            ref
                .cast<UiStorage>()
                .getFloatRef(_prebindUisKey(args, 0), defaultVal: Float32(prebindNum(args, 1, default: 0.0))),
            "three.utils.memory.PtrArrayFloat32")]
    }

    // ===== 批量操作 / Batch operations =====
    b.method("setAllInt") {
        ref, args =>
            ref.cast<UiStorage>().setAllInt(Int32(prebindInt(args, 0)))
            []
    }
    b.method("buildSortByKey") {
        ref, _ =>
            ref.cast<UiStorage>().buildSortByKey()
            []
    }
    b.install(vm)
}
