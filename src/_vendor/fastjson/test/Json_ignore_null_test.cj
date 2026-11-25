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
public class IgnoreNullClass {
    @JsonIgnoreNull
    public var a: Int64 = 0

    @JsonIgnoreNull
    public var b: Option<Int64> = 0

    @JsonIgnoreNull
    public var c: Option<String> = ""

    @JsonIgnoreNull
    public var d: Option<ArrayList<Int64>> = None

    @JsonIgnoreNull
    public var e: Option<ArrayList<String>> = None
}

@Test
func JsonIgnoreNull_UseNullValue() {
    const input = #"{"a":1,"b":null,"c":"ccc","d":[4,5,6],"e":null}"#
    const expectOutput = #"{"a":1,"c":"ccc","d":[4,5,6]}"#
    @Assert(IgnoreNullClass.fromJson(input).toJson(), expectOutput)
}

@Test
func JsonIgnoreNull_MissValue() {
    const input = #"{"a":1}"#
    const expectOutput = #"{"a":1,"b":0,"c":""}"#
    @Assert(IgnoreNullClass.fromJson(input).toJson(), expectOutput)
}
