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
public class NewNameClass {
    @JsonName["newName"]
    public var name: String = ""
}

@Test
func JsonName_UseOldName() {
    const input = #"{"newName":""}"#
    @Assert(NewNameClass().toJson(), input)
}

@Test
func JsonName_UseNewName() {
    const input = #"{"newName":"123"}"#
    @Assert(NewNameClass.fromJson(input).toJson(), input)
}
