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

// Case 1：基础测试。
@JsonAdapter
public class Basic {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()
}

@Test
func JsonAdapter_BasicTest() {
    const input: String = #"{"a":123,"b":"bbbbb","c":null,"d":[1,2,3],"e":["s1","s2","s3"],"f":{"f1":123,"f2":456}}"#
    @Assert(Basic.fromJson(input).toJson(), input)
}

// Case 2：开发者如果手动添加了 `<: IStreamJsonAdapter<T>`，也可以正常运行。
@JsonAdapter
public class ClassWithInterface <: IStreamJsonAdapter<ClassWithInterface> {
    public var a: Int64 = 0
}

@Test
func Test_JsonAdapter_ClassWithInterface() {
    const input: String = #"{"a": 123}"#
    let obj = ClassWithInterface.fromJson(input)
    @Assert(obj.a, 123)
}

// Case 3：即使类实现了其他接口，也不影响 @JsonAdapter 的使用。
@JsonAdapter
public class ClassWithEqutable <: Equatable<ClassWithEqutable> {
    public var a: Int64 = 0

    public operator func ==(right: ClassWithEqutable): Bool {
        return this.a == right.a
    }
    public operator func !=(right: ClassWithEqutable): Bool {
        return !(this.a == right.a)
    }
}

@Test
func Test_JsonAdapter_ClassWithEqutable() {
    const input: String = #"{"a": 123}"#
    let obj = ClassWithEqutable.fromJson(input)
    let target = ClassWithEqutable()
    target.a = 123
    @Assert(obj, target)
}

// Case 4：存在父类，并且未使用 withSuperClass 属性
@JsonAdapter
public open class Parent {
    public var a: Int64 = 0
}

@JsonAdapter
public class ChildNotMarkParent <: Parent {
    public var b: String = ""
}

@Test
func Test_JsonAdapter_ChildNotMarkParent() {
    const input: String = #"{"a":123,"b":"hello"}"#

    let c = ChildNotMarkParent.fromJson(input)
    @Assert(c.toJson(), #"{"b":"hello"}"#)

}

// Case 5：存在父类，使用了 withSuperClass 属性
@JsonAdapter[withSuperClass = Parent]
public class ChildMarkParent <: Parent {
    public var b: String = ""
}

@Test
func Test_JsonAdapter_ChildMarkParent() {
    const input: String = #"{"a":123,"b":"hello"}"#
    let c = ChildMarkParent.fromJson(input)
    @Assert(c.a, 123)
    @Assert(c.b, "hello")

}

// Case 6: 存在泛型，并且未使用 withGenericType 属性
@JsonAdapter
public class GenericNotMark<T> {
    public var a: Int64 = 0

    @JsonIgnore
    public var data: ?T = None
}

@JsonAdapter
public class MyData {
    public var d1: Int64 = 0
    public var d2: Int64 = 0
}

@Test
func Test_JsonAdapter_GenericNotMark() {
    const input = #"{"a":123,"data":{"d1":100,"d2":200}}"#
    let obj = GenericNotMark<MyData>.fromJson(input)
    @Assert(obj.data.isNone())
    @Assert(obj.toJson(), #"{"a":123}"#)

}

// Case 7：存在泛型，使用了 withGenericType 属性
@JsonAdapter[withGenericType = T]
public class GenericMark<T> {
    public var a: Int64 = 0
    public var data: ?T = None
}

@Test
func Test_JsonAdapter_GenericMark() {
    const input = #"{"a":123,"data":{"d1":100,"d2":200}}"#
    let obj = GenericMark<MyData>.fromJson(input)
    @Assert(obj.data.isSome())
    @Assert(obj.toJson(), input)
}

// Case 8：同时具有泛型和泛型父类。
@JsonAdapter[withGenericType = T]
public open class GenericParent<T> {
    public var pData: ?T = None
}

@JsonAdapter[withSuperClass = GenericParent<T> ; withGenericType = T]
public class GenericChild<T> <: GenericParent<T> {
    public var cData: ?T = None
}

@Test
func Test_JsonAdapter_GeneircChild() {
    const input = #"{"pData":{"d1":1,"d2":2},"cData":{"d1":11,"d2":22}}"#
    let c = GenericChild<MyData>.fromJson(input)

    @Assert(c.pData.getOrThrow().d1, 1)
    @Assert(c.pData.getOrThrow().d2, 2)
    @Assert(c.cData.getOrThrow().d1, 11)
    @Assert(c.cData.getOrThrow().d2, 22)
}
