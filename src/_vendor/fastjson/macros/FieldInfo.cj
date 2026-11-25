/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected macro package three._vendor.fastjson.macros

import std.ast.*
// import std.collection.*

/**
 * 字段信息：同时支持 VarDecl（成员变量）与 PropDecl（成员属性）。
 * 接口/父类中声明的抽象 prop 在实现类中通常以 `mut prop` + backing field 的形式实现，
 * 因此宏需要能够识别 prop 成员参与序列化，backing field 通过 @JsonIgnore 排除。
 */
class FieldInfo {
    public let vd: VarDecl
    public let pd: PropDecl
    public let isProp: Bool
    public var isIgnore: Bool = false
    public var isIgnoreNull: Bool = false
    public var jsonName: ?String = None
    public var typeNode: ?TypeNode = None

    public var isPrivate: Bool = false
    public var isStatic: Bool = false

    public init(vd: VarDecl) {
        this.vd = vd
        this.pd = PropDecl()
        this.isProp = false
        initFieldInfoCommon(this, vd.identifier, vd.declType, vd.modifiers)
    }

    public init(pd: PropDecl) {
        this.vd = VarDecl()
        this.pd = pd
        this.isProp = true
        initFieldInfoCommon(this, pd.identifier, pd.declType, pd.modifiers)
    }

    /// 统一访问成员类型（var 或 prop 的声明类型）
    public prop declType: TypeNode {
        get() { if (this.isProp) { this.pd.declType } else { this.vd.declType } }
    }

    /// 统一访问成员标识符
    public prop identifier: Token {
        get() { if (this.isProp) { this.pd.identifier } else { this.vd.identifier } }
    }

    /// 统一访问成员修饰符
    public prop modifiers: ArrayList<Modifier> {
        get() { if (this.isProp) { this.pd.modifiers } else { this.vd.modifiers } }
    }

    /// 成员所在节点（用于诊断报告定位）
    public func declTokens(): Tokens {
        if (this.isProp) { this.pd.toTokens() } else { this.vd.toTokens() }
    }

    public func getJsonName(): String {
        if (let Some(v) <- jsonName) {
            return v
        } else {
            unwrapRawIdentifier(this.identifier)
        }
    }
}

/// VarDecl 与 PropDecl 共用的字段初始化逻辑
func initFieldInfoCommon(field: FieldInfo, identifier: Token, declType: TypeNode,
    modifiers: ArrayList<Modifier>): Unit {
    let identifierString = identifier.value
    field.isIgnore = GlobalInfo.current().isJsonIgnore(identifierString)
    field.isIgnoreNull = GlobalInfo.current().isJsonIgnoreNull(identifierString)
    field.jsonName = GlobalInfo.current().getJsonName(identifierString)
    if (!field.isIgnore) {
        try {
            field.typeNode = declType
        } catch (e: ASTException) {
            diagReport(DiagReportLevel.ERROR, identifier.toTokens(),
                "filed without @JsonIgnore must explicitly declare its type", "must explicitly declare its type")
        }
    }
    for (mod in modifiers) {
        match (mod.toTokens().toString()) {
            case "private" => field.isPrivate = true
            case "static" => field.isStatic = true
            case _ => ()
        }
    }
}
