/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

protected macro package three._vendor.fastjson.macros

import std.ast.*

class HandleEnum {
    public HandleEnum(let ed: EnumDecl) {}

    private func hasValueMethod(): Bool {
        for (decl in this.ed.decls) {
            match (decl) {
                case fd: FuncDecl =>
                    if (fd.identifier.value == "value" && !isStaticFunc(fd) && fd.funcParams.size == 0) {
                        return true
                    }
                case _ => ()
            }
        }
        return false
    }

    private func hasFromValueMethod(): Bool {
        for (decl in this.ed.decls) {
            match (decl) {
                case fd: FuncDecl =>
                    if (fd.identifier.value == "fromValue" && isStaticFunc(fd) && fd.funcParams.size == 1) {
                        return true
                    }
                case _ => ()
            }
        }
        return false
    }

    private func hasEnumNumAnnotation(): Bool {
        for (ann in this.ed.annotations) {
            if (ann.identifier.value == "EnumNum") {
                return true
            }
        }
        return false
    }

    private func isStaticFunc(fd: FuncDecl): Bool {
        for (mod in fd.modifiers) {
            if (mod.toTokens().toString() == "static") {
                return true
            }
        }
        return false
    }

    private func checkValueAndFromValue(attr: Tokens): Bool {
        let hasValue = hasValueMethod()
        let hasFromValue = hasFromValueMethod()
        if (hasValue && hasFromValue) {
            return true
        }

        // 如果存在 @EnumNum 注解，则认为 value/fromValue 会由该宏生成
        if (hasEnumNumAnnotation()) {
            return true
        }

        let diagTokens = if (attr.size > 0) {
            attr
        } else {
            this.ed.identifier.toTokens()
        }
        if (!hasValue && !hasFromValue) {
            diagReport(DiagReportLevel.ERROR, diagTokens,
                "enum must provide value() and static fromValue(Int64) methods for JSON serialization; consider using @EnumNum",
                "missing value() and fromValue(Int64)")
        } else if (!hasValue) {
            diagReport(DiagReportLevel.ERROR, diagTokens,
                "enum must provide value() method for JSON serialization; consider using @EnumNum", "missing value()")
        } else {
            diagReport(DiagReportLevel.ERROR, diagTokens,
                "enum must provide static fromValue(Int64) method for JSON serialization; consider using @EnumNum",
                "missing fromValue(Int64)")
        }
        return false
    }

    private func handleSuperTypes(): Unit {
        let enumName = this.ed.identifier.toTokens()
        let refType = RefType(quote(IStreamJsonAdapter<$(enumName)>))
        var hasAdded = false
        for (item in this.ed.superTypes) {
            if (item.toTokens().toString() == refType.toTokens().toString()) {
                hasAdded = true
                break
            }
        }
        if (!hasAdded) {
            this.ed.superTypes.add(refType)
        }
    }

    private func createToStreamJsonFunc(): FuncDecl {
        let enumName = this.ed.identifier.toTokens()
        return FuncDecl(
            quote(
            public func toJson(jsonWriter: JsonStreamWriter): Unit {
                this.value().toJson(jsonWriter)
            }
        ))
    }

    private func createfromStreamJsonFunc(): FuncDecl {
        let enumName = this.ed.identifier.toTokens()
        return FuncDecl(
            quote(
            public static func fromJson(jsonReader: JsonStreamReader): $(enumName) {
                return $(enumName).fromValue(jsonReader.readValue<Int64>())
            }
        ))
    }

    public func doExpend(attr: Tokens): Tokens {
        if (attr.size > 0) {
            diagReport(DiagReportLevel.ERROR, attr, "@JsonAdapter does NOT support attributes for EnumDecl",
                "attributes not supported for Enum")
        }

        if (!checkValueAndFromValue(attr)) {
            return this.ed.toTokens()
        }

        handleSuperTypes()

        this.ed.decls.add(createfromStreamJsonFunc())
        this.ed.decls.add(createToStreamJsonFunc())

        return this.ed.toTokens()
    }
}
