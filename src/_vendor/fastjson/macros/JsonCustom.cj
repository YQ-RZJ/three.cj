protected macro package three._vendor.fastjson.macros

import std.ast.*

/**
 * @brief[zh-cn] 自定义字段序列化
 * @explain[zh-cn] 标记一个 prop 作为指定字段的自定义序列化器。
 * 被标记的 prop 不参与自动序列化，而是作为目标字段的序列化/反序列化工具。
 * 该 prop 的 getter 返回的字符串将被序列化为目标字段的 JSON 值；
 * 该 prop 的 setter 会在反序列化时被调用，参数为从 JSON 读取的字符串。
 *
 * 用法：
 * ```
 * @JsonIgnore
 * public var userData: HashMap<String, Any>
 *
 * @JsonCustom["userData"]
 * public prop userDataJson: String {
 *     get() { ... }
 *     set(val: String) { ... }
 * }
 * ```
 *
 * @brief[en] Custom field serialization
 * @explain[en] Marks a property as a custom serializer for the specified field.
 * The property's getter return value is serialized as the target field's JSON value;
 * the property's setter is called during deserialization with the JSON string value.
 */
public macro JsonCustom(attr: Tokens, input: Tokens): Tokens {
    assertParentContext("JsonAdapter")

    // 解析 attr 参数：目标字段名（必须为字符串字面量）
    var targetField = "N/A"
    let expr = parseExpr(attr)
    match (expr) {
        case lce: LitConstExpr =>
            if (lce.literal.kind == STRING_LITERAL) {
                targetField = lce.literal.value
            } else {
                diagReport(DiagReportLevel.ERROR, attr, "@JsonCustom only accepts a String Literal (field name)",
                    "must be a String Literal")
            }
        case _ => diagReport(DiagReportLevel.ERROR, attr, "@JsonCustom only accepts a String Literal (field name)",
            "must be a String Literal")
    }
    if (targetField.isEmpty()) {
        diagReport(DiagReportLevel.ERROR, attr, "@JsonCustom has an empty target field name",
            "should not be an empty String")
    }

    // 解析被修饰的声明：必须为 PropDecl（属性）
    let decl = parseDecl(input)
    match (decl) {
        case pd: PropDecl =>
            GlobalInfo.current().setJsonCustom(targetField, pd.identifier.value)
        case _ => diagReport(DiagReportLevel.ERROR, input, "@JsonCustom can only be used on a PropDecl (property)",
            "Expected PropDecl")
    }

    return input
}