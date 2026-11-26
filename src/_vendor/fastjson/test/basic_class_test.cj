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
public class BasicClass {
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

    // 支持Option类型
    public var optNone: ?String = None
    public var optSome: ?Int64 = None

    // 支持 Array、ArrayList、HashSet类型（对应JSON Array）
    public var arr: Array<Int64> = Array()
    public var arrList: ArrayList<String> = ArrayList()
    public var hashSet: HashSet<Int64> = HashSet()

    // 支持 HashMap 类型（对应JSON Object类型）
    public var hashMap: HashMap<String, String> = HashMap()

    // 支持 AnyType 类型（对应任意的JSON值）
    public var any: Any = ""
    public var OpAny: Option<Any> = Some(0)
    public var OpAny2: Option<Any> = Some(0.1)
    public var hashMapAny: HashMap<String, Any> = HashMap()
    public var arrayAny: Array<Any> = Array()
}

@JsonAdapter
public struct BasicStruct{
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

    // 支持Option类型
    public var optNone: ?String = None
    public var optSome: ?Int64 = None

    // 支持 Array、ArrayList、HashSet类型（对应JSON Array）
    public var arr: Array<Int64> = Array()
    public var arrList: ArrayList<String> = ArrayList()
    public var hashSet: HashSet<Int64> = HashSet()

    // 支持 HashMap 类型（对应JSON Object类型）
    public var hashMap: HashMap<String, String> = HashMap()

    // 支持 AnyType 类型（对应任意的JSON值）
    public var any: Any = ""
    public var OpAny: Option<Any> = Some(0)
    public var OpAny2: Option<Any> = Some(0.1)
    public var hashMapAny: HashMap<String, Any> = HashMap()
    public var arrayAny: Array<Any> = Array()
}


@Test
class BasicClassTest {
    @TestCase
    func fromJson() {
        const input = #"
            {
                "i8": 127,
                "i16": -32768,
                "i32": 2147483647,
                "i64": 9223372036854775807,
                "u8": 255,
                "u16": 65535,
                "u32": 4294967295,
                "u64": 9223372036854775807,
                "f16": 1.5,
                "f32": 3.1415927,
                "f64": 2.718281828459045,
                "b": true,
                "str": "Hello, World!",
                "optNone": null,
                "optSome": 42,
                "arr": [
                    1,
                    2,
                    3,
                    4
                ],
                "arrList": [
                    "apple",
                    "banana",
                    "orange"
                ],
                "hashSet": [
                    100,
                    101
                ],
                "hashMap": {
                    "key1": "value1",
                    "key2": "value2"
                },
                "any": {
                    "nested": {
                        "data": [
                            1,
                            "two",
                            false
                        ],
                        "info": "This is any type data"
                    }
                },
                "OpAny" : 100,
                "OpAny2" : 100.1,
                "hashMapAny": {
                    "key1": "value1",
                    "key2": 100.02
                },
                "arrayAny": [
                    "apple",
                     false,
                    10
                ]
            }
            "#
        let b = BasicClass.fromJson(input)
        @Assert(b.i8, 127)
        @Assert(b.i16, -32768)
        @Assert(b.i32, 2147483647)
        @Assert(b.i64, 9223372036854775807)
        @Assert(b.u8, 255)
        @Assert(b.u16, 65535)
        @Assert(b.u32, 4294967295)
        @Assert(b.u64, 9223372036854775807) // JsonInt对应的类型是 Int64，所以值不能超过 Int64.MAX
        @Assert(b.f16, 1.5)
        @Assert(b.f32, 3.1415927)
        @Assert(b.f64, 2.718281828459045)
        @Assert(b.b, true)
        println(b.str)
        @Assert(b.str, "Hello, World!")
        @Assert(b.optNone.isNone())
        @Assert(b.optSome.getOrThrow(), 42)
        @Assert(b.arr.size, 4)
        @Assert(b.arr[0], 1)
        @Assert(b.arr[1], 2)
        @Assert(b.arr[2], 3)
        @Assert(b.arr[3], 4)
        @Assert(b.arrList.size, 3)
        @Assert(b.arrList[0], "apple")
        @Assert(b.arrList[1], "banana")
        @Assert(b.arrList[2], "orange")
        @Assert(b.hashSet.size, 2)
        @Assert(b.hashSet.contains(100))
        @Assert(b.hashSet.contains(101))
        @Assert(b.hashMap.size, 2)
        @Assert(b.hashMap.contains("key1"))
        @Assert(b.hashMap.contains("key2"))
        @Assert(b.hashMap.get("key1").getOrThrow(), "value1")
        @Assert(b.hashMap.get("key2").getOrThrow(), "value2")
        var bany = b.any as HashMap<String, Any> ?? throw Exception("any is not HashMap<String, Any>")
        var opany = b.OpAny.getOrThrow() as Int64 ?? throw Exception("OpAny is not Int64")
        @Assert(opany, 100)
        var opany2 = b.OpAny2.getOrThrow() as Float64 ?? throw Exception("OpAny is not Float64")
        @Assert(opany2, 100.1)
        @Assert(b.hashMapAny.size, 2)

        var aa1 = b.arrayAny[0] as String ?? throw Exception("any is not String")
        @Assert(aa1, "apple")
        var aa2 = b.arrayAny[1] as Bool ?? throw Exception("any is not Bool")
        @Assert(aa2, false)
        var aa3 = b.arrayAny[2] as Int64 ?? throw Exception("any is not Int64")
        @Assert(aa3, 10)
    }

    @TestCase
    func toJson() {
        let b = BasicClass()
        b.i8 = 1
        b.i16 = -2
        b.i32 = 3
        b.i64 = -4
        b.u8 = 5
        b.u16 = 6
        b.u32 = 7
        b.u64 = 8
        b.f16 = 16.5 // 二进制中是有限位数的浮点数可以精确存储，没有精度丢失
        b.f32 = 32.25 // 二进制中是有限位数的浮点数可以精确存储，没有精度丢失
        b.f64 = 64.125 // 二进制中是有限位数的浮点数可以精确存储，没有精度丢失
        b.b = true
        b.str = "Hello, Cangjie!"
        b.optNone = None
        b.optSome = 9
        b.arr = [10, 11, 12]
        b.arrList = ArrayList<String>(["one", "two", "three"])
        b.hashSet = HashSet([20, 21, 22, 23, 24, 25])
        b.hashMap = HashMap(
            [
                ("key1", "value1"),
                ("key2", "value2"),
                ("key3", "value3")
            ]
        )

        b.any = HashMap<String, Any>([("key1", "value1")])
        b.OpAny = Some(100)
        b.OpAny2 = Some(100.1)
        b.hashMapAny = HashMap<String, Any>([("key1", "value1"), ("key2", 100.02)])
        b.arrayAny = ["apple", false, 10]

        const expectJson = #"{"i8":1,"i16":-2,"i32":3,"i64":-4,"u8":5,"u16":6,"u32":7,"u64":8,"f16":16.5,"f32":32.25,"f64":64.125,"b":true,"str":"Hello, Cangjie!","optNone":null,"optSome":9,"arr":[10,11,12],"arrList":["one","two","three"],"hashSet":[20,21,22,23,24,25],"hashMap":{"key1":"value1","key2":"value2","key3":"value3"},"any":{"key1":"value1"},"OpAny":100,"OpAny2":100.1,"hashMapAny":{"key1":"value1","key2":100.02},"arrayAny":["apple",false,10]}"#
        @Assert(b.toJson(), expectJson)
    }


 @TestCase
 func structTest(){
        const input = #"{"i8":127,"i16":-32768,"i32":2147483647,"i64":9223372036854775807,"u8":255,"u16":65535,"u32":4294967295,"u64":9223372036854775807,"f16":1.5,"f32":3.141593,"f64":2.718282,"b":true,"str":"Hello, World!","optNone":null,"optSome":42,"arr":[1,2,3,4],"arrList":["apple","banana","orange"],"hashSet":[100,101],"hashMap":{"key1":"value1","key2":"value2"},"any":{"nested":{"data":[1,"two",false],"info":"This is any type data"}},"OpAny":100,"OpAny2":100.1,"hashMapAny":{"key1":"value1","key2":100.02},"arrayAny":["apple",false,10]}"#
        let b:BasicStruct = BasicStruct.fromJson(input)
        @Assert(b.toJson(), input)
 }

  @TestCase
 func mapTest(){
    var i =0
    try {
        BClass().toJson()
    } catch (e: Exception) {
        i++
        @Assert(e.message, "This key is supported in JSON Object.")
    }
    @Assert(i,1)
    
 }

  @TestCase
 func map2Test(){
    const exceptstr = #"{"hashMap_Int64":{"1":"1"},"hashMap_Int32":{"1":"1"},"hashMap_Int16":{"1":"1"},"hashMap_Int8":{"1":"1"},"hashMap_IntNative":{"1":"1"},"hashMap_UInt64":{"1":"1"},"hashMap_UInt32":{},"hashMap_UInt16":{},"hashMap_UInt8":{},"hashMap_UIntNative":{"1":"1"},"hashMap_Float64":{"1.100000":"1.1"},"hashMap_Float32":{"1.100000":"1.1"},"hashMap_Float16":{"1.099609":"1.1"},"hashMap_Bool":{"true":"true"}}"#
     @Assert(exceptstr, B2Class().toJson())
 }


}


@JsonAdapter
public class BClass {
    public var  hashMapAny: HashMap<AClass, String> = HashMap<AClass, String> ()
    public init(){
        hashMapAny.add(AClass("name", 1), "1")
    }
}



@JsonAdapter
public class B2Class {
    public var  hashMap_Int64: HashMap<Int64, String> = HashMap<Int64, String> ()
    public var  hashMap_Int32: HashMap<Int64, String> = HashMap<Int64, String> ()
    public var  hashMap_Int16: HashMap<Int64, String> = HashMap<Int64, String> ()
    public var  hashMap_Int8: HashMap<Int64, String> = HashMap<Int64, String> ()
    public var  hashMap_IntNative: HashMap<IntNative, String> = HashMap<IntNative, String> ()

    public var  hashMap_UInt64: HashMap<UInt64, String> = HashMap<UInt64, String> ()
    public var  hashMap_UInt32: HashMap<UInt64, String> = HashMap<UInt64, String> ()
    public var  hashMap_UInt16: HashMap<UInt64, String> = HashMap<UInt64, String> ()
    public var  hashMap_UInt8: HashMap<UInt64, String> = HashMap<UInt64, String> ()
    public var  hashMap_UIntNative: HashMap<UIntNative, String> = HashMap<UIntNative, String> ()
    public var  hashMap_Float64: HashMap<Float64, String> = HashMap<Float64, String> ()
    public var  hashMap_Float32: HashMap<Float32, String> = HashMap<Float32, String> ()
    public var  hashMap_Float16: HashMap<Float16, String> = HashMap<Float16, String> ()
    public var  hashMap_Bool: HashMap<Bool, String> = HashMap<Bool, String> ()

    public init(){
        hashMap_Int64.add(1, "1")
        hashMap_Int32.add(1, "1")
        hashMap_Int16.add(1, "1")
        hashMap_Int8.add(1, "1")
        hashMap_IntNative.add(1, "1")
        hashMap_UInt64.add(1, "1")
        hashMap_UInt64.add(1, "1")
        hashMap_UInt64.add(1, "1")
        hashMap_UInt64.add(1, "1")
        hashMap_UIntNative.add(1, "1")

        hashMap_Float64.add(1.1, "1.1")
        hashMap_Float32.add(1.1, "1.1")
        hashMap_Float16.add(1.1, "1.1")

        hashMap_Bool.add(true, "true")
    }
}

@JsonAdapter
public class AClass <: Hashable  & Equatable<AClass> {
    public var name: String = ""
    public var age: Int64 = 0
    public init(){
        this.name = ""
        this.age = 0
    }
    public init(name: String, age: Int64){
        this.name = name
        this.age = age
        
    }

    @OverflowWrapping
    public func hashCode(): Int64 {
        name.hashCode() + age.hashCode()
    }
    public operator func ==(that: AClass): Bool {
        return this.name == that.name && this.age == that.age
    }

    public operator func !=(that: AClass): Bool {
        return this.name != that.name || this.age != that.age
    }
}

