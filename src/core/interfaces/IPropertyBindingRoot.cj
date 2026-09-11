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
 * @file[zh-cn] IPropertyBindingRoot
 * @brief[zh-cn] 属性绑定根节点接口
 * @explain[zh-cn] Three.js 的 PropertyBinding.rootNode/node/targetObject 是 Object3D|Skeleton 联合类型。仓颉无联合类型，且 Object3D（core 包）与 Skeleton（objects 包）无公共基类，故抽象为公共接口。实现方（core 包 Object3D、objects 包 Skeleton）实现本接口；使用方（animation 包 PropertyBinding）以接口持有根节点引用，不依赖具体实现类型。
 *
 * @file[en] IPropertyBindingRoot
 * @brief[en] Property binding root node interface
 * @explain[en] In three.js, PropertyBinding.rootNode/node/targetObject is of union type Object3D|Skeleton. Cangjie has no union types, and Object3D (core package) and Skeleton (objects package) share no common base class, so they are abstracted into a common interface. Implementers (core package Object3D, objects package Skeleton) implement this interface; consumers (animation package PropertyBinding) hold root node references via the interface without depending on concrete implementation types.
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 属性绑定根节点接口：PropertyBinding 的 rootNode/node/targetObject 类型
 * @explain[zh-cn] 消除 Object3D|Skeleton 联合类型，让 PropertyBinding 以统一接口持有根节点引用
 *
 * @brief[en] Property binding root node interface: type of PropertyBinding's rootNode/node/targetObject
 * @explain[en] Eliminates Object3D|Skeleton union type, allowing PropertyBinding to hold root node references via a unified interface
 */
public interface IPropertyBindingRoot {
    /**
     * @brief[zh-cn] 获取节点唯一标识
     * @return[zh-cn] 节点 UUID
     *
     * @brief[en] Get the node's unique identifier
     * @return[en] Node UUID
     */
    func getUuid(): String
}
