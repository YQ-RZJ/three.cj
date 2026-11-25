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

@JsonAdapter
public open class Father {
    public var p1: Int64 = 0
    public var p2: String = "i am p2"
    public var p3: Bool = false
    public var p4: Array<Int64> = [10, 20, 30]
    public var p5: HashMap<String, String> = HashMap([("keyA", "valueA"), ("keyB", "valueB")])
}

@JsonAdapter[withSuperClass = Father]
public class Son <: Father {
    public var s1: String = "i am s1"
    public var s2: Int64 = 10
    public var s3: Bool = true
    public var s4: Array<Int64> = [1, 2, 3]
    public var s5: HashMap<String, String> = HashMap([("key1", "value1"), ("key2", "value2")])
}

// 少字段
@Test
func Test_FieldClass_Less() {
    // 少 son s1 s4 father p2 p3
    const input = #"{"s2":10,"s3":true,"s5":{"key1":"value1","key2":"value2"},"p1":0,"p4":[10,20,30],"p5":{"keyA":"valueA","keyB":"valueB"}}"#
    var s = Son.fromJson(input)

    //少的字段 使用默认值
    @Assert(s.s1, "i am s1")
    @Assert(s.s4, [1, 2, 3])
    @Assert(s.p2, "i am p2")
    @Assert(s.p3, false)
}

// 多字段
@Test
func Test_FieldClass_More() {
    // 多 son s6 father p6
    const input = #"{"s1":"i am s1","s2":10,"s3":true,"s4":[1,2,3],"s5":{"key1":"value1","key2":"value2"},"s6":123.1,"p1":0,"p2":"i am p2","p3":false,"p4":[10,20,30],"p5":{"keyA":"valueA","keyB":"valueB"},"p6":"test"}"#
    const exceptstr = #"{"s1":"i am s1","s2":10,"s3":true,"s4":[1,2,3],"s5":{"key1":"value1","key2":"value2"},"p1":0,"p2":"i am p2","p3":false,"p4":[10,20,30],"p5":{"keyA":"valueA","keyB":"valueB"}}"#
    var s = Son.fromJson(input)
    // 多的字段 忽略
    @Assert(s.toJson(), exceptstr)
}
