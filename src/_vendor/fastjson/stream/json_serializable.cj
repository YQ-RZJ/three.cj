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


public interface JsonStreamSerializable {
    func toJson(w: JsonStreamWriter): Unit
    func toJson(): String {
        let stream = ByteBuffer()
        var writer = JsonStreamWriter(stream)
        toJson(writer)
        writer.flush()
        return String.fromUtf8(readToEnd(stream))
    }
}

extend Rune <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        this.toString().toJson(w)
    }
}

extend Int64 <: JsonStreamSerializable {
    @OverflowWrapping
    public func toJson(w: JsonStreamWriter): Unit {
        w.beforeValue()
        if (this < 0) {
            w.buffer[w.curPos] = b'-'
            w.curPos++
            w.curPos += uitoa(UInt64(-this), w.buffer[w.curPos..])
        } else {
            w.curPos += uitoa(UInt64(this), w.buffer[w.curPos..])
        }
    }
}

extend Int32 <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        Int64(this).toJson(w)
    }
}

extend Int16 <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        Int64(this).toJson(w)
    }
}

extend Int8 <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        Int64(this).toJson(w)
    }
}

extend IntNative <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        Int64(this).toJson(w)
    }
}

extend UInt64 <: JsonStreamSerializable {
    @OverflowWrapping
    public func toJson(w: JsonStreamWriter): Unit {
        w.beforeValue()
        w.curPos += uitoa(this, w.buffer[w.curPos..])
    }
}

extend UInt32 <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        UInt64(this).toJson(w)
    }
}

extend UInt16 <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        UInt64(this).toJson(w)
    }
}

extend UInt8 <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        UInt64(this).toJson(w)
    }
}

extend UIntNative <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        UInt64(this).toJson(w)
    }
}

extend Float64 <: JsonStreamSerializable {
    @OverflowWrapping
    public func toJson(w: JsonStreamWriter): Unit {
        w.beforeValue()
        let chars = this.toString().toArray()
        for (i in 0..chars.size) {
             w.buffer[w.curPos] =  chars[i]
             w.curPos += 1
        }
        while (w.buffer[w.curPos - 1] == b'0') {
            w.curPos--
        }
        if (w.buffer[w.curPos - 1] == b'.') {
            w.curPos--
        }
    }
}

extend Float32 <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        Float64(this).toJson(w)
    }
}

extend Float16 <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        Float64(this).toJson(w)
    }
}

extend Bool <: JsonStreamSerializable {
    @OverflowWrapping
    public func toJson(w: JsonStreamWriter): Unit {
        w.beforeValue()
        if (this) {
            w.buffer[w.curPos] = b't'
            w.buffer[w.curPos + 1] = b'r'
            w.buffer[w.curPos + 2] = b'u'
            w.buffer[w.curPos + 3] = b'e'
            w.curPos += 4
        } else {
            w.buffer[w.curPos] = b'f'
            w.buffer[w.curPos + 1] = b'a'
            w.buffer[w.curPos + 2] = b'l'
            w.buffer[w.curPos + 3] = b's'
            w.buffer[w.curPos + 4] = b'e'
            w.curPos += 5
        }
    }
}

extend<T> Array<T> <: JsonStreamSerializable where T <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startArray()
        for (item in this) {
            w.writeValue<T>(item)
        }
        w.endArray()
    }
}

extend<T> ArrayList<T> <: JsonStreamSerializable where T <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startArray()
        for (item in this) {
            w.writeValue<T>(item)
        }
        w.endArray()
    }
}
extend<T> HashSet<T> <: JsonStreamSerializable where T <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startArray()
        for (item in this) {
            w.writeValue<T>(item)
        }
        w.endArray()
    }
}

extend<K, V> HashMap<K, V> <: JsonStreamSerializable where K<: JsonStreamSerializable,  V <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startObject()
        for ((k, v) in this) {
            match (k) {
                case k: String => w.writeName(k).writeValue(v)
                case k: Int64 => w.writeName(k.toString()).writeValue(v)
                case k: Int32 => w.writeName(k.toString()).writeValue(v)
                case k: Int16 => w.writeName(k.toString()).writeValue(v)
                case k: Int8 => w.writeName(k.toString()).writeValue(v)
                case k: IntNative => w.writeName(k.toString()).writeValue(v)
                case k: UInt64 => w.writeName(k.toString()).writeValue(v)
                case k: UInt32 => w.writeName(k.toString()).writeValue(v)
                case k: UInt16 => w.writeName(k.toString()).writeValue(v)
                case k: UInt8 => w.writeName(k.toString()).writeValue(v)
                case k: UIntNative => w.writeName(k.toString()).writeValue(v)
                case k: Float64 => w.writeName(k.toString()).writeValue(v)
                case k: Float32 => w.writeName(k.toString()).writeValue(v)
                case k: Float16 => w.writeName(k.toString()).writeValue(v)
                case k: Bool => w.writeName(k.toString()).writeValue(v)
                case _ => throw IllegalStateException("This key is supported in JSON Object.")
            }

        }
        w.endObject()
    }
}

extend<T> Option<T> <: JsonStreamSerializable where T <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        if (let Some(v) <- this) {
            w.writeValue<T>(v)
        } else {
            w.writeNullValue()
        }
    }
}

extend<T> LinkedList<T> <: JsonStreamSerializable where T <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startArray()
        for (item in this) {
            w.writeValue<T>(item)
        }
        w.endArray()
    }
}

extend<T> ArrayQueue<T> <: JsonStreamSerializable where T <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startArray()
        for (item in this) {
            w.writeValue<T>(item)
        }
        w.endArray()
    }
}

extend<T> ArrayDeque<T> <: JsonStreamSerializable where T <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startArray()
        for (item in this) {
            w.writeValue<T>(item)
        }
        w.endArray()
    }
}

extend<T> ArrayStack<T> <: JsonStreamSerializable where T <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startArray()
        let list = this.toArray()
        list.reverse()
        for (item in list) {
            w.writeValue<T>(item)
        }
        w.endArray()
    }
}

extend<T> TreeSet<T> <: JsonStreamSerializable where T <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startArray()
        for (item in this) {
            w.writeValue<T>(item)
        }
        w.endArray()
    }
}

extend<V> TreeMap<String, V> <: JsonStreamSerializable where V <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startObject()
        for ((k, v) in this) {
            w.writeName(k).writeValue(v)
        }
        w.endObject()
    }
}

extend<V> ConcurrentHashMap<String, V> <: JsonStreamSerializable where V <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.startObject()
        for ((k, v) in this) {
            w.writeName(k).writeValue(v)
        }
        w.endObject()
    }
}
