/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] LoadResultWrappers 加载结果值类型包装类
 * @brief[zh-cn] 加载结果值类型包装类（three.resource.loader 包内）
 * @explain[zh-cn] Loader.load 的 onLoad 回调参数类型已具体化为 ILoadResult 接口。对象型结果直接实现接口；而 String 与 Array<UInt8> 是值类型/库类型，无法实现自定义接口，用本包装类承载。
 *
 * @file[en] LoadResultWrappers  Load result value type wrapper classes
 * @brief[en] Load result value type wrapper classes (within three.resource.loader package)
 * @explain[en] Loader.load's onLoad callback parameter type is concretized as ILoadResult interface. Object-type results directly implement the interface; String and Array<UInt8> are value/library types that cannot implement custom interfaces, so these wrapper classes are used.
 *
 * @package three.resource.loader
 */
package three.resource.loader

import std.collection.*
import three.core.interfaces.ILoadResult
import three.animation.clip.AnimationClip

/**
 * @brief[zh-cn] StringLoadResult：字符串加载结果包装
 *
 * @brief[en] StringLoadResult: String load result wrapper
 */
public class StringLoadResult <: ILoadResult {
    public let value: String
    public init(value: String) { this.value = value }
}

/**
 * @brief[zh-cn] BytesLoadResult：字节数组加载结果包装（Array<UInt8>）
 *
 * @brief[en] BytesLoadResult: Byte array load result wrapper (Array<UInt8>)
 */
public class BytesLoadResult <: ILoadResult {
    public let value: Array<UInt8>
    public init(value: Array<UInt8>) { this.value = value }
}

/**
 * @brief[zh-cn] ClipsLoadResult：动画剪辑数组加载结果包装（ArrayList<AnimationClip>）
 * @explain[zh-cn] AnimationLoader.load 的 onLoad(clips)——clips 为 AnimationClip[]。
 *
 * @brief[en] ClipsLoadResult: Animation clip array load result wrapper (ArrayList<AnimationClip>)
 * @explain[en] AnimationLoader.load's onLoad(clips) where clips is AnimationClip[].
 */
public class ClipsLoadResult <: ILoadResult {
    public let value: ArrayList<AnimationClip>
    public init(value: ArrayList<AnimationClip>) { this.value = value }
}
