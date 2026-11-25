/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected package three._vendor.fastjson.stream

import std.collection.*
import std.collection.concurrent.ConcurrentHashMap
public import std.io.*

public interface JsonStreamDeserializable<T> {
    static func fromJson(r: JsonStreamReader): T
    static func fromJson(str: String): T {
        fromJson(JsonStreamReader(ByteBuffer(str.toArray())))
    }
}

extend Bool <: JsonStreamDeserializable<Bool> {
    public static func fromJson(r: JsonStreamReader): Bool {
        if (r.peeked == PEEK_STATE_TRUE) {
            return r.readTrue()
        } else if (r.peeked == PEEK_STATE_FALSE) {
            return r.readFalse()
        }
        return r.readBool()
    }
}

extend Rune <: JsonStreamDeserializable<Rune> {
    public static func fromJson(r: JsonStreamReader): Rune {
        let charStr: String = r.readString()
        if (charStr.toRuneArray().size != 1) {
            throw IllegalStateException("This data is not Rune.")
        }
        return Rune(charStr[0])
    }
}

extend<T> Option<T> <: JsonStreamDeserializable<Option<T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): Option<T> {
        if (r.peeked == PEEK_STATE_NULL || r.nextNonJsonWhitespace() == b'n') {
            r.readNull()
            return None
        }
        return T.fromJson(r)
    }
}

const MAXVAL_I64: UInt64 = 0x7FFF_FFFF_FFFF_FFFF
const MAXVAL_UI64: UInt64 = 0xFFFF_FFFF_FFFF_FFFF
const MAXABSVAL_I64: UInt64 = MAXVAL_I64 + 1
const MAXVAL_I32: Int32 = 0x7FFF_FFFF
const MINVAL_I32: Int32 = -0x8000_0000
const MAXVAL_I16: Int16 = 0x7FFF
const MINVAL_I16: Int16 = -0x8000
const MAXVAL_I8: Int8 = 0x7F
const MINVAL_I8: Int8 = -0x80
const MAXVAL_UI32: UInt32 = 0xFFFF_FFFF
const MAXVAL_UI16: UInt16 = 0xFFFF
const MAXVAL_UI8: UInt8 = 0xFF
let isNative64 = UInt64(!UIntNative(0)) == MAXVAL_UI64

extend Int64 <: JsonStreamDeserializable<Int64> {
    public static func fromJson(r: JsonStreamReader): Int64 {
        let (res, overflow) = r.readInt()
        if (overflow) {
            throw OverflowException("The next number is out of range for Int64.")
        }
        return res
    }
}

extend Int32 <: JsonStreamDeserializable<Int32> {
    public static func fromJson(r: JsonStreamReader): Int32 {
        let (res, overflow) = r.readInt()
        if (overflow || res > Int64(MAXVAL_I32) || res < Int64(MINVAL_I32)) {
            throw OverflowException("The next number is out of range for Int32.")
        }
        return Int32(res)
    }
}

extend Int16 <: JsonStreamDeserializable<Int16> {
    public static func fromJson(r: JsonStreamReader): Int16 {
        let (res, overflow) = r.readInt()
        if (overflow || res > Int64(MAXVAL_I16) || res < Int64(MINVAL_I16)) {
            throw OverflowException("The next number is out of range for Int16.")
        }
        return Int16(res)
    }
}

extend Int8 <: JsonStreamDeserializable<Int8> {
    public static func fromJson(r: JsonStreamReader): Int8 {
        let (res, overflow) = r.readInt()
        if (overflow || res > Int64(MAXVAL_I8) || res < Int64(MINVAL_I8)) {
            throw OverflowException("The next number is out of range for Int8.")
        }
        return Int8(res)
    }
}

extend IntNative <: JsonStreamDeserializable<IntNative> {
    public static func fromJson(r: JsonStreamReader): IntNative {
        let (res, overflow) = r.readInt()
        if (overflow || (!isNative64 && (res > Int64(MAXVAL_I32) || res < Int64(MINVAL_I32)))) {
            throw OverflowException("The next number is out of range for IntNative.")
        }
        return IntNative(res)
    }
}

extend UInt64 <: JsonStreamDeserializable<UInt64> {
    public static func fromJson(r: JsonStreamReader): UInt64 {
        let (res, overflow) = r.readUInt()
        if (overflow) {
            throw OverflowException("The next number is out of range for UInt64.")
        }
        return res
    }
}

extend UInt32 <: JsonStreamDeserializable<UInt32> {
    public static func fromJson(r: JsonStreamReader): UInt32 {
        let (res, overflow) = r.readUInt()
        if (overflow || res > UInt64(MAXVAL_UI32)) {
            throw OverflowException("The next number is out of range for UInt32.")
        }
        return UInt32(res)
    }
}

extend UInt16 <: JsonStreamDeserializable<UInt16> {
    public static func fromJson(r: JsonStreamReader): UInt16 {
        let (res, overflow) = r.readUInt()
        if (overflow || res > UInt64(MAXVAL_UI16)) {
            throw OverflowException("The next number is out of range for UInt16.")
        }
        return UInt16(res)
    }
}

extend UInt8 <: JsonStreamDeserializable<UInt8> {
    public static func fromJson(r: JsonStreamReader): UInt8 {
        let (res, overflow) = r.readUInt()
        if (overflow || res > UInt64(MAXVAL_UI8)) {
            throw OverflowException("The next number is out of range for UInt8.")
        }
        return UInt8(res)
    }
}

extend UIntNative <: JsonStreamDeserializable<UIntNative> {
    public static func fromJson(r: JsonStreamReader): UIntNative {
        let (res, overflow) = r.readUInt()
        if (overflow || (!isNative64 && (res > UInt64(MAXVAL_UI32)))) {
            throw OverflowException("The next number is out of range for UIntNative.")
        }
        return UIntNative(res)
    }
}

extend Float64 <: JsonStreamDeserializable<Float64> {
    public static func fromJson(r: JsonStreamReader): Float64 {
        r.readFloat()
    }
}

extend Float32 <: JsonStreamDeserializable<Float32> {
    public static func fromJson(r: JsonStreamReader): Float32 {
        return Float32(r.readFloat())
    }
}

extend Float16 <: JsonStreamDeserializable<Float16> {
    public static func fromJson(r: JsonStreamReader): Float16 {
        return Float16(r.readFloat())
    }
}

extend<T> Array<T> <: JsonStreamDeserializable<Array<T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): Array<T> {
        return ArrayList<T>.fromJson(r).toArray()
    }
}

extend<T> ArrayList<T> <: JsonStreamDeserializable<ArrayList<T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): ArrayList<T> {
        let result = ArrayList<T>()
        r.startArray()
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndArray) {
                result.add(T.fromJson(r))
                r.afterRead()
            } else {
                break
            }
        }
        r.endArray()
        return result
    }
}

extend<T> HashSet<T> <: JsonStreamDeserializable<HashSet<T>>  where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): HashSet<T> {
        let result = HashSet<T>()
        r.startArray()
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndArray) {
                result.add(T.fromJson(r))
                r.afterRead()
            } else {
                break
            }
        }
        r.endArray()
        return result
    }
}


extend<K, V> HashMap<K, V> <: JsonStreamDeserializable<HashMap<K, V>> where K <:JsonStreamDeserializable<K>,  V <: JsonStreamDeserializable<V> {
    public static func fromJson(r: JsonStreamReader): HashMap<K, V> {
        let result =  HashMap<K, V>()
        r.startObject()
        var key: K
        var value: V
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndObject) {
                key = (r.readName() as K).getOrThrow()
                value = V.fromJson(r)
                r.afterRead()
                result.add(key, value)
            } else {
                break
            }
        }
        r.endObject()
        return result
    }
}


extend<T> LinkedList<T> <: JsonStreamDeserializable<LinkedList<T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): LinkedList<T> {
        let result = LinkedList<T>()
        r.startArray()
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndArray) {
                result.addLast(T.fromJson(r))
                r.afterRead()
            } else {
                break
            }
        }
        r.endArray()
        return result
    }
}

extend<T> ArrayQueue<T> <: JsonStreamDeserializable<ArrayQueue<T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): ArrayQueue<T> {
        let result = ArrayQueue<T>()
        r.startArray()
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndArray) {
                result.add(T.fromJson(r))
                r.afterRead()
            } else {
                break
            }
        }
        r.endArray()
        return result
    }
}

extend<T> ArrayDeque<T> <: JsonStreamDeserializable<ArrayDeque<T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): ArrayDeque<T> {
        let result = ArrayDeque<T>()
        r.startArray()
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndArray) {
                result.addLast(T.fromJson(r))
                r.afterRead()
            } else {
                break
            }
        }
        r.endArray()
        return result
    }
}

extend<T> ArrayStack<T> <: JsonStreamDeserializable<ArrayStack<T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): ArrayStack<T> {
        let result = ArrayStack<T>()
        r.startArray()
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndArray) {
                result.add(T.fromJson(r))
                r.afterRead()
            } else {
                break
            }
        }
        r.endArray()
        return result
    }
}

extend<T> TreeSet<T> <: JsonStreamDeserializable<TreeSet<T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): TreeSet<T> {
        let result = TreeSet<T>()
        r.startArray()
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndArray) {
                result.add(T.fromJson(r))
                r.afterRead()
            } else {
                break
            }
        }
        r.endArray()
        return result
    }
}

extend<T> TreeMap<String, T> <: JsonStreamDeserializable<TreeMap<String, T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): TreeMap<String, T> {
        let result = TreeMap<String, T>()
        r.startObject()
        var key: String
        var value: T
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndObject) {
                key = (r.readName() as String).getOrThrow()
                value = T.fromJson(r)
                r.afterRead()
                result.add(key, value)
            } else {
                break
            }
        }
        r.endObject()
        return result
    }
}

extend<T> ConcurrentHashMap<String, T> <: JsonStreamDeserializable<ConcurrentHashMap<String, T>> where T <: JsonStreamDeserializable<T> {
    public static func fromJson(r: JsonStreamReader): ConcurrentHashMap<String, T> {
        let result = ConcurrentHashMap<String, T>()
        r.startObject()
        var key: String
        var value: T
        while (let Some(v) <- r.peek()) {
            if (v != JsonStreamEndObject) {
                key = (r.readName() as String).getOrThrow()
                value = T.fromJson(r)
                r.afterRead()
                result.add(key, value)
            } else {
                break
            }
        }
        r.endObject()
        return result
    }
}

let DIGITS_UI64: Array<UInt64> = [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 100, 100, 100, 100, 100, 100, 100, 10, 11, 12,
    13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 100, 100, 100, 100, 100,
    100, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100]
const HEXADECIMAL_OVERFLOW_LIMIT_UI64 = MAXVAL_UI64 / 16
const OCTAL_OVERFLOW_LIMIT_UI64 = MAXVAL_UI64 / 8
const BINARY_OVERFLOW_LIMIT_UI64 = MAXVAL_UI64 / 2
const DECIMAL_OVERFLOW_LIMIT_UI64 = MAXVAL_UI64 / 10
