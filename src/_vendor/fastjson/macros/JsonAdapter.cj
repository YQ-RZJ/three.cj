/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected macro package three._vendor.fastjson.macros

import std.ast.*

// @JsonAdapter 修饰 class 时允许使用的属性
class JsonAdapterClassAttr {
    public static const WITH_SUPER_CLASS = "withSuperClass"
    public static const WITH_GENERIC_TYPE = "withGenericType"
    // 多态根：反序列化时先扫描 JSON 中的 "kind" 字段，按注册表分发到具体子类
    public static const POLYMORPHIC = "polymorphic"
    // 是否忽略私有成员（默认 false，指定 ignorePrivate = true 后忽略）
    public static const IGNORE_PRIVATE = "ignorePrivate"

    public static func availableAttrs(): String {
        return "[${WITH_SUPER_CLASS}, ${WITH_GENERIC_TYPE}, ${POLYMORPHIC}, ${IGNORE_PRIVATE}]"
    }
}

public macro JsonAdapter(attr: Tokens, input: Tokens): Tokens {
    return jsonAdapterImpl(attr, input)
}

public macro JsonAdapter(input: Tokens): Tokens {
    return jsonAdapterImpl(Tokens(), input)
}

func jsonAdapterImpl(attr: Tokens, input: Tokens): Tokens {
    var ret = input
    let decl = parseDecl(input)
    match (decl) {
        case cd: ClassDecl => ret = HandleClass(cd).doExpend(attr)
        case ed: EnumDecl => ret = HandleEnum(ed).doExpend(attr)
        case sd: StructDecl => ret = HandleStruct(sd).doExpend(attr)
        case _ => diagReport(DiagReportLevel.ERROR, input, "Can only be used on ClassDecl or EnumDecl",
            "Expected ClassDecl or EnumDecl")
    }
    
    GlobalInfo.current().reset()

    return ret
}
