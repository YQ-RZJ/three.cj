/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

protected package three._vendor.fastjson

import std.collection.*
import std.convert.*
import three._vendor.fastjson.stream.*

public class JsonUtil {
    public static func checkRefEq(thisAny: Any, thatAny: ?Any): Bool {
        if (let Some(thatObj) <- thatAny) {
            if (let Some(thatObj) <- (thatObj as Object)) {
                if (let Some(thisObj) <- (thisAny as Object)) {
                    return refEq(thisObj, thatObj) // 判断对象是否相同
                }
            }
        }
        return false
    }

    public static func toModelStream(obj: Any, w: JsonStreamWriter, parent!: ?Any = None): Unit {
        return match (obj) {
            case v: JsonStreamSerializable => v.toJson(w)
            // 基本类型：扩展实现的 JsonStreamSerializable 在运行时可能无法被 match 检测到，显式处理
            case v: String => v.toJson(w)
            case v: Int64 => v.toJson(w)
            case v: Float64 => v.toJson(w)
            case v: Bool => v.toJson(w)
            case v: Option<Any> => match (v) {
                case Some(v) => toModelStream(v, w, parent: obj)
                case None => var df = w.writeValue("null")
            }
            case v: Collection<Any> =>
                if (checkRefEq(v, parent)) {
                    return // 禁止套娃
                }
                w.startArray()
                for (item in v) {
                    toModelStream(item, w, parent: obj)
                }
                w.endArray()
            case v: Map<String, Any> =>
                if (checkRefEq(v, parent)) {
                    return // 禁止套娃
                }
                w.startObject()
                for ((key, value) in v) {
                    w.writeName(key)
                    toModelStream(value, w, parent: obj)
                }
                w.endObject()
            case _ => throw Exception("error type")
        }
    }

    public static func toAnyStream(obj: ArrayList<Any>, w: JsonStreamWriter, parent!: ?Any = None): Unit {
        return match (obj) {
            case v: JsonStreamSerializable => v.toJson(w)
            case v: Option<Any> => match (v) {
                case Some(v) => toModelStream(v, w, parent: obj)
                case None => var df = w.writeValue("null")
            }
            case v: Collection<Any> =>
                if (checkRefEq(v, parent)) {
                    return // 禁止套娃
                }
                w.startArray()
                for (item in v) {
                    toModelStream(item, w, parent: obj)
                }
                w.endArray()
            case v: Map<String, Any> =>
                if (checkRefEq(v, parent)) {
                    return // 禁止套娃
                }
                w.startObject()
                for ((key, value) in v) {
                    w.writeName(key)
                    toModelStream(value, w, parent: obj)
                }
                w.endObject()
            case _ => throw Exception("error type")
        }
    }

    public static func streamFromJsonForOptionAny(reader: JsonStreamReader): ?Any {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case JsonStreamBeginArray =>
                var list = ArrayList<Any>()
                reader.startArray()
                while (let Some(v) <- reader.peek()) {
                    if (v != JsonStreamEndArray) {
                        list.add(streamFromJsonForOptionAny(reader))
                    } else {
                        break
                    }
                }
                reader.endArray()
                return list
            case JsonStreamBeginObject =>
                var map = HashMap<String, Any>()
                reader.startObject()
                while (let Some(v) <- reader.peek()) {
                    if (v != JsonStreamEndObject) {
                        map.add(reader.readName(), streamFromJsonForOptionAny(reader))
                    } else {
                        break
                    }
                }
                reader.endObject()
                return map
            case JsonStreamString => return reader.readValue<String>()
            case JsonStreamNumber =>
                var bby = reader.readValueBytes()
                for (i in 0..bby.size) {
                    if (bby[i] == 46) {
                        return Float64.parse(unsafe { String.fromUtf8Unchecked(bby) })
                    }
                }
                return Int64.parse(unsafe { String.fromUtf8Unchecked(bby) })
            case JsonStreamBool => return reader.readValue<Bool>()
            case JsonStreamNull => return None
            case _ => throw Exception("暂不支持反序列化该类型")
        }
    }

    public static func streamFromJsonForAny(reader: JsonStreamReader): Any {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case JsonStreamBeginArray =>
                var list = ArrayList<Any>()
                reader.startArray()
                while (let Some(v) <- reader.peek()) {
                    if (v != JsonStreamEndArray) {
                        list.add(streamFromJsonForAny(reader))
                    } else {
                        break
                    }
                }
                reader.endArray()
                return list
            case JsonStreamBeginObject =>
                var map = HashMap<String, Any>()
                reader.startObject()
                while (let Some(v) <- reader.peek()) {
                    if (v != JsonStreamEndObject) {
                        map.add(reader.readName(), streamFromJsonForAny(reader))
                    } else {
                        break
                    }
                }
                reader.endObject()
                return map

            case JsonStreamString => return reader.readValue<String>()
            case JsonStreamNumber =>
                var bby = reader.readValueBytes()
                for (i in 0..bby.size) {
                    if (bby[i] == 46) {
                        return Float64.parse(unsafe { String.fromUtf8Unchecked(bby) })
                    }
                }
                return Int64.parse(unsafe { String.fromUtf8Unchecked(bby) })
            case JsonStreamBool => return reader.readValue<Bool>()
            case JsonStreamNull => return reader.readValue<Option<Int64>>()
            case _ => throw Exception("暂不支持反序列化该类型")
        }
    }

    public static func streamFromJsonForArryAny(reader: JsonStreamReader): Array<Any> {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case JsonStreamBeginArray =>
                var list = ArrayList<Any>()
                reader.startArray()
                while (let Some(v) <- reader.peek()) {
                    if (v != JsonStreamEndArray) {
                        list.add(streamFromJsonForAny(reader))
                    } else {
                        break
                    }
                }
                reader.endArray()
                return unsafe { list.getRawArray() }
            case _ => throw Exception("暂不支持反序列化该类型")
        }
    }

    public static func streamFromJsonForListAny(reader: JsonStreamReader): ArrayList<Any> {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case JsonStreamBeginArray =>
                var list = ArrayList<Any>()
                reader.startArray()
                while (let Some(v) <- reader.peek()) {
                    if (v != JsonStreamEndArray) {
                        list.add(streamFromJsonForAny(reader))
                    } else {
                        break
                    }
                }
                reader.endArray()
                return list
            case _ => throw Exception("暂不支持反序列化该类型")
        }
    }

    public static func streamFromJsonForHashMapAny(reader: JsonStreamReader): HashMap<String, Any> {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case JsonStreamBeginObject =>
                var map = HashMap<String, Any>()
                reader.startObject()
                while (let Some(v) <- reader.peek()) {
                    if (v != JsonStreamEndObject) {
                        map.add(reader.readName(), streamFromJsonForAny(reader))
                    } else {
                        break
                    }
                }
                reader.endObject()
                return map
            case _ => throw Exception("暂不支持反序列化该类型")
        }
    }

    public static func streamFromJsonForArray<T>(reader: JsonStreamReader): Array<T> where T <: JsonStreamDeserializable<T> {
        var list = ArrayList<T>()
        reader.startArray()
        while (let Some(v) <- reader.peek()) {
            if (v != JsonStreamEndArray) {
                list.add(reader.readValue<T>())
            } else {
                break
            }
        }
        reader.endArray()
        return list.toArray()
    }

    public static func streamFromJsonForList<T>(reader: JsonStreamReader): ArrayList<T> where T <: JsonStreamDeserializable<T> {
        var list = ArrayList<T>()
        reader.startArray()
        while (let Some(v) <- reader.peek()) {
            if (v != JsonStreamEndArray) {
                list.add(reader.readValue<T>())
            } else {
                break
            }
        }
        reader.endArray()
        return list
    }
}
