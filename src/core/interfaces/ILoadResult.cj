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
