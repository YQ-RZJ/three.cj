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

// 使用 @EnumNum 自动生成 value()/fromValue(Int64)。
// 与 @JsonAdapter 配合使用时，@EnumNum 需要位于 @JsonAdapter 下方（更靠近 enum 声明），
// 以便 @EnumNum 先展开生成 value()/fromValue()，再由 @JsonAdapter 生成 JSON 方法。
@JsonAdapter
@EnumNum
public enum Color {
    | Red
    | Green
    | Blue
}

// 手动实现 value()/fromValue(Int64)，@JsonAdapter 应能识别并使用
@JsonAdapter
public enum Size {
    | Small
    | Medium
    | Large

    public func value(): Int64 {
        match (this) {
            case Small => 10
            case Medium => 20
            case Large => 30
        }
    }

    public static func fromValue(v: Int64): Size {
        match (v) {
            case 10 => Small
            case 20 => Medium
            case 30 => Large
            case _ => Small
        }
    }
}

@JsonAdapter
public class Product {
    public var name: String = ""
    public var color: Color = Color.Red
    public var size: Size = Size.Small
}

@Test
class EnumTest {
    @TestCase
    func enumNumValue(): Unit {
        @Assert(Color.Red.value(), 0)
        @Assert(Color.Green.value(), 1)
        @Assert(Color.Blue.value(), 2)
    }

    @TestCase
    func enumNumFromValue(): Unit {
        @Assert(Color.fromValue(0).value(), 0)
        @Assert(Color.fromValue(1).value(), 1)
        @Assert(Color.fromValue(2).value(), 2)
        // 越界值回退到第一个构造器
        @Assert(Color.fromValue(999).value(), 0)
    }

    @TestCase
    func enumToJson(): Unit {
        @Assert(Color.Red.toJson(), "0")
        @Assert(Color.Green.toJson(), "1")
        @Assert(Color.Blue.toJson(), "2")
    }

    @TestCase
    func enumFromJson(): Unit {
        @Assert(Color.fromJson("2").value(), 2)
        @Assert(Color.fromJson("0").value(), 0)
    }

    @TestCase
    func manualEnumJson(): Unit {
        @Assert(Size.Small.toJson(), "10")
        @Assert(Size.Medium.toJson(), "20")
        @Assert(Size.Large.toJson(), "30")
        @Assert(Size.fromJson("30").value(), 30)
        @Assert(Size.fromJson("99").value(), 10)
    }

    @TestCase
    func classWithEnumField(): Unit {
        let p = Product()
        p.name = "Test"
        p.color = Color.Green
        p.size = Size.Large
        const expect = #"{"name":"Test","color":1,"size":30}"#
        @Assert(p.toJson(), expect)

        let p2 = Product.fromJson(expect)
        @Assert(p2.name, "Test")
        @Assert(p2.color.value(), Color.Green.value())
        @Assert(p2.size.value(), Size.Large.value())
    }
}
