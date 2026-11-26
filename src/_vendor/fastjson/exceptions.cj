/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected package three._vendor.fastjson

public class JsonTypeMismatch <: Exception {
    public init(className: String, fieldName: String, expectedType: String, actualType: String) {
        super("'${className}.${fieldName}' mismatch type, expect '${expectedType}', actually got '${actualType}'")
    }
}

public class JsonFieldNotExist <: Exception {
    public init(className: String, fieldName: String) {
        super("'${className}.${fieldName}' not exist")
    }
}

public class JsonGetValueException <: Exception {
    public init(message: String) {
        super(message)
    }
}
