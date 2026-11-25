/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

protected package three._vendor.fastjson

import std.collection.concurrent.ConcurrentHashMap
import three._vendor.fastjson.stream.*

/**
 * @brief[zh-cn] 多态反序列化注册表：kind（类名）→ 具体子类读取器
 * @explain[zh-cn] @JsonAdapter 宏为继承链上的每个类注入静态惰性登记字段，
 *   类首次主动使用时自动登记；也可通过 ensureXxxRegistered() 显式触发。
 *   反序列化多态根（polymorphic = true）时，先扫描 JSON 对象中的 "kind" 字段，
 *   再按 kind 查找本表，命中则交给对应子类的 fromJsonConcrete 还原真实类型；
 *   未命中回退为根类型自身读取。
 *
 * @brief[en] Polymorphic deserialization registry: kind (class name) -> concrete subclass reader
 * @explain[en] The @JsonAdapter macro injects a static lazy registration field for every
 *   class in an inheritance chain; registration happens on first active use of the class,
 *   or can be triggered explicitly via ensureXxxRegistered(). When deserializing a
 *   polymorphic root (polymorphic = true), the "kind" field of the JSON object is scanned
 *   first, then looked up here; on hit the concrete subclass fromJsonConcrete restores the
 *   real type; on miss the root type's own reader is used as fallback.
 */
public class JsonPolymorphicRegistry {
    /**
     * @brief[zh-cn] kind → 读取器（读取器消费整个 JSON 对象并返回实例）
     */
    static let readers: ConcurrentHashMap<String, (JsonStreamReader) -> Any> =
        ConcurrentHashMap<String, (JsonStreamReader) -> Any>()

    /**
     * @brief[zh-cn] 登记一个具体类型的读取器
     * @param[zh-cn] typeName 类型判别名（类名，对应 JSON 中的 "kind" 值）
     * reader 读取器：接收 JsonStreamReader，返回该类型实例
     * @return[zh-cn] 恒为 true（便于静态惰性字段初始化）
     */
    public static func register(typeName: String, reader: (JsonStreamReader) -> Any): Bool {
        readers.add(typeName, reader)
        return true
    }

    /**
     * @brief[zh-cn] 按 kind 创建实例；未登记返回 None
     */
    public static func create(typeName: String, reader: JsonStreamReader): ?Any {
        match (readers.get(typeName)) {
            case Some(f) => Some(f(reader))
            case None => None
        }
    }

    /**
     * @brief[zh-cn] 判断 kind 是否已登记
     */
    public static func isRegistered(typeName: String): Bool {
        match (readers.get(typeName)) {
            case Some(_) => true
            case None => false
        }
    }
}
