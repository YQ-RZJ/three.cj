/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

protected macro package three._vendor.fastjson.macros

import std.ast.*
import std.collection.HashSet

func isOptionType(node: TypeNode): Bool {
    match (node) {
        case pt: PrefixType => return true
        case rt: RefType =>
            if (rt.identifier.value == "Option") {
                return true
            } else {
                return false
            }
        case _ => return false
    }
}

func getOptionBaseType(node: TypeNode): Tokens {
    match (node) {
        case pt: PrefixType => return pt.baseType.toTokens()
        case rt: RefType =>
            if (rt.identifier.value == "Option") {
                return rt.typeArguments.toTokens()
            } else {
                return node.toTokens()
            }
        case _ => return node.toTokens()
    }
}

func unwrapRawIdentifier(identifier: Token): String {
    let name = identifier.value
    if (name.startsWith("`") && name.endsWith("`")) {
        return name[1..name.size - 1]
    } else {
        return name
    }
}

/* func isHashMapStringAnyType(typeInfo: TypeNode): Bool {
    let refType = typeInfo as RefType ?? return false
    if (refType.identifier.value != "HashMap") {
        return false
    }
    let keyType = refType.typeArguments[0] as RefType ?? return false
    let valueType = refType.typeArguments[1] as RefType ?? return false
    return keyType.identifier.value == "String" && valueType.identifier.value == "Any"
}*/

/* func isHashMapStringStringType(typeInfo: TypeNode): Bool {
    let refType = typeInfo as RefType ?? return false
    if (refType.identifier.value != "HashMap") {
        return false
    }
    let keyType = refType.typeArguments[0] as RefType ?? return false
    let valueType = refType.typeArguments[1] as RefType ?? return false
    return keyType.identifier.value == "String" && valueType.identifier.value == "String"
}*/

/* func isSeqAnyType(typeInfo: TypeNode): Bool {
    let refType = typeInfo as RefType ?? return false
    match (refType.identifier.value) {
        case "Array" | "ArrayList" => () // 序列类型
        case _ => return false
    }
    let elementType = refType.typeArguments[0] as RefType ?? return false
    return elementType.identifier.value == "Any"
}*/
func isAnyType(typeInfo: TypeNode): Bool {
    let refType = typeInfo as RefType ?? return false
    return refType.identifier.value == "Any"
}

/* func isAnyType(typeArgs: Tokens): Bool {
    return typeArgs.size == 1 && typeArgs[0].value == "Any"
}*/
private let NUMBER_TYPE_SET = HashSet<String>("Int64", "Int32", "Int16", "Int8", "UInt64", "UInt32", "UInt16", "UInt8",
    "Float64", "Float32", "Float16", "Float8")

/* func isNumberType(node: TypeNode) {
    match (node) {
        case pt: PrimitiveType => return NUMBER_TYPE_SET.contains(pt.keyword.value)
        case _ => return false
    }
}*/
func isSeqListAnyTypeForStream(typeInfo: TypeNode): Bool {
    let refType = typeInfo as RefType ?? return false
    match (refType.identifier.value) {
        case "ArrayList" | "HashSet" => ()
        case _ => return false
    }
    let elementType = refType.typeArguments[0] as RefType ?? return false
    return elementType.identifier.value == "Any"
}

func isSeqArrayAnyTypeForStream(typeInfo: TypeNode): Bool {
    let refType = typeInfo as RefType ?? return false
    match (refType.identifier.value) {
        case "Array" => ()
        case _ => return false
    }
    let elementType = refType.typeArguments[0] as RefType ?? return false
    return elementType.identifier.value == "Any"
}

func isMapAnyTypeForStream(typeInfo: TypeNode): Bool {
    let refType = typeInfo as RefType ?? return false
    match (refType.identifier.value) {
        case "HashMap" => ()
        case _ => return false
    }
    let elementType = refType.typeArguments[1] as RefType ?? return false
    return elementType.identifier.value == "Any"
}

func isOptionAnyType(node: TypeNode): Bool {
    match (node) {
        case pt: PrefixType => isAnyType(pt.baseType)
        case rt: RefType =>
            if (rt.identifier.value == "Option") {
                let elementType = rt.typeArguments[0] as RefType ?? return false
                return elementType.identifier.value == "Any"
            } else {
                return false
            }
        case _ => return false
    }
}

func isArrayType(node: TypeNode): Bool {
    match (node) {
        case rt: RefType => rt.identifier.value == "Array"
        case _ => return false
    }
}

func getArrayBaseType(node: TypeNode): Tokens {
    match (node) {
        case rt: RefType =>
            if (rt.identifier.value == "Array") {
                return rt.typeArguments.toTokens()
            } else {
                return node.toTokens()
            }
        case _ => return node.toTokens()
    }
}

func isSeqListType(node: TypeNode): Bool {
    match (node) {
        case rt: RefType => rt.identifier.value == "ArrayList" || rt.identifier.value == "HashSet"
        case _ => return false
    }
}

func getSeqListBaseType(node: TypeNode): Tokens {
    match (node) {
        case rt: RefType =>
            if (rt.identifier.value == "ArrayList" || rt.identifier.value == "HashSet") {
                return rt.typeArguments.toTokens()
            } else {
                return node.toTokens()
            }
        case _ => return node.toTokens()
    }
}

func isHashSetType(node: TypeNode): Bool {
    match (node) {
        case rt: RefType => rt.identifier.value == "HashSet"
        case _ => return false
    }
}

func getHashSetBaseType(node: TypeNode): Tokens {
    match (node) {
        case rt: RefType =>
            if (rt.identifier.value == "HashSet") {
                return rt.typeArguments.toTokens()
            } else {
                return node.toTokens()
            }
        case _ => return node.toTokens()
    }
}
