/**
 * @file[zh-cn] BitArray
 * @brief[zh-cn] 动态二进制位管理器
 * @explain[zh-cn] 底层使用 Array<UInt8> 存储位数据，按需自动扩容。支持 get/set、批量设置、按位与/或/非、相等判断、覆盖判断等操作。
 *
 * @file[en] BitArray
 * @brief[en] Dynamic binary bit manager
 * @explain[en] Uses Array<UInt8> internally to store bit data, with automatic expansion on demand. Supports get/set, batch setting, bitwise AND/OR/NOT, equality comparison, cover check, and more.
 */
package three.core.dsa

import std.math.*
import three.utils.encode.Hash

/**
 * @brief[zh-cn] 动态二进制位管理器
 * @explain[zh-cn] 底层用 Array<UInt8>，每个字节存储 8 个比特位。支持动态扩容，扩容时保留原有数据。实现 Hashable & Equatable<BitArray>：hashCode() 复用 Hash.murmurHash32；==(other) 复用 equal(other) 方法。
 *
 * @brief[en] Dynamic binary bit manager
 * @explain[en] Uses Array<UInt8> internally, with each byte storing 8 bits. Supports dynamic expansion while preserving existing data. Implements Hashable & Equatable<BitArray>: hashCode() reuses Hash.murmurHash32; ==(other) reuses equal(other) method.
 */
public class BitArray <: Hashable & Equatable<BitArray> {
    /** 内部字节数据 */
    private var _data: Array<UInt8>
    /** 实际比特数 */
    private var _length: Int64

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] index 初始比特索引（自动扩容到该索引+1）
     * value 是否将指定位置 1（默认 true）
     *
     * @brief[en] Constructor
     * @param[en] index Initial bit index (automatically expands to this index + 1)
     * value Whether to set the specified position to 1 (defaults to true)
     */
    public init(index: Int64, value!: Bool = true) {
        this._data = Array<UInt8>(0, { _ => 0u8 })
        this._length = 0
        _expansionAndTryCopy(index)
        if (value) {
            set(index, value: true)
        }
    }

    /**
     * @brief[zh-cn] 扩容到指定比特范围，保留原值
     * @param[zh-cn] index 目标比特索引
     * oriData 原始数据（默认当前 _data）
     *
     * @brief[en] Expand to the specified bit range, preserving original values
     * @param[en] index Target bit index
     * oriData Original data (defaults to current _data)
     */
    private func _expansionAndTryCopy(index: Int64, oriData!: Array<UInt8> = Array<UInt8>(0, { _ => 0u8 })): Unit {
        let bitLength = index + 1
        let oriByteLen = if (oriData.size > 0) { oriData.size } else { 0 }
        let selfByteLen = if (_data.size > 0) { _data.size } else { 0 }
        if ((selfByteLen << 3) < bitLength) {
            var byteLength = calcCapacityExpansion(oriByteLen)
            let byteLengthTmp = Int64(ceil(Float64(bitLength) / 8.0))
            if (byteLength < byteLengthTmp) {
                byteLength = byteLengthTmp
            }
            let tmp = Array<UInt8>(byteLength, { _ => 0u8 })
            if (oriData.size > 0) {
                for (i in 0..oriData.size) {
                    tmp[i] = oriData[i]
                }
            }
            _data = tmp
        }
        _length = bitLength
    }

    /**
     * @brief[zh-cn] 固定长度扩容，保留原值
     * @param[zh-cn] bitLength 目标比特长度
     * oriData 原始数据
     *
     * @brief[en] Fixed-length expansion, preserving original values
     * @param[en] bitLength Target bit length
     * oriData Original data
     */
    private func _expansionFixLenAndTryCopy(bitLength: Int64, oriData!: Array<UInt8> = Array<UInt8>(0, { _ => 0u8 })): Unit {
        let selfByteLen = if (_data.size > 0) { _data.size } else { 0 }
        if ((selfByteLen << 3) < bitLength) {
            let byteLength = Int64(ceil(Float64(bitLength) / 8.0))
            let tmp = Array<UInt8>(byteLength, { _ => 0u8 })
            if (oriData.size > 0) {
                for (i in 0..oriData.size) {
                    tmp[i] = oriData[i]
                }
            }
            _data = tmp
        }
        _length = bitLength
    }

    /**
     * @brief[zh-cn] 容量扩容策略，每次翻倍，最小 4
     * @param[zh-cn] oldLen 旧容量
     * @return[zh-cn] 新容量
     *
     * @brief[en] Capacity expansion strategy, doubles each time, minimum 4
     * @param[en] oldLen Old capacity
     * @return[en] New capacity
     */
    private static func calcCapacityExpansion(oldLen: Int64): Int64 {
        if (oldLen <= 0) { return 4 }
        return oldLen * 2
    }

    /**
     * @brief[zh-cn] 获取比特长度
     *
     * @brief[en] Get the bit length
     */
    public prop length: Int64 {
        get() { _length }
    }

    /**
     * @brief[zh-cn] 拷贝副本
     * @return[zh-cn] 新的 BitArray 副本
     *
     * @brief[en] Create a copy
     * @return[en] A new BitArray copy
     */
    public func copy(): BitArray {
        let obj = BitArray(_length - 1, value: false)
        obj._expansionAndTryCopy(_length, oriData: _data)
        // _expansionAndTryCopy 在容量已足够时不进入扩容分支，不会复制 oriData，
        // 因此需要显式复制所有数据字节
        let copyLen = min(_data.size, obj._data.size)
        for (i in 0..copyLen) {
            obj._data[i] = _data[i]
        }
        return obj
    }

    /**
     * @brief[zh-cn] 获取指定位置上的 bit 值
     * @param[zh-cn] index 比特索引
     * @return[zh-cn] true 表示该位为 1
     *
     * @brief[en] Get the bit value at the specified position
     * @param[en] index Bit index
     * @return[en] true if the bit is 1
     */
    public func get(index: Int64): Bool {
        if (index < 0) {
            throw IllegalArgumentException("index out of range: ${index}")
        }
        if (index >= _length) { return false }
        let byteIndex = index / 8
        let bitOffset = index % 8
        return (_data[byteIndex] & (1u8 << UInt8(bitOffset))) != 0u8
    }

    /**
     * @brief[zh-cn] 设置指定位置上的 bit 值
     * @param[zh-cn] index 比特索引
     * value true 置 1，false 清 0
     *
     * @brief[en] Set the bit value at the specified position
     * @param[en] index Bit index
     * value true to set to 1, false to clear to 0
     */
    public func set(index: Int64, value!: Bool = true): Unit {
        if (index < 0) {
            throw IllegalArgumentException("index out of range: ${index}")
        }
        if (index >= _length) { _expansionAndTryCopy(index) }
        let byteIndex = index / 8
        let bitOffset = index % 8
        if (value) {
            _data[byteIndex] |= (1u8 << UInt8(bitOffset))
        } else {
            _data[byteIndex] &= !(1u8 << UInt8(bitOffset))
        }
    }

    /**
     * @brief[zh-cn] 批量设置指定位置上的 bit 值
     * @param[zh-cn] indexs 比特索引数组
     * value true 置 1，false 清 0
     *
     * @brief[en] Batch set bit values at specified positions
     * @param[en] indexs Array of bit indices
     * value true to set to 1, false to clear to 0
     */
    public func setIdxs(indexs: Array<Int64>, value!: Bool = true): Unit {
        if (indexs.size == 0) { return }
        var maxIdx = Int64.Min
        for (idx in indexs) {
            if (idx > maxIdx) { maxIdx = idx }
        }
        if (maxIdx >= _length) { _expansionAndTryCopy(maxIdx) }
        if (value) {
            for (index in indexs) {
                if (index < 0) { return }
                let byteIndex = index / 8
                let bitOffset = index % 8
                _data[byteIndex] |= (1u8 << UInt8(bitOffset))
            }
        } else {
            for (index in indexs) {
                if (index < 0) { return }
                let byteIndex = index / 8
                let bitOffset = index % 8
                _data[byteIndex] &= !(1u8 << UInt8(bitOffset))
            }
        }
    }

    /**
     * @brief[zh-cn] 按位与
     * @param[zh-cn] operand 操作数
     *
     * @brief[en] Bitwise AND
     * @param[en] operand Operand
     */
    public func and(operand: BitArray): Unit {
        let destLen = _data.size
        let srcLen = operand._data.size
        let minLen = min(destLen, srcLen)
        let maxLen = max(destLen, srcLen)
        for (i in 0..minLen) {
            _data[i] = _data[i] & operand._data[i]
        }
        if (_data.size == maxLen) {
            for (i in minLen..maxLen) {
                _data[i] = 0u8
            }
        }
    }

    /**
     * @brief[zh-cn] 按位或
     * @param[zh-cn] operand 操作数
     *
     * @brief[en] Bitwise OR
     * @param[en] operand Operand
     */
    public func or(operand: BitArray): Unit {
        let destLen = _data.size
        let srcLen = operand._data.size
        let minLen = min(destLen, srcLen)
        let maxLen = max(destLen, srcLen)
        for (i in 0..minLen) {
            _data[i] = _data[i] | operand._data[i]
        }
        if (_data.size == minLen) {
            _expansionFixLenAndTryCopy(operand._length, oriData: _data)
            for (i in minLen..maxLen) {
                _data[i] = operand._data[i]
            }
        }
    }

    /**
     * @brief[zh-cn] 按位取反
     *
     * @brief[en] Bitwise NOT
     */
    public func not(): Unit {
        for (i in 0.._data.size) {
            _data[i] = !_data[i]
        }
        let byteIndex = _length / 8
        let bitOffset = _length % 8
        let surplus = 8 - bitOffset
        for (i in 0..surplus) {
            _data[byteIndex] &= !(1u8 << UInt8(bitOffset + i))
        }
    }

    /**
     * @brief[zh-cn] 是否相等
     * @param[zh-cn] operand 操作数
     * @return[zh-cn] true 表示按位相等
     *
     * @brief[en] Check equality
     * @param[en] operand Operand
     * @return[en] true if bitwise equal
     */
    public func equal(operand: BitArray): Bool {
        let destLen = _data.size
        let srcLen = operand._data.size
        let minLen = min(destLen, srcLen)
        let maxLen = max(destLen, srcLen)
        for (i in 0..minLen) {
            if (_data[i] != operand._data[i]) { return false }
        }
        if (_data.size == minLen) {
            for (i in minLen..maxLen) {
                if (operand._data[i] != 0u8) { return false }
            }
        } else {
            for (i in minLen..maxLen) {
                if (_data[i] != 0u8) { return false }
            }
        }
        return true
    }

    /**
     * @brief[zh-cn] 是否覆盖所有值为 1 的比特位
     * @param[zh-cn] operand 操作数
     * @return[zh-cn] true 表示覆盖
     *
     * @brief[en] Check if all bits set to 1 in the operand are also set in this BitArray
     * @param[en] operand Operand
     * @return[en] true if covers
     */
    public func cover(operand: BitArray): Bool {
        let destLen = _data.size
        let srcLen = operand._data.size
        let minLen = min(destLen, srcLen)
        let maxLen = max(destLen, srcLen)
        for (i in 0..minLen) {
            if ((_data[i] & operand._data[i]) != operand._data[i]) { return false }
        }
        if (_data.size == minLen) {
            for (i in minLen..maxLen) {
                if (operand._data[i] != 0u8) { return false }
            }
        }
        return true
    }

    /**
     * @brief[zh-cn] 赋值
     * @param[zh-cn] operand 操作数
     *
     * @brief[en] Assign from another BitArray
     * @param[en] operand Operand
     */
    public func assign(operand: BitArray): Unit {
        if (operand._data.size > 0) {
            _data = Array<UInt8>(operand._data.size, { i => operand._data[i] })
            _length = operand._length
        }
    }

    /**
     * @brief[zh-cn] 清理所有位为 0
     *
     * @brief[en] Clear all bits to 0
     */
    public func clear(): Unit {
        _data = Array<UInt8>(0, { _ => 0u8 })
        _length = 0
    }

    /**
     * @brief[zh-cn] 导出为字节数组
     * @return[zh-cn] 字节数组副本
     *
     * @brief[en] Export as byte array
     * @return[en] Copy of the byte array
     */
    public func toArray(): Array<UInt8> {
        return Array<UInt8>(_data.size, { i => _data[i] })
    }

    /**
     * @brief[zh-cn] 直接公开内部数据
     *
     * @brief[en] Directly expose internal data
     */
    public prop innerData: Array<UInt8> {
        get() { _data }
    }

    /**
     * @brief[zh-cn] 复制内部数据
     * @return[zh-cn] 内部数据的副本
     *
     * @brief[en] Copy internal data
     * @return[en] Copy of internal data
     */
    public func copyInnerData(): Array<UInt8> {
        return Array<UInt8>(_data.size, { i => _data[i] })
    }

    /**
     * @brief[zh-cn] 转为二进制字符串输出
     * @return[zh-cn] 二进制字符串
     *
     * @brief[en] Convert to binary string representation
     * @return[en] Binary string representation
     */
    public func toBinaryString(): String {
        let sb = StringBuilder()
        var len = 0
        for (i in 0.._data.size) {
            let byte = _data[i]
            var bin = ""
            for (j in 0..8) {
                if (len >= _length) { break }
                bin += if ((byte & (1u8 << UInt8(j))) != 0u8) { "1" } else { "0" }
                len += 1
            }
            sb.append(bin)
            if (i < _data.size - 1) { sb.append(" ") }
        }
        return sb.toString()
    }

    // ===== Hashable & Equatable 接口实现 =====

    /**
     * @brief[zh-cn] 计算 Hash 值
     * @explain[zh-cn] _length < 1024 用 FNV-1a 32（实现简单，小数据性能良好）；_length >= 1024 用 MurmurHash3 32（雪崩效应更好，大数据性能更优）。
     * @return[zh-cn] 32 位无符号整数哈希值（用 Int64 容纳）
     *
     * @brief[en] Compute hash value
     * @explain[en] Uses FNV-1a 32 for _length < 1024 (simple implementation, good for small data); uses MurmurHash3 32 for _length >= 1024 (better avalanche effect, better for large data).
     * @return[en] 32-bit unsigned integer hash value (stored in Int64)
     */
    public func hashCode(): Int64 {
        if (_length < 1024) {
            return Hash.fnv1a32(_data)
        } else {
            return Hash.murmurHash32(_data)
        }
    }

    /**
     * @brief[zh-cn] 相等比较
     * @explain[zh-cn] 与 equal 方法语义一致：比较公共字节区域，多余部分必须为 0。
     * @param[zh-cn] other 另一个 BitArray
     * @return[zh-cn] true 表示二者按位相等
     *
     * @brief[en] Equality comparison
     * @explain[en] Same semantics as equal method: compares common byte region, excess must be 0.
     * @param[en] other Another BitArray
     * @return[en] true if bitwise equal
     */
    public operator func ==(other: BitArray): Bool {
        return equal(other)
    }

    /**
     * @brief[zh-cn] 不等比较
     * @param[zh-cn] other 另一个 BitArray
     * @return[zh-cn] true 表示二者不相等
     *
     * @brief[en] Inequality comparison
     * @param[en] other Another BitArray
     * @return[en] true if not equal
     */
    public operator func !=(other: BitArray): Bool {
        return !equal(other)
    }
}
