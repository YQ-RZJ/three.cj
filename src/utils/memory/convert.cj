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
 * @file[zh-cn] convert 整数与指针互转工具
 * @brief[zh-cn] 提供将整数类型转换为指针的工具函数
 * @explain[zh-cn] 目前仓颉仅 64 位运行时，整数类型一般就是 Int64 等。转换时使用
 * AutoFreePtr 包装分配内存，~init 终结器兜底释放，dispose() 显式释放避免等待 GC。
 *
 * @file[en] convert  Integer-to-pointer conversion utilities
 * @brief[en] Provides utilities to convert integer types into pointers
 * @explain[en] Cangjie currently only targets the 64-bit runtime, so integer types are
 * usually Int64 and similar. The conversion allocates memory via AutoFreePtr,
 * with the ~init finalizer as a safety net and dispose() for explicit release
 * without waiting for the GC.
 *
 * @package three.utils.memory
 */
package three.utils.memory

/**
 * @brief[zh-cn] 将整数类型转换为指针
 * @param[zh-cn] int 整数数值（一般取自指针的整数表示）
 * @return[zh-cn] 转换得到的 CPointer<Unit>
 *
 * @brief[en] Converts an integer type into a pointer
 * @param[en] int The integer value (usually the integer representation of a pointer)
 * @return[en] The resulting CPointer<Unit>
 *
 * @note[zh-cn] 内部通过 AutoFreePtr 临时分配内存并拷贝整数值，随后立即释放，
 * 仅返回读取出的指针值本身。
 * @note[en] A temporary AutoFreePtr buffer holds and copies the integer value and is
 * released immediately; only the read-back pointer value is returned.
 */
public func intToCPointer<T>(int:T):CPointer<Unit> where T <: CType{
    unsafe{
        let holder = AutoFreePtr<T>(LibC.malloc<T>())
        holder.get().write(int)
        let retv = CPointer<CPointer<Unit>>(holder.get()).read()
        holder.dispose()
        return retv
    }
}