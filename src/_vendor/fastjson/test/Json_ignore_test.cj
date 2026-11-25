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
public class IgnoreClass {
    @JsonIgnore
    public var a: String = ""
    @JsonIgnore
    public var b: ArrayList<Int64> = ArrayList<Int64>()

    public var c: Int64 = 0
}

@Test
func JsonIgnore_BasicTest() {
    const input = #"{"a":"aaa","b":[1,2,3],"c":456}"#
    const expectOutput = #"{"c":456}"#
    @Assert(IgnoreClass.fromJson(input).toJson(), expectOutput)
}
