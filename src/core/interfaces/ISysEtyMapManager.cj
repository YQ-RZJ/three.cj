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
 * @file[zh-cn] ISysEtyMapManager
 * @brief[zh-cn] 系统-实体映射管理接口
 * @explain[zh-cn] ECS 世界（World）需要可替换的"系统 <-> 实体"掩码匹配策略：ArrSysEtyMapManager（哈希模式）实现简单，系统少时开销低（默认）；TreeSysEtyMapManager（前缀树模式）基于 BinaryPatriciaTrie 按位子集查询，系统数量大、实体组件变更频繁时更优。将策略抽象为接口放在独立接口包内，便于 World(sysMapMgr) 注入更换模式。泛型化说明：接口包处于依赖底层，不允许回引 three.ecs（否则成环），故系统/实体类型以泛型参数 S/E 抽象；three.ecs 中以 ISysEtyMapManager<System, Entity> 落地。
 *
 * @file[en] ISysEtyMapManager
 * @brief[en] System-entity mapping manager interface
 * @explain[en] The ECS World requires replaceable "system <-> entity" mask matching strategies: ArrSysEtyMapManager (hash mode) is simple to implement with low overhead when systems are few (default); TreeSysEtyMapManager (trie mode) is based on BinaryPatriciaTrie with bit-subset queries, better when there are many systems or frequent entity component changes. The strategy is abstracted as an interface in the independent interface package, facilitating World(sysMapMgr) injection for mode switching. Generics explanation: the interface package is at the dependency bottom and must not back-reference three.ecs (would form a cycle), so system/entity types are abstracted as generic parameters S/E; in three.ecs it is instantiated as ISysEtyMapManager<System, Entity>.
 */
package three.core.interfaces

import std.collection.*

/**
 * @brief[zh-cn] 系统-实体映射管理接口
 * @explain[zh-cn] 泛型 S 为系统类型（three.ecs.System），E 为实体类型（three.ecs.Entity）
 *
 * @brief[en] System-entity mapping manager interface
 * @explain[en] Generic S is the system type (three.ecs.System), E is the entity type (three.ecs.Entity)
 */
public interface ISysEtyMapManager<S, E> {
    /**
     * @brief[zh-cn] 挂接系统表与实体表（引用共享，由 SystemManager 建立）
     * @param[zh-cn] systems 系统哈希表
     * entitys 实体哈希表
     *
     * @brief[en] Bind system table and entity table (shared references, established by SystemManager)
     * @param[en] systems System hash map
     * entitys Entity hash map
     */
    func bind(systems: HashMap<Int64, S>, entitys: HashMap<Int64, E>): Unit

    /**
     * @brief[zh-cn] 将系统加入记录区
     * @param[zh-cn] sys 系统
     *
     * @brief[en] Add a system to the record area
     * @param[en] sys System
     */
    func addSystem(sys: S): Unit

    /**
     * @brief[zh-cn] 从记录区移除系统
     * @param[zh-cn] sys 系统
     *
     * @brief[en] Remove a system from the record area
     * @param[en] sys System
     */
    func delSystem(sys: S): Unit

    /**
     * @brief[zh-cn] 获取系统记录区的所有实体
     * @return[zh-cn] (总数, 当轮快照迭代器)
     *
     * @brief[en] Get all entities in the system's record area
     * @return[en] (Total count, current round snapshot iterator)
     */
    func getSystemEntitys(sys: S): (Int64, Iterator<E>)

    /**
     * @brief[zh-cn] 将实体加入到各系统的记录区
     * @param[zh-cn] ety 实体
     *
     * @brief[en] Add an entity to each system's record area
     * @param[en] ety Entity
     */
    func addEntity(ety: E): Unit

    /**
     * @brief[zh-cn] 将实体从所有系统记录区移除
     * @param[zh-cn] ety 实体
     *
     * @brief[en] Remove an entity from all system record areas
     * @param[en] ety Entity
     */
    func delEntity(ety: E): Unit

    /**
     * @brief[zh-cn] 实体组件变更，调整实体归属记录区
     * @param[zh-cn] oldMask 旧组件掩码
     * ety 实体
     *
     * @brief[en] Entity components changed, adjust entity's record area assignments
     * @param[en] oldMask Old component mask
     * ety Entity
     */
    func changeEntity(oldMask: Array<UInt8>, ety: E): Unit

    /**
     * @brief[zh-cn] 清理所有记录区
     *
     * @brief[en] Clear all record areas
     */
    func clear(): Unit
}
