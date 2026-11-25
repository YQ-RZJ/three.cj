protected macro package three._vendor.fastjson.macros

import std.ast.*
import std.collection.ArrayList

/**
 * @EnumNum 用于为 enum 自动生成 value() 与 fromValue(v: Int64) 两个成员方法。
 *
 * 生成规则：
 * - 按照 enum 构造器在源码中出现的顺序，从 0 开始依次编号；
 * - value() 返回当前枚举值对应的 Int64 编号；
 * - fromValue(v: Int64) 根据编号反查枚举值，若 v 不在有效范围内则返回第一个构造器；
 * - 仅支持无参构造器（无 payload），若存在带参构造器会报错。
 *
 * 用法示例：
 * ```cangjie
 * @EnumNum
 * public enum Color {
 *     | Red
 *     | Green
 *     | Blue
 * }
 * ```
 */
public macro EnumNum(input: Tokens): Tokens {
    let decl = parseDecl(input)
    let enumDecl = match (decl as EnumDecl) {
        case Some(value) => value
        case None =>
            diagReport(DiagReportLevel.ERROR, input, "@EnumNum can only be used on enum declaration",
                "expected enum declaration")
            return input
    }

    let enumName = enumDecl.identifier
    let constructors = enumDecl.constructors

    // 过滤掉 `...` 这种未命名构造器
    let validConstructors = ArrayList<Constructor>()
    for (ctor in constructors) {
        if (ctor.identifier.value == "...") {
            continue
        }
        if (ctor.typeArguments.size > 0) {
            diagReport(DiagReportLevel.ERROR, ctor.toTokens(), "@EnumNum does not support constructor with payload",
                "constructor with payload is not allowed")
            return input
        }
        validConstructors.add(ctor)
    }

    if (validConstructors.size == 0) {
        diagReport(DiagReportLevel.ERROR, input, "@EnumNum requires at least one named constructor",
            "no valid constructor found")
        return input
    }

    // 生成 value() 方法体中的 match case
    var valueMatchBody = Tokens()
    for (i in 0..validConstructors.size) {
        let ctor = validConstructors[i]
        let ctorName = ctor.identifier
        let indexToken = Token(TokenKind.INTEGER_LITERAL, "${i}")
        valueMatchBody = quote(
            $(valueMatchBody)
            case $ctorName => $(indexToken)
        )
    }

    // 生成 fromValue(v: Int64) 方法体中的 match case
    var fromValueMatchBody = Tokens()
    for (i in 0..validConstructors.size) {
        let ctor = validConstructors[i]
        let ctorName = ctor.identifier
        let indexToken = Token(TokenKind.INTEGER_LITERAL, "${i}")
        fromValueMatchBody = quote(
            $(fromValueMatchBody)
            case $(indexToken) => $ctorName
        )
    }

    // 默认返回第一个构造器
    let firstCtor = validConstructors[0].identifier

    let valueMethod = parseDecl(
        quote(
        public func value(): Int64 {
            match (this) {
                $(valueMatchBody)
            }
        }
    ))

    let fromValueMethod = parseDecl(
        quote(
        public static func fromValue(v: Int64): $(enumName) {
            match (v) {
                $(fromValueMatchBody)
                case _ => $firstCtor
            }
        }
    ))

    enumDecl.decls.add(valueMethod)
    enumDecl.decls.add(fromValueMethod)

    return enumDecl.toTokens()
}
