/**
 * @file main
 * @brief three.resource.serializer（JSON 序列化）完整测试
 *
 * 验证 three 重公开的 cjfast_json 能力端到端可用：
 *   1. @JsonAdapter 宏：对象自动生成 fromJson/toJson
 *   2. JsonSerializer 便捷类：toJson / fromJson / toJsonBytes / fromJsonBytes / isValidJson
 *   3. @JsonName 别名 / @JsonIgnore 忽略 / @JsonIgnoreNull 空值不序列化
 *   4. 嵌套对象 + 集合（ArrayList / HashMap）
 *   5. @JsonAdapter[withGenericType = T] 泛型支持
 *   6. 手动流式 JsonStreamReader / JsonStreamWriter（api.md 方式 2）
 */
package threeSerializerTest

import std.io.*
import std.collection.*
import three.resource.serializer.*
import three.resource.serializer.macros.*

// =============================================================================
// 简易断言工具
// =============================================================================

private var _passCount: Int64 = 0
private var _failCount: Int64 = 0

private func check(name: String, cond: Bool): Unit {
    if (cond) {
        _passCount += 1
        println("  [PASS] ${name}")
    } else {
        _failCount += 1
        println("  [FAIL] ${name}")
    }
}

// =============================================================================
// @JsonAdapter 测试模型
// =============================================================================

/// 基础模型：覆盖基本类型 + 集合 + Option
@JsonAdapter
public class Basic {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()
}

/// 嵌套模型
@JsonAdapter
public class Nested {
    public var name: String = ""
    public var basic: ?Basic = None
}

/// 别名/忽略/空值忽略
@JsonAdapter
public class Attrs {
    @JsonName["user_id"]
    public var id: Int64 = 0

    @JsonIgnore
    public var temp: String = "secret"

    @JsonIgnoreNull
    public var nullable: ?String = None
}

/// 泛型模型（withGenericType = T）
@JsonAdapter[withGenericType = T]
public class Result<T> {
    public var data: ?T = None
    public var ok: Bool = false
}

main(): Int64 {
    println("=== three.resource.serializer（JSON 序列化）测试 ===")
    println("")

    // ---- [A] @JsonAdapter 宏：fromJson / toJson ----
    println("[A] @JsonAdapter 宏基础序列化")
    let input = #"{"a":123,"b":"hello","c":null,"d":[1,2,3],"e":["s1","s2"],"f":{"k1":10,"k2":20}}"#
    let obj = Basic.fromJson(input)
    check("fromJson: a == 123", obj.a == 123)
    check("fromJson: b == hello", obj.b == "hello")
    check("fromJson: c == None", obj.c.isNone())
    check("fromJson: d == [1,2,3]", obj.d.size == 3 && obj.d[2] == 3)
    check("fromJson: e == [s1,s2]", obj.e.size == 2 && obj.e[0] == "s1")
    check("fromJson: f.k2 == 20", obj.f["k2"] == 20)

    let json = obj.toJson()
    check("toJson: 非空且含关键字段", json.contains("123") && json.contains("hello"))
    println("  [info] toJson = ${json}")

    // 往返一致性
    let obj2 = Basic.fromJson(json)
    check("roundtrip: a 保持", obj2.a == obj.a)
    check("roundtrip: b 保持", obj2.b == obj.b)

    // ---- [B] JsonSerializer 便捷类 ----
    println("")
    println("[B] JsonSerializer 便捷类")
    let fromUtil = JsonSerializer.fromJson<Basic>(input)
    check("JsonSerializer.fromJson<T>: a == 123", fromUtil.a == 123)
    let toUtil = JsonSerializer.toJson(obj2)
    check("JsonSerializer.toJson: 非空", toUtil.size > 0)

    let bytes = JsonSerializer.toJsonBytes(obj2)
    check("toJsonBytes: 字节数组", bytes.size > 0)
    let fromBytes = JsonSerializer.fromJsonBytes<Basic>(bytes)
    check("fromJsonBytes: b 保持", fromBytes.b == obj2.b)

    check("isValidJson: 合法 JSON", JsonSerializer.isValidJson<Basic>(#"{"a":1}"#))
    check("isValidJson: 非法 JSON", !JsonSerializer.isValidJson<Basic>("not json"))

    // ---- [C] 嵌套模型 ----
    println("")
    println("[C] 嵌套对象")
    let nestedInput = #"{"name":"outer","basic":{"a":7,"b":"inner","e":["x"]}}"#
    let nested = Nested.fromJson(nestedInput)
    check("嵌套: name == outer", nested.name == "outer")
    check("嵌套: basic.a == 7", match (nested.basic) {
        case Some(b) => b.a == 7
        case None => false
    })
    let nestedJson = nested.toJson()
    check("嵌套: toJson 含 inner", nestedJson.contains("inner"))

    // ---- [D] @JsonName / @JsonIgnore / @JsonIgnoreNull ----
    println("")
    println("[D] 别名/忽略/空值忽略")
    let attrs = Attrs()
    attrs.id = 42
    attrs.temp = "should-not-appear"
    let attrsJson = attrs.toJson()
    check("@JsonName: 使用 user_id 别名", attrsJson.contains("user_id") && !attrsJson.contains("\"id\""))
    check("@JsonIgnore: temp 不序列化", !attrsJson.contains("should-not-appear"))
    check("@JsonIgnoreNull: nullable None 不序列化", !attrsJson.contains("nullable"))
    println("  [info] attrsJson = ${attrsJson}")

    // 反序列化：别名映射回字段
    let attrs2 = Attrs.fromJson(#"{"user_id":99}"#)
    check("反序列化: user_id → id == 99", attrs2.id == 99)

    // ---- [E] 泛型 withGenericType ----
    println("")
    println("[E] 泛型模型 withGenericType")
    let resultInput = #"{"data":{"a":5,"b":"gen"},"ok":true}"#
    let res = Result<Basic>.fromJson(resultInput)
    check("泛型: ok == true", res.ok)
    check("泛型: data.a == 5", match (res.data) {
        case Some(d) => d.a == 5
        case None => false
    })
    let resJson = res.toJson()
    check("泛型: toJson 含 gen", resJson.contains("gen"))

    // ---- [F] 手动流式 JsonStreamReader / JsonStreamWriter ----
    println("")
    println("[F] 手动流式（api.md 方式 2）")
    // 便捷类内部已是流式；此处直接验证流式类可构造/可用
    let stream = ByteBuffer()
    let writer = JsonStreamWriter(stream)
    writer.jsonValue(#"{"manual":1}"#)
    writer.flush()
    let manualStr = String.fromUtf8(readToEnd(stream))
    check("JsonStreamWriter: 写入成功", manualStr.contains("manual"))
    println("  [info] manual = ${manualStr}")

    let reader = JsonStreamReader(ByteBuffer(#"{"a":1}"#.toArray()))
    let fromStream = Basic.fromJson(reader)
    check("JsonStreamReader: 流式反序列化 a == 1", fromStream.a == 1)

    // ---- 汇总 ----
    println("")
    println("=== 测试结果 ===")
    println("  PASS: ${_passCount}")
    println("  FAIL: ${_failCount}")
    println(if (_failCount == 0) { "  == 全部通过 ==" } else { "  == 存在失败 ==" })

    return if (_failCount == 0) { 0 } else { 1 }
}
