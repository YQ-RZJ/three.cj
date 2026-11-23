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
 * @file[zh-cn] IPoolObject 池对象生命周期接口（自 three.utils.pool 迁入本接口包）
 * @brief[zh-cn] 定义池对象的生命周期回调，由 \@PoolObject 宏自动注入实现
 * @explain[zh-cn] 按 C9 约定收纳于 utils/interfaces（protected 包），经实现包重导出
 * 为 three.utils.pool.IPoolObject。
 *
 * @file[en] IPoolObject  Pool-object lifecycle interface (moved from three.utils.pool into this interface package)
 * @brief[en] Defines the lifecycle callbacks of pooled objects, auto-injected by the \@PoolObject macro
 * @explain[en] Collected into utils/interfaces per C9 (protected package), re-exported by the implementation package as three.utils.pool.IPoolObject.
 */
protected package three.utils._interfaces

/**
 * @brief[zh-cn] 池对象生命周期接口
 * @explain[zh-cn] 由 \@PoolObject 宏自动为池对象类添加该接口实现并提供空实现；
 * 子类可 override construct/destruct 实现自定义的初始化/清理逻辑。
 * ObjectPool.allocate 复用对象时会调用 construct，recycle 回收对象时
 * 会调用 destruct。
 *
 * @brief[en] Pooled-object lifecycle interface
 * @explain[en] The \@PoolObject macro automatically adds this interface to pooled object
 * classes with no-op implementations; subclasses may override construct/destruct
 * for custom init/cleanup logic. ObjectPool calls construct when allocating a
 * reused object and destruct when recycling one.
 */
public interface IPoolObject {
    /**
     * @brief[zh-cn] 构造回调（对象被复用前调用）
     * @explain[zh-cn] 用于初始化或重置对象状态，使其进入可用状态。
     *
     * @brief[en] Construct callback (invoked before an object is reused)
     * @explain[en] Used to initialize or reset object state so it becomes usable.
     */
    func construct(): Unit

    /**
     * @brief[zh-cn] 析构回调（对象被回收时调用）
     * @explain[zh-cn] 用于清理对象状态、释放关联资源，使其可被复用。
     *
     * @brief[en] Destruct callback (invoked when an object is recycled)
     * @explain[en] Used to clean up object state and release associated resources so it
     * can be reused.
     */
    func destruct(): Unit
}
