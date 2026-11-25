/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected macro package three._vendor.fastjson.macros

import std.collection.*

class GlobalInfo {
    private static var instance = GlobalInfo()

    private let jsonIgnoreSet = HashSet<String>()
    private let jsonIgnoreNullSet = HashSet<String>()
    private let jsonNameMap = HashMap<String, String>()
    // @JsonCustom：目标字段名 → 自定义序列化 prop 名
    private let jsonCustomMap = HashMap<String, String>()
    private init() {
    }
    public static func current(): GlobalInfo {
        return instance
    }
    public func reset() {
        jsonIgnoreSet.clear()
        jsonIgnoreNullSet.clear()
        jsonNameMap.clear()
        jsonCustomMap.clear()
    }
    public func setJsonIgnore(fieldName: String) {
        jsonIgnoreSet.add(fieldName)
    }

    public func isJsonIgnore(fieldName: String): Bool {
        return jsonIgnoreSet.contains(fieldName)
    }

    public func setJsonIgnoreNull(fieldName: String) {
        jsonIgnoreNullSet.add(fieldName)
    }

    public func isJsonIgnoreNull(fieldName: String) {
        return jsonIgnoreNullSet.contains(fieldName)
    }

    public func setJsonName(fieldName: String, jsonName: String) {
        jsonNameMap.add(fieldName, jsonName)
    }

    public func getJsonName(fieldName: String): ?String {
        return jsonNameMap.get(fieldName)
    }

    /** @brief[zh-cn] 注册自定义字段序列化映射 */
    public func setJsonCustom(targetField: String, propName: String): Unit {
        jsonCustomMap.add(targetField, propName)
    }

    /** @brief[zh-cn] 获取字段的自定义序列化 prop 名（None 表示无自定义序列化） */
    public func getJsonCustom(targetField: String): ?String {
        return jsonCustomMap.get(targetField)
    }

    /** @brief[zh-cn] 判断某 prop 名是否已被注册为自定义序列化器 */
    public func isJsonCustomProp(propName: String): Bool {
        for ((_, pn) in jsonCustomMap) {
            if (pn == propName) { return true }
        }
        return false
    }
}
