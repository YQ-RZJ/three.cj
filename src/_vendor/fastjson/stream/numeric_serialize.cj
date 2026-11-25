/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected package three._vendor.fastjson.stream

import std.math.numeric.*


extend BigInt <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.jsonValue(this.toString())
    }
}

extend BigInt <: JsonStreamDeserializable<BigInt> {
    public static func fromJson(r: JsonStreamReader): BigInt {
        return BigInt.parse(r.readString(), radix: 10)
    }
}

extend Decimal <: JsonStreamSerializable {
    public func toJson(w: JsonStreamWriter): Unit {
        w.jsonValue(this.toString())
    }
}

extend Decimal <: JsonStreamDeserializable<Decimal> {
    public static func fromJson(r: JsonStreamReader): Decimal {
        return Decimal.parse(r.readString())
    }
}
