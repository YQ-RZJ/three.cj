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

class HandleClass {
    private let cd: ClassDecl
    private var className: Tokens
    private let allFields = ArrayList<FieldInfo>()
    private var withSuperClass: Bool = false
    private var superClass: Tokens = Tokens()
    private var withGenericType: Bool = false
    private var genericType: Token = Token()
    private var isOpen: Bool = false
    // 多态根：fromJson 时按 JSON 中的 "kind" 字段分发到具体子类
    private var polymorphic: Bool = false
    // 类自身未声明 kind 成员时，由宏自动生成 kind prop / 序列化字段 / 多态登记
    private var autoKind: Bool = false
    // 是否忽略私有成员（默认 false，指定 ignorePrivate = true 后忽略）
    private var ignorePrivate: Bool = false
    public init(cd: ClassDecl) {
        this.cd = cd
        this.className = if (this.cd.isGenericDecl) {
            this.cd.identifier.toTokens() + this.cd.genericParam.toTokens()
        } else {
            this.cd.identifier.toTokens()
        }

        for (item in cd.modifiers) {
            if (item.toTokens().toString() == "open") {
                this.isOpen = true
                break
            }
        }
    }

    private func handleSuperTypes() {
        let refTypeStream = RefType(quote(IStreamJsonAdapter<$(className)>))
        var hasAddedStream = false
        for (item in cd.superTypes) {
            if (item.toTokens().toString() == refTypeStream.toTokens().toString()) {
                hasAddedStream = true
            }
        }
        if (!hasAddedStream) {
            cd.superTypes.add(refTypeStream)
        }
    }

    private func createToStreamJsonFunc(): FuncDecl {
        let openModifier = if (isOpen) {
            quote(open)
        } else {
            quote()
        }
        var funcBody = Tokens()

        // 多态类型判别字段：始终作为第一个成员写入，值为类名
        if (autoKind) {
            let kindLiteral = cd.identifier.toTokens().toString()
            funcBody.append(
                quote(
                    jsonWriter.writeName("kind")
                    $(kindLiteral).toJson(jsonWriter)
                ))
        }

        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let jsonName = field.getJsonName()
            let typeInfo = field.declType

            if (field.isIgnoreNull && isOptionType(typeInfo)) {
                if (isOptionAnyType(typeInfo)) {
                    funcBody.append(
                        quote(
                            if (let Some(v) <- $(field.identifier)) {
                                jsonWriter.writeName($(jsonName))
                                JsonUtil.toModelStream($(field.identifier), jsonWriter)
                            }
                        ))
                } else {
                    funcBody.append(
                        quote(
                            if (let Some(v) <- $(field.identifier)) {
                                jsonWriter.writeName($(jsonName))
                                v.toJson(jsonWriter)
                            }
                        ))
                }
            } else {
                if (isAnyType(typeInfo) || isOptionAnyType(typeInfo) || isSeqListAnyTypeForStream(typeInfo) ||
                    isMapAnyTypeForStream(typeInfo)) {
                    funcBody.append(
                        quote(
                                jsonWriter.writeName($(jsonName))
                                JsonUtil.toModelStream($(field.identifier), jsonWriter)
                            ))
                } else if (isSeqArrayAnyTypeForStream(typeInfo)) {
                    funcBody.append(
                        quote(
                                jsonWriter.writeName($(jsonName))
                                JsonUtil.toModelStream($(field.identifier), jsonWriter)
                            ))
                } else {
                    funcBody.append(
                        quote(
                                jsonWriter.writeName($(jsonName))
                                $(field.identifier).toJson(jsonWriter)
                            ))
                }
            }
        }

        if (withSuperClass) {
            funcBody.append(quote(
                    super.toStreamJsonInherit(jsonWriter)
                ))
        }

        // @JsonCustom 自定义序列化字段
        for (field in allFields) {
            if (!field.isIgnore) {
                continue
            }
            let fieldJsonName = field.getJsonName()
            let customProp = GlobalInfo.current().getJsonCustom(fieldJsonName)
            if (let Some(propName) <- customProp) {
                let propToken = Token(TokenKind.IDENTIFIER, propName)
                funcBody.append(
                    quote(
                        jsonWriter.writeName($(fieldJsonName))
                        this.$propToken.toJson(jsonWriter)
                    ))
            }
        }
        return FuncDecl(
            quote(
                public $openModifier func toJson(jsonWriter: JsonStreamWriter): Unit {
                    jsonWriter.startObject()
                    $funcBody
                    jsonWriter.endObject()
                }
            ))
    }
    private func createToStreamJsonInheritFunc(): FuncDecl {
        var funcBody = Tokens()

        if (withSuperClass) {
            funcBody.append(quote(
                super.toStreamJsonInherit(jsonWriter)
            ))
        }

        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let jsonName = field.getJsonName()
            let typeInfo = field.declType
            if (field.isIgnoreNull && isOptionType(field.declType)) {
                if (isOptionAnyType(field.declType)) {
                    funcBody.append(
                        quote(
                        if (let Some(v) <- $(field.identifier)) {
                            jsonWriter.writeName($(jsonName))
                            JsonUtil.toModelStream($(field.identifier), jsonWriter)
                        }
                    ))
                } else {
                    funcBody.append(
                        quote(
                        if (let Some(v) <- $(field.identifier)) {
                            jsonWriter.writeName($(jsonName))
                            v.toJson(jsonWriter)
                        }
                    ))
                }
            } else {
                if (isAnyType(typeInfo) || isOptionAnyType(typeInfo) || isSeqListAnyTypeForStream(typeInfo) ||
                    isMapAnyTypeForStream(typeInfo)) {
                    funcBody.append(
                        quote(
                            jsonWriter.writeName($(jsonName))
                            JsonUtil.toModelStream($(field.identifier), jsonWriter)
                        ))
                } else if (isSeqArrayAnyTypeForStream(typeInfo)) {
                    funcBody.append(
                        quote(
                            jsonWriter.writeName($(jsonName))
                            JsonUtil.toModelStream($(field.identifier), jsonWriter)
                        ))
                } else {
                    funcBody.append(
                        quote(
                            jsonWriter.writeName($(jsonName))
                            $(field.identifier).toJson(jsonWriter)
                        ))
                }
            }
        }

        // @JsonCustom 自定义序列化字段（继承版本）
        for (field in allFields) {
            if (!field.isIgnore) {
                continue
            }
            let fieldJsonName = field.getJsonName()
            let customProp = GlobalInfo.current().getJsonCustom(fieldJsonName)
            if (let Some(propName) <- customProp) {
                let propToken = Token(TokenKind.IDENTIFIER, propName)
                funcBody.append(
                    quote(
                        jsonWriter.writeName($(fieldJsonName))
                        this.$propToken.toJson(jsonWriter)
                    ))
            }
        }

        let openModifier = if (isOpen) {
            quote(open)
        } else {
            quote()
        }

        return FuncDecl(
            quote(
            public $openModifier func toStreamJsonInherit(jsonWriter: JsonStreamWriter): Unit {
                $funcBody
            }
        ))
    }

    private func createfromStreamJsonFunc(): FuncDecl {
        var funcBody = Tokens()
        // 多态判别字段：宏自动生成，反序列化时消费丢弃（类型已由分发逻辑确定）
        if (autoKind) {
            funcBody.append(
                quote(
                    case "kind" => jsonReader.readValue<String>()
                ))
        }
        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let identifier = field.identifier
            let jsonName = field.getJsonName()
            let typeInfo = field.declType
            let fieldName = identifier.toTokens().toString()
            let baseType = getOptionBaseType(typeInfo)
            // let baseTypeStr = baseType.toString()

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
                } else if (isHashSetType(typeInfo)) {
                    let elementType = getHashSetBaseType(typeInfo)
                    quote(
                        case $jsonName  => obj.$identifier = jsonReader.readValue<HashSet<$elementType>>()
                    )
                } else if (isSeqListType(typeInfo)) {
                    let elementType = getSeqListBaseType(typeInfo)
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForList<$elementType>(jsonReader)
                    )
                } else if (isMapAnyTypeForStream(typeInfo)) {
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForHashMapAny(jsonReader)
                    )
                } else if (isSeqArrayAnyTypeForStream(typeInfo)) {
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForArryAny(jsonReader)
                    )
                } else if (isArrayType(typeInfo)) {
                    let elementType = getArrayBaseType(typeInfo)
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForArray<$elementType>(jsonReader)
                    )
                } else {
                    quote(case $jsonName  => obj.$identifier = jsonReader.readValue<$baseType>())
                }
            }
            funcBody.append(assignExpr)
        }

        // @JsonCustom 自定义反序列化字段
        for (field in allFields) {
            if (!field.isIgnore) {
                continue
            }
            let fieldJsonName = field.getJsonName()
            let customProp = GlobalInfo.current().getJsonCustom(fieldJsonName)
            if (let Some(propName) <- customProp) {
                let propToken = Token(TokenKind.IDENTIFIER, propName)
                funcBody.append(
                    quote(
                        case $(fieldJsonName) => obj.$propToken = jsonReader.readValue<String>()
                    ))
            }
        }

        if (withSuperClass) {
            funcBody.append(
                quote(
                case _ => $superClass.fromStreamJsonInherit(obj, readfiledName, jsonReader)
            ))
        } else {
            funcBody.append(quote(
                case _ => jsonReader.skip()
            ))
        }

        return FuncDecl(
            quote(
            public static func fromJsonConcrete(jsonReader: JsonStreamReader): $className {
                var obj = $className()
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

    /**
     * @brief[zh-cn] 生成对外 fromJson：多态根按 kind 分发，非根直接委托 fromJsonConcrete
     */
    private func createFromJsonDispatchFunc(): FuncDecl {
        if (!polymorphic) {
            return FuncDecl(
                quote(
                public static func fromJson(jsonReader: JsonStreamReader): $className {
                    fromJsonConcrete(jsonReader)
                }
            ))
        }
        return FuncDecl(
            quote(
            public static func fromJson(jsonReader: JsonStreamReader): $className {
                // 先捕获整个 JSON 对象，扫描其中的 kind 判别字段
                let bytes = jsonReader.readValueBytes()
                var kindName = ""
                let probe = JsonStreamReader(ByteBuffer(bytes))
                probe.startObject()
                while (let Some(t) <- probe.peek()) {
                    if (t != JsonStreamEndObject) {
                        let memberName = probe.readName()
                        if (memberName == "kind") {
                            kindName = probe.readValue<String>()
                        } else {
                            probe.skip()
                        }
                    } else {
                        break
                    }
                }
                // 按 kind 查注册表分发到具体子类；未登记或类型不匹配时回退本类读取
                match (JsonPolymorphicRegistry.create(kindName, JsonStreamReader(ByteBuffer(bytes)))) {
                    case Some(v) => match (v) {
                        case obj: $className => obj
                        case _ => $className.fromJsonConcrete(JsonStreamReader(ByteBuffer(bytes)))
                    }
                    case None => $className.fromJsonConcrete(JsonStreamReader(ByteBuffer(bytes)))
                }
            }
        ))
    }

    /**
     * @brief[zh-cn] 生成自动 kind prop 与多态注册表静态登记字段
     */
    private func createKindMembers(): ArrayList<Decl> {
        let members = ArrayList<Decl>()
        if (!autoKind) {
            return members
        }
        let kindLiteral = cd.identifier.toTokens().toString()
        let pos = cd.identifier.pos
        let seed = "jsonKindReg:${kindLiteral}:${pos.fileID}:${pos.line}:${pos.column}"
        let h = seed.hashCode() & 0x7FFFFFFFFFFFFFFF
        let regField = Token(TokenKind.IDENTIFIER, "_jsonKindReg_${kindLiteral}_${h}")
        let openModifier = if (isOpen) {
            quote(open)
        } else {
            quote()
        }
        // 使用 mut prop 避免 immutable 错误；继承链上子类 override 根类的 open prop
        let kindProp = if (withSuperClass) {
            quote(
                public $openModifier override mut prop kind: String {
                    get() { $(kindLiteral) }
                    set(v) { }
                }
            )
        } else {
            quote(
                public $openModifier mut prop kind: String {
                    get() { $(kindLiteral) }
                    set(v) { }
                }
            )
        }
        let regDecl = quote(
            private static var $(regField): Bool =
                JsonPolymorphicRegistry.register($(kindLiteral), { r =>
                    let v: Any = $className.fromJsonConcrete(r)
                    v
                })
        )
        let ensureDecl = quote(
            public static func ensureJsonRegistered(): Unit {
                _ = $(regField)
            }
        )
        members.add(parseDecl(kindProp))
        members.add(parseDecl(regDecl))
        members.add(parseDecl(ensureDecl))
        members
    }

    private func createFromStreamJsonInheritFunc(): FuncDecl {
        var funcBody = Tokens()
        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let identifier = field.identifier
            let jsonName = field.getJsonName()
            let typeInfo = field.declType
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
                } else if (isHashSetType(typeInfo)) {
                    let elementType = getHashSetBaseType(typeInfo)
                    quote(
                        case $jsonName  => obj.$identifier = jsonReader.readValue<HashSet<$elementType>>()
                    )
                } else if (isSeqListType(typeInfo)) {
                    let elementType = getSeqListBaseType(typeInfo)
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForList<$elementType>(jsonReader)
                    )
                } else if (isMapAnyTypeForStream(typeInfo)) {
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForHashMapAny(jsonReader)
                    )
                } else if (isSeqArrayAnyTypeForStream(typeInfo)) {
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForArryAny(jsonReader)
                    )
                } else if (isArrayType(typeInfo)) {
                    let elementType = getArrayBaseType(typeInfo)
                    quote(
                        case $jsonName  => obj.$identifier = JsonUtil.streamFromJsonForArray<$elementType>(jsonReader)
                    )
                } else {
                    quote(
                        case $jsonName  => obj.$identifier = jsonReader.readValue<$baseType>()
                    )
                }
            }

            funcBody.append(assignExpr)
        }

        // @JsonCustom 自定义反序列化字段（继承版本）
        for (field in allFields) {
            if (!field.isIgnore) {
                continue
            }
            let fieldJsonName = field.getJsonName()
            let customProp = GlobalInfo.current().getJsonCustom(fieldJsonName)
            if (let Some(propName) <- customProp) {
                let propToken = Token(TokenKind.IDENTIFIER, propName)
                funcBody.append(
                    quote(
                        case $(fieldJsonName) => obj.$propToken = jsonReader.readValue<String>()
                    ))
            }
        }

        if (withSuperClass) {
            funcBody.append(
                quote(
                case _ => $superClass.fromStreamJsonInherit(obj, filedName, jsonReader)
            ))
        } else {
            funcBody.append(quote(
                case _ => jsonReader.skip()
            ))
        }

        return FuncDecl(
            quote(
            public static func fromStreamJsonInherit(obj: $className, filedName: String, jsonReader: JsonStreamReader): Unit {
                match (filedName) {
                    $funcBody
                }
            }
        ))
    }

    private func createToStreamJson(): FuncDecl {
        let openModifier = if (isOpen) {
            quote(open)
        } else {
            quote()
        }
        return FuncDecl(
            quote(
            public $openModifier func toJson(): String {
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
        public static func fromJson(str: String): $className {
            fromJson(JsonStreamReader(ByteBuffer(str.toArray())))
        }
    ))
    }

    private func handleAttr(attr: Tokens): Unit {
        if (attr.size == 0) {
            return
        }
        var offset: Int64 = 0
        while (offset < attr.size) {
            try {
                let (expr, off) = parseExprFragment(attr, startFrom: offset)
                // expr.dump()
                match (expr) {
                    case ae: AssignExpr =>
                        let key = ae.leftExpr.toTokens().toString()
                        let value = ae.rightExpr
                        if (key == JsonAdapterClassAttr.WITH_SUPER_CLASS) {
                            this.withSuperClass = true
                            this.superClass = value.toTokens()
                        } else if (key == JsonAdapterClassAttr.WITH_GENERIC_TYPE) {
                            if (value.toTokens().size != 1) {
                                diagReport(DiagReportLevel.ERROR, value.toTokens(), "only one generic type is allowed",
                                    "only one generic type is allowed")
                            }
                            this.withGenericType = true
                            this.genericType = value.toTokens().get(0)
                        } else if (key == JsonAdapterClassAttr.POLYMORPHIC) {
                            this.polymorphic = value.toTokens().toString() == "true"
                        } else if (key == JsonAdapterClassAttr.IGNORE_PRIVATE) {
                            this.ignorePrivate = value.toTokens().toString() == "true"
                        } else {
                            diagReport(DiagReportLevel.ERROR, key.toTokens(),
                                "Unknown key, it should be one of ${JsonAdapterClassAttr.availableAttrs()}",
                                "Unknown key, it should be one of ${JsonAdapterClassAttr.availableAttrs()}")
                        }
                    case _ => diagReport(DiagReportLevel.ERROR, expr.toTokens(),
                        "expect AssignExpr, and key should be one of ${JsonAdapterClassAttr.availableAttrs()}",
                        "expect AssignExpr, and key should be one of ${JsonAdapterClassAttr.availableAttrs()}")
                }
                offset = off
            } catch (e: ParseASTException) {
                diagReport(DiagReportLevel.ERROR, attr,
                    "attributes is illegal, it should looks like [${JsonAdapterClassAttr.WITH_SUPER_CLASS} = Xxx; ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} = T]",
                    "attributes is illegal")
                break
            }
        }
    }

    private func handleGenericType(): Unit {
        if (!withGenericType) {
            return
        }

        if (!this.cd.isGenericDecl) {
            diagReport(DiagReportLevel.ERROR, this.cd.identifier.toTokens(),
                "expect to be a generic class type when using `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute",
                "expect to be a generic class")
            return
        }

        let gpTokens = this.cd.genericParam.parameters.toTokens()
        if (gpTokens.size != 1) {
            diagReport(DiagReportLevel.ERROR, gpTokens, "can only have one generic param",
                "can only have one generic param")
            return
        }

        let gp = gpTokens.get(0)
        if (gp.toTokens().toString() != genericType.toTokens().toString()) {
            diagReport(DiagReportLevel.ERROR, gpTokens,
                "generic param is inconsistent with `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute",
                "generic param is inconsistent with `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute")
            return
        }

        let gcList = this.cd.genericConstraint
        let gc = GenericConstraint()
        gc.keyword = Token(TokenKind.WHERE)
        gc.typeArgument = RefType(genericType.toTokens())

        if (gcList.size == 0) {
            this.cd.genericConstraint.add(gc)
            gc.upperBounds.add(RefType(quote(IStreamJsonAdapter<T>)))
        } else {
            var hasAddStream = false
            for (item in gcList) {
                let ta = item.typeArgument
                if (ta.toTokens().toString() == genericType.toTokens().toString()) {
                    for (value in item.upperBounds) {
                        match (value) {
                            case rt: RefType =>
                                if (rt.identifier.toTokens().toString() == "IStreamJsonAdapter") {
                                    hasAddStream = true
                                }
                            case _ => ()
                        }
                    }
                    if (!hasAddStream) {
                        item.upperBounds.add(RefType(quote(IStreamJsonAdapter<T>)))
                        gc.upperBounds.add(RefType(quote(IStreamJsonAdapter<T>)))
                        hasAddStream = true
                    }
                }
            }
            if (!hasAddStream) {
                this.cd.genericConstraint.add(gc)
            }
        }

        println("class = ${this.cd.toTokens().toString()}")
    }

    public func doExpend(attr: Tokens): Tokens {
        handleAttr(attr)

        handleGenericType()

        handleSuperTypes()

        for (decl in cd.body.decls) {
            match (decl) {
                case vd: VarDecl =>
                    let field = FieldInfo(vd)
                    // 如果指定了 ignorePrivate = true，则跳过私有字段
                    if (this.ignorePrivate && field.isPrivate) {
                        continue
                    }
                    if (field.isStatic && !field.isIgnore) {
                        diagReport(DiagReportLevel.ERROR, vd.toTokens(), "`static` member variable must use @JsonIgnore",
                            "must use @JsonIgnore")
                    }
                    // 如果该字段有 @JsonCustom prop 注册，则标记为忽略（由自定义 prop 处理）
                    if (!field.isIgnore && GlobalInfo.current().getJsonCustom(field.getJsonName()).isSome()) {
                        field.isIgnore = true
                    }
                    this.allFields.add(field)
                case pd: PropDecl =>
                    let field = FieldInfo(pd)
                    // 如果指定了 ignorePrivate = true，则跳过私有属性
                    if (this.ignorePrivate && field.isPrivate) {
                        continue
                    }
                    if (field.isStatic && !field.isIgnore) {
                        diagReport(DiagReportLevel.ERROR, pd.identifier.toTokens(),
                            "`static` member prop must use @JsonIgnore", "must use @JsonIgnore")
                    }
                    // 如果该 prop 是 @JsonCustom 自定义序列化器，则跳过常规序列化
                    if (!field.isIgnore && GlobalInfo.current().isJsonCustomProp(field.getJsonName())) {
                        field.isIgnore = true
                    }
                    this.allFields.add(field)
                case _ => ()
            }
        }

        // 类自身未声明 kind 成员且非泛型类时，启用自动 kind（多态判别）
        var hasKindField = false
        for (field in this.allFields) {
            if (field.identifier.toTokens().toString() == "kind") {
                hasKindField = true
                break
            }
        }
        // 自动 kind 仅对显式标记 polymorphic 的类启用（继承链上每个类都需标记；
        // withSuperClass 决定生成 open prop 还是 override prop）。
        // 类自身已声明 kind 成员（旧体系）或泛型类不启用。
        this.autoKind = this.polymorphic && !hasKindField && !this.cd.isGenericDecl

        cd.body.decls.add(createfromStreamJsonFunc())
        cd.body.decls.add(createFromJsonDispatchFunc())
        cd.body.decls.add(createToStreamJsonFunc())
        cd.body.decls.add(createToStreamJson())
        cd.body.decls.add(createfromStreamJson())
        if (this.isOpen) {
            cd.body.decls.add(createToStreamJsonInheritFunc())
            cd.body.decls.add(createFromStreamJsonInheritFunc())
        }
        for (member in createKindMembers()) {
            cd.body.decls.add(member)
        }

        return cd.toTokens()
    }
}
