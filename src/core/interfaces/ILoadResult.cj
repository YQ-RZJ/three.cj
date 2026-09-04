/**
 * @file[zh-cn] ILoadResult
 * @brief[zh-cn] 加载结果标记接口
 * @explain[zh-cn] three.js 各 loader 的 load(url, onLoad, onProgress, onError) 回调中，onLoad(data) 的 data 是加载结果（类型因 loader 而异：String/BufferGeometry/Texture/Material/Object3D/Group/AudioBuffer 等）。仓颉中原用 Any 承载，为消除 Any，定义本标记接口。结果对象类型（BufferGeometry/Texture/Material/Object3D/Group 等）实现本接口；String/字节数组等值类型结果用包装类（StringLoadResult 等）实现本接口；使用方（Loader 基类与各子类）仅以接口表达回调参数，不依赖具体实现类型。
 *
 * @file[en] ILoadResult
 * @brief[en] Load result marker interface
 * @explain[en] In three.js, the onLoad(data) callback in loader.load(url, onLoad, onProgress, onError) carries the load result (type varies by loader: String/BufferGeometry/Texture/Material/Object3D/Group/AudioBuffer etc.). Cangjie originally used Any to carry this; to eliminate Any, this marker interface is defined. Result object types (BufferGeometry/Texture/Material/Object3D/Group etc.) implement this interface; String/byte array value-type results use wrapper classes (StringLoadResult etc.) to implement this interface; consumers (Loader base class and subclasses) express callback parameters via the interface without depending on concrete implementation types. JS reference: loader.load(url, onLoad(data)) data (arbitrary load result).
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 加载结果标记接口：Loader.load 的 onLoad 回调参数类型
 * @explain[zh-cn] 消除 Any，让各类型加载结果共享统一接口类型
 *
 * @brief[en] Load result marker interface: onLoad callback parameter type of Loader.load
 * @explain[en] Eliminates Any, allowing various load result types to share a unified interface type
 */
public interface ILoadResult {
}
