/**
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