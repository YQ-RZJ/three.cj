/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected macro package three._vendor.fastjson.macros

import std.ast.*
import std.collection.*

class HandleStruct {
    private let sd: StructDecl
    private var structName: Tokens
    private let allFields = ArrayList<FieldInfo>()

    private var withGenericType: Bool = false
    private var genericType: Tokens = Tokens()

    public init(sd: StructDecl) {
        this.sd = sd
        this.structName = this.sd.identifier.toTokens()

        if (this.sd.isGenericDecl) {
            this.structName += this.sd.genericParam.toTokens()
        }
    }

    private func handleAttr(attr: Tokens): Unit {
        if (attr.size == 0) {
            return
        }
        var offset: Int64 = 0
        while (offset < attr.size) {
            try {
                let (expr, off) = parseExprFragment(attr, startFrom: offset)
                match (expr) {
                    case ae: AssignExpr =>
                        let key = ae.leftExpr.toTokens().toString()
                        let value = ae.rightExpr
                        if (key == JsonAdapterClassAttr.WITH_GENERIC_TYPE) {
                            if (value.toTokens().size != 1) {
                                diagReport(DiagReportLevel.ERROR, value.toTokens(),
                                    "only one generic type is allowed",
                                    "only one generic type is allowed")
                            }
                            this.withGenericType = true
                            this.genericType = value.toTokens()
                        } else {
                            diagReport(DiagReportLevel.ERROR, key.toTokens(),
                            "only ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} is supported for struct type",
                            "only ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} is supported for struct type")
                        }
                    case _ =>
                        diagReport(DiagReportLevel.ERROR, expr.toTokens(),
                            "only ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} is supported for struct type",
                            "only ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} is supported for struct type")
                }
                offset = off
            } catch (e: ParseASTException) {
                diagReport(DiagReportLevel.ERROR, attr,
                    "attributes is illegal, it should looks like [${JsonAdapterClassAttr.WITH_GENERIC_TYPE} = T]",
                    "attributes is illegal")
                break
            }
        }
    }
    private func handleGenericType(): Unit {
        if (!withGenericType) {
            return
        }

        if (!this.sd.isGenericDecl) {
            diagReport(DiagReportLevel.ERROR, this.sd.identifier.toTokens(),
                "expect to be a generic struct type when using `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute",
                "expect to be a generic struct")
            return
        }

        let gpTokens = this.sd.genericParam.parameters.toTokens()
        if (gpTokens.size != 1) {
            diagReport(DiagReportLevel.ERROR, gpTokens,
                "can only have one generic param",
                "can only have one generic param")
            return
        }

        let gp = gpTokens.get(0)
        if (gp.toTokens().toString() != genericType.toString()) {
            diagReport(DiagReportLevel.ERROR, gpTokens,
                "generic param is inconsistent with `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute",
                "generic param is inconsistent with `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute")
            return
        }

        let gcList = this.sd.genericConstraint
        let gc = GenericConstraint()
        gc.keyword = Token(TokenKind.WHERE)
        gc.typeArgument = RefType(genericType)
        gc.upperBounds.add(RefType(quote(IStreamJsonAdapter<T>)))

        if (gcList.size == 0) {
            this.sd.genericConstraint.add(gc)
        } else {
            var hasAdd = false
            for (item in gcList) {
                let ta = item.typeArgument
                if (ta.toTokens().toString() == genericType.toString()) {
                    for (value in item.upperBounds) {
                        match(value) {
                            case rt: RefType =>
                                if (rt.identifier.toTokens().toString() == "IStreamJsonAdapter") {
                                    hasAdd = true
                                    break
                                }
                            case _ => ()
                        }
                    }
                    if (!hasAdd) {
                        item.upperBounds.add(RefType(quote(IStreamJsonAdapter<T>)))
                        hasAdd = true
                    }
                }
            }
            if (!hasAdd) {
                this.sd.genericConstraint.add(gc)
            }
        }
    }

    private func handleSuperTypes() {
        let refType = RefType(quote(IStreamJsonAdapter<$(structName)>))
        var hasAdded = false
        for (item in sd.superTypes) {
            if (item.toTokens().toString() == refType.toTokens().toString()) {
                hasAdded = true
                break
            }
        }
        if (!hasAdded) {
            sd.superTypes.add(refType)
        }
    }


    private func createfromStreamJsonFunc(): FuncDecl {
        var funcBody = Tokens()
        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let identifier = field.vd.identifier
            let jsonName = field.getJsonName()
            let typeInfo = field.vd.declType
            // let fieldName = identifier.toTokens().toString()
            let baseType = getOptionBaseType(typeInfo)

            let assignExpr = if (isOptionType(typeInfo)) {
                if (isOptionAnyType(typeInfo)) {
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForOptionAny(jsonReader)
                    )
                } else {
                    quote(
                        case $jsonName  => obj.$identifier = jsonReader.readValue<Option<$baseType>>()
                    )
                }
            } else {
                if (isAnyType(typeInfo)) {
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForAny(jsonReader)
                    )
                } else if (isSeqListAnyTypeForStream(typeInfo)) {
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForListAny(jsonReader)
                    )
                } else if (isMapAnyTypeForStream(typeInfo)) {
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForHashMapAny(jsonReader)
                    )
                } else if (isSeqArrayAnyTypeForStream(typeInfo)) {
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForArryAny(jsonReader)
                    )
                } else {
                    quote(
                        case $jsonName  => obj.$identifier = jsonReader.readValue<$baseType>()
                    )
                }
            }
            funcBody.append(assignExpr)
        }

            funcBody.append(quote(
                case _ => jsonReader.skip()
            ))

        return FuncDecl(
            quote(
            public static func fromJson(jsonReader: JsonStreamReader): $structName {
                var obj = $structName()
                jsonReader.startObject()
                while (let Some(v) <- jsonReader.peek()) {
                    if(v != JsonStreamEndObject) {
                        let readfiledName = jsonReader.readName()
                        match (readfiledName) {
                            $funcBody
                        }
                    } else {
                        break
                    }
                }
                jsonReader.endObject()
                return obj
            }
        ))
    }


    private func createToStreamJsonFunc(): FuncDecl {
        var funcBody = Tokens()

        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let jsonName = field.getJsonName()
            let typeInfo = field.vd.declType

            if (field.isIgnoreNull && isOptionType(typeInfo)) {
                funcBody.append(
                    quote(
                        if (let Some(v) <- $(field.vd.identifier)) {
                            jsonWriter.writeName($(jsonName))
                            JsonUtil.toModelStream($(field.vd.identifier), jsonWriter)
                            // $(field.vd.identifier).toJson(jsonWriter)
                        }
                    ))
            } else {
                if (isOptionType(typeInfo) || isAnyType(typeInfo) || isSeqListAnyTypeForStream(typeInfo) ||
                    isMapAnyTypeForStream(typeInfo)) {
                    funcBody.append(
                        quote(
                                jsonWriter.writeName($(jsonName))
                                JsonUtil.toModelStream($(field.vd.identifier), jsonWriter)
                            ))
                } else if (isSeqArrayAnyTypeForStream(typeInfo)) {
                    funcBody.append(
                        quote(
                                jsonWriter.writeName($(jsonName))
                                JsonUtil.toModelStream($(field.vd.identifier), jsonWriter)
                            ))
                } else {
                    funcBody.append(
                        quote(
                                jsonWriter.writeName($(jsonName))
                                $(field.vd.identifier).toJson(jsonWriter)
                            ))
                }
            }
        }
        return FuncDecl(
            quote(
                public func toJson(jsonWriter: JsonStreamWriter): Unit {
                    jsonWriter.startObject()
                    $funcBody
                    jsonWriter.endObject()
                }
            ))
    }


    private func createToStreamJson(): FuncDecl {
        return FuncDecl(
            quote(
            public func toJson(): String {
                let stream = ByteBuffer()
                var writer = JsonStreamWriter(stream)
                toJson(writer)
                writer.flush()
                return String.fromUtf8(readToEnd(stream))
            }
        ))
    }

    private func createfromStreamJson(): FuncDecl {
        return FuncDecl(
            quote(
        public static func fromJson(str: String): $structName {
            fromJson(JsonStreamReader(ByteBuffer(str.toArray())))
        }
    ))
    }



    public func doExpend(attr: Tokens): Tokens {
        handleAttr(attr)
        handleGenericType()
        handleSuperTypes()
        for (decl in sd.body.decls) {
            match (decl) {
                case vd: VarDecl =>
                    let field = FieldInfo(vd)
                    if (field.isStatic && !field.isIgnore) {
                        diagReport(DiagReportLevel.ERROR, vd.toTokens(),
                            "`static` member variable must use @JsonIgnore",
                            "must use @JsonIgnore")
                    }
                    this.allFields.add(field)
                case _ => ()
            }
        }

        sd.body.decls.add(createfromStreamJsonFunc())
        sd.body.decls.add(createToStreamJsonFunc())
        sd.body.decls.add(createToStreamJson())
        sd.body.decls.add(createfromStreamJson())

        return sd.toTokens()
    }
}