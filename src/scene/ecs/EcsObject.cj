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
 * @file[zh-cn] EcsObject ECS 对象生命周期基类
 * @brief[zh-cn] 提供 construct/restruct/destruct 生命周期，对接对象池 IPoolObject
 * @explain[zh-cn] 设计要点：
 * - 模板方法模式：construct/restruct/destruct 为 final 入口，维护 _constructed 标记
 * 并分派到开放钩子 onConstruct/onDestruct，用户只重写钩子
 * - 标记守卫保证钩子不会因对象池的自动回调而重复执行（幂等）
 * - 注意：重写 onConstruct/onDestruct 时必须调用 super 实现（与 TS 版 destruct 的
 * super 约定一致，仓颉无原型链遍历能力，无法自动走继承链）
 * 对照 TS: @raozj/ry-core 的 RyAuto.StructMgr + RyObjPool.ObjectBase
 * - TS 用 StructMgr 装饰器注入 construct/restruct/destruct，restruct 沿原型链
 * 从基到子调用每一级 construct，子类无需 super.construct()
 * - 仓颉改为基类模板方法 + 钩子重写约定
 *
 * @file[en] EcsObject  ECS object lifecycle base class
 * @brief[en] Provides construct/restruct/destruct lifecycle, interfacing with object pool IPoolObject
 * @explain[en] Design notes:
 * - Template method pattern: construct/restruct/destruct are final entry points that
 * maintain the _constructed flag and dispatch to open hooks onConstruct/onDestruct;
 * users only override the hooks
 * - Flag guard ensures hooks do not execute repeatedly due to object pool auto-callbacks (idempotent)
 * - Note: when overriding onConstruct/onDestruct, super implementations must be called
 * (consistent with TS destruct super convention; Cangjie has no prototype chain traversal)
 * TS counterpart: @raozj/ry-core RyAuto.StructMgr + RyObjPool.ObjectBase
 * - TS uses StructMgr decorator to inject construct/restruct/destruct; restruct calls each
 * level's construct along the prototype chain; subclasses do not need super.construct()
 * - Cangjie uses base class template method + hook override convention
 */
package three.scene.ecs

import three.utils.pool.IPoolObject

/**
 * @brief[zh-cn] 无效 ID 哨兵值
 *
 * @brief[en] Invalid ID sentinel value
 */
public const NUM_NONE: Int64 = -1

/**
 * @brief[zh-cn] ECS 对象生命周期基类，对接对象池
 * @explain[zh-cn] 生命周期时序：
 * - 新建：init 完成字段初始化（Entity/System 在 init 中分配 ID 并 markConstructed）
 * - 池复用：ObjectPool.allocate 自动回调 construct -> onConstruct
 * - 池回收 / 管理器删除：自动回调 destruct -> onDestruct
 *
 * @brief[en] ECS object lifecycle base class, interfacing with object pool
 * @explain[en] Lifecycle timing:
 * - New: init completes field initialization (Entity/System allocate ID and markConstructed in init)
 * - Pool reuse: ObjectPool.allocate auto-calls construct -> onConstruct
 * - Pool recycle / manager deletion: auto-calls destruct -> onDestruct
 */
public open class EcsObject <: IPoolObject {
    /**
     * @brief[zh-cn] 是否已构造
     *
     * @brief[en] Whether constructed
     */
    protected var _constructed: Bool = false

    /**
     * @brief[zh-cn] 是否已构造
     *
     * @brief[en] Whether constructed
     */
    public prop constructed: Bool {
        get() { _constructed }
    }

    /**
     * @brief[zh-cn] 构造（池复用入口），仅在未构造时执行 onConstruct，保证幂等
     *
     * @brief[en] Construct (pool reuse entry); only executes onConstruct when not constructed, ensuring idempotency
     */
    public func construct(): Unit {
        if (!_constructed) {
            _constructed = true
            onConstruct()
        }
    }

    /**
     * @brief[zh-cn] 重构（强制重建），仓颉依靠 onConstruct 重写链中的 super 调用达到同等效果
     *
     * @brief[en] Restruct (force rebuild); Cangjie relies on super calls in the onConstruct override chain
     */
    public func restruct(): Unit {
        _constructed = true
        onConstruct()
    }

    /**
     * @brief[zh-cn] 析构（回收/删除入口），仅在已构造时执行 onDestruct，保证幂等
     *
     * @brief[en] Destruct (recycle/delete entry); only executes onDestruct when constructed, ensuring idempotency
     */
    public func destruct(): Unit {
        if (_constructed) {
            onDestruct()
            _constructed = false
        }
    }

    /**
     * @brief[zh-cn] 构造钩子，重写时必须调用 super.onConstruct()
     *
     * @brief[en] Construction hook; must call super.onConstruct() when overriding
     */
    protected open func onConstruct(): Unit {}

    /**
     * @brief[zh-cn] 析构钩子，重写时必须调用 super.onDestruct()；实现应保持幂等
     *
     * @brief[en] Destruction hook; must call super.onDestruct() when overriding; implementation should be idempotent
     */
    protected open func onDestruct(): Unit {}
}
