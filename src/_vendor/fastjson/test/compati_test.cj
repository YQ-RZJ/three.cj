/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected package three._vendor.fastjson.test


import std.unittest.*
import std.unittest.testmacro.*
import three._vendor.fastjson.*
import three._vendor.fastjson.macros.*
import std.collection.*
import std.convert.*

// 支持多种类型
@JsonAdapter
public class CompatiClass {
    // 支持所有整数类型
    public var i8: Int8 = 0
    public var i16: Int16 = 0
    public var i32: Int32 = 0
    public var i64: Int64 = 0
    public var u8: UInt8 = 0
    public var u16: UInt16 = 0
    public var u32: UInt32 = 0
    public var u64: UInt64 = 0

    // 支持所有的整数类型
    public var f16: Float16 = 0.0
    public var f32: Float32 = 0.0
    public var f64: Float64 = 0.0

    // 支持Bool类型
    public var b: Bool = false

    // 支持String类型
    public var str: String = ""

    public var arr: Array<Int64> = Array()
    public var arrList: ArrayList<Float16> = ArrayList()
    public var hashMap: HashMap<String, Int64> = HashMap()

}



@JsonAdapter
public class CompatiStrClass {

    // 支持String类型
    public var str: String = ""

    public var arr: Array<String> = Array()
    public var arrList: ArrayList<String> = ArrayList()
    public var hashMap: HashMap<String, String> = HashMap()

}


@Test
class CompatiClassTest {
    @TestCase
    func fromJson() {
        const input = #"
            {
                "i8": "127",
                "i16": "-32768",
                "i32": "2147483647",
                "i64": "9223372036854775807",
                "u8": "255",
                "u16": "65535",
                "u32": "4294967295",
                "u64": "9223372036854775807",
                "f16": "1.5",
                "f32": "3.1415927",
                "f64": "2.718281828459045",
                "b": "true",
                "str": "Hello, World!",
                "arr": ["123","456","789"],
                "arrList":["23.33","45.3","12.45"],
                "hashMap":{
                            "a":"3445",
                            "b":"13445"
                          }
            
            }
            "#
        var excpet = #"{"i8":127,"i16":-32768,"i32":2147483647,"i64":9223372036854775807,"u8":255,"u16":65535,"u32":4294967295,"u64":9223372036854775807,"f16":1.5,"f32":3.141593,"f64":2.718282,"b":true,"str":"Hello, World!","arr":[123,456,789],"arrList":[23.328125,45.3125,12.453125],"hashMap":{"a":3445,"b":13445}}"#
        let b = CompatiClass.fromJson(input)
         @Assert(b.toJson(),excpet)
        

    }

    @TestCase
    func fromJsonStr() {
        const input = #"
            {
                "str": 1234,
                "arr": [1234,adc,@#$],
                "arrList":[23.33,45.3,12.45],
                "hashMap":{
                            "a":3445,
                            "b":13445
                          }

            }
            "#
        var excpet = #"{"str":"1234","arr":["1234","adc","@#$"],"arrList":["23.33","45.3","12.45"],"hashMap":{"a":"3445","b":"13445"}}"#
        let b = CompatiStrClass.fromJson(input)
         @Assert(b.toJson(),excpet)
        

    }

}