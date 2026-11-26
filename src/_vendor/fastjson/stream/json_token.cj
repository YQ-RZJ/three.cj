/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected package three._vendor.fastjson.stream


public enum JsonToken <: Equatable<JsonToken> & Hashable {
    | JsonStreamNull
    | JsonStreamBool
    | JsonStreamNumber
    | JsonStreamString
    | JsonStreamBeginArray
    | JsonStreamEndArray
    | JsonStreamBeginObject
    | JsonStreamEndObject
    | JsonStreamName

    public operator func ==(that: JsonToken): Bool {
        return this.hashCode() == that.hashCode()
    }

    public operator func !=(that: JsonToken): Bool {
        return !(this == that)
    }

    public func hashCode(): Int64 {
        return match (this) {
            case JsonStreamNull => 0
            case JsonStreamBool => 1
            case JsonStreamNumber => 2
            case JsonStreamString => 3
            case JsonStreamBeginArray => 4
            case JsonStreamEndArray => 5
            case JsonStreamBeginObject => 6
            case JsonStreamEndObject => 7
            case JsonStreamName => 8
        }
    }
}

const PEEK_STATE_NULL = 0
const PEEK_STATE_TRUE = 1
const PEEK_STATE_FALSE = 2
const PEEK_STATE_NUMBER = 3
const PEEK_STATE_STRING = 4
const PEEK_STATE_ARRAY_BEGIN = 5
const PEEK_STATE_ARRAY_END = 6
const PEEK_STATE_OBJECT_BEGIN = 7
const PEEK_STATE_OBJECT_END = 8
const PEEK_STATE_NAME = 9 // next token must be a name, which type is string
const PEEK_STATE_VALUE = 10 // next token must be a value, can not be a endArray\endobject\name
const PEEK_STATE_NONE = 11
let PEEKSTATE2TOKEN: Array<JsonToken> = [JsonStreamNull, JsonStreamBool, JsonStreamBool, JsonStreamNumber, JsonStreamString, JsonStreamBeginArray, JsonStreamEndArray,
    JsonStreamBeginObject, JsonStreamEndObject, JsonStreamName]

class JsonStateStack {
    static const JSON_UNDEFINE = 0
    static const JSON_OBJECT = 1
    static const JSON_ARRAY = 2

    var stack = Array<Int64>(8, repeat: 0)
    var stacksize = 1

    init() {}

    func put(v: Int64) {
        if (stacksize >= stack.size) {
            var newstack = Array<Int64>(stack.size * 2, repeat: 0)
            stack.copyTo(newstack, 0, 0, stack.size)
            stack = newstack
        }
        stack[stacksize] = v
        stacksize++
    }

    func pop() {
        stacksize--
    }

    prop top: Int64 {
        get() {
            stack[stacksize - 1]
        }
    }

    prop depth: Int64 {
        get() {
            stacksize
        }
    }
}
