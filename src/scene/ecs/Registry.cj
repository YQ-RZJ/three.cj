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
 * @file[zh-cn] Registry 组件类注册表
 * @brief[zh-cn] 组件类唯一键 -> 类级 ID（cptId）的分配，以及 cptId -> 无参工厂的登记
 * @explain[zh-cn] 设计要点：
 * - cptId 为全局自增整数，按唯一键幂等分配（同一类重复注册返回同一 ID）
 * - 唯一键由 @Component 宏在编译期生成（类名 + 定义位置，保证定义点唯一）
 * - 工厂用于 ComponentManager 按 cptId 池化创建组件实例
 * 对照 TS: ry-ecs Decorator.ts 的 componentRegistry + nextId
 * - TS 在装饰器求值（模块加载）时自增盖章 _cptId 并登记构造函数
 * - 仓颉静态成员惰性初始化：首次访问类的 typeId() 时完成登记，语义等价
 *
 * @file[en] Registry  Component class registry
 * @brief[en] Component class unique key -> class-level ID (cptId) allocation and cptId -> no-arg factory registration
 * @explain[en] Design notes:
 * - cptId is a globally auto-incrementing integer, idempotently allocated by unique key
 * (registering the same class again returns the same ID)
 * - Unique key is generated at compile time by the @Component macro (class name + definition location)
 * - Factory is used by ComponentManager to pool-create component instances by cptId
 * TS counterpart: ry-ecs Decorator.ts componentRegistry + nextId
 * - TS stamps _cptId and registers constructor during decorator evaluation (module load)
 * - Cangjie static members are lazily initialized: registration completes on first access of typeId()
 */
package three.scene.ecs

import std.collection.*

/**
 * @brief[zh-cn] 组件类注册表
 * @explain[zh-cn] 框架内部使用，由 @Component 宏注入的代码自动调用，使用者无需直接操作
 *
 * @brief[en] Component class registry
 * @explain[en] Used internally by the framework; auto-called by code injected by @Component macro; users need not operate directly
 */
public class ComponentRegistry {
    /**
     * @brief[zh-cn] 下一个待分配的组件类 ID
     *
     * @brief[en] Next component class ID to be allocated
     */
    private static var _nextId: Int64 = 0
    /**
     * @brief[zh-cn] 唯一键 -> 组件类 ID
     *
     * @brief[en] Unique key -> component class ID
     */
    private static let _nameToId: HashMap<String, Int64> = HashMap<String, Int64>()
    /**
     * @brief[zh-cn] 组件类 ID -> 无参工厂
     *
     * @brief[en] Component class ID -> no-argument factory
     */
    private static let _idToFactory: HashMap<Int64, () -> Component> = HashMap<Int64, () -> Component>()

    /**
     * @brief[zh-cn] 登记组件类并分配类 ID（幂等）
     * @param[zh-cn] uniqueKey 定义点唯一键（宏生成）
     * factory 组件无参工厂
     * @return[zh-cn] 分配到的组件类 ID
     *
     * @brief[en] Register a component class and allocate class ID (idempotent)
     * @param[en] uniqueKey Definition-point unique key (macro-generated)
     * factory Component no-arg factory
     * @return[en] Allocated component class ID
     */
    public static func registerAlloc(uniqueKey: String, factory: () -> Component): Int64 {
        if (let Some(id) <- _nameToId.get(uniqueKey)) {
            return id
        }
        let id = _nextId
        _nextId += 1
        _nameToId.add(uniqueKey, id)
        _idToFactory.add(id, factory)
        id
    }

    /**
     * @brief[zh-cn] 按唯一键查询组件类 ID
     * @param[zh-cn] uniqueKey 定义点唯一键
     * @return[zh-cn] 未登记返回 None
     *
     * @brief[en] Query component class ID by unique key
     * @param[en] uniqueKey Definition-point unique key
     * @return[en] None if not registered
     */
    public static func idOf(uniqueKey: String): ?Int64 {
        _nameToId.get(uniqueKey)
    }

    /**
     * @brief[zh-cn] 按类 ID 查询组件工厂
     * @param[zh-cn] id 组件类 ID
     * @return[zh-cn] 未登记返回 None
     *
     * @brief[en] Query component factory by class ID
     * @param[en] id Component class ID
     * @return[en] None if not registered
     */
    public static func factoryOf(id: Int64): ?(() -> Component) {
        _idToFactory.get(id)
    }

    /**
     * @brief[zh-cn] 已分配的组件类 ID 总数
     *
     * @brief[en] Total number of allocated component class IDs
     */
    public static prop count: Int64 {
        get() { _nextId }
    }
}
