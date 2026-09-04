/**
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
