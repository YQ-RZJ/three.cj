/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
 protected macro package three._vendor.fastjson.macros

import std.ast.*

public macro JsonIgnoreNull(input: Tokens): Tokens {
    assertParentContext("JsonAdapter")

    let decl = parseDecl(input)
    match (decl) {
        case vd: VarDecl => GlobalInfo.current().setJsonIgnoreNull(vd.identifier.value)
        case _ => diagReport(DiagReportLevel.ERROR, input, "Can only be used on VarDecl", "Expected VarDecl")
    }

    return input
}
