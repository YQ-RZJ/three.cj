/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
 
protected package three._vendor.fastjson

public import std.io.*
public import three._vendor.fastjson.stream.*
public import std.collection.*
public import std.collection.concurrent.ConcurrentHashMap

public interface  IStreamJsonAdapter<T> <:JsonStreamDeserializable<T> & JsonStreamSerializable {
}