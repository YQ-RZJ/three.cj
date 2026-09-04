/**
 * @file[zh-cn] IPoolObject 池对象生命周期接口
 * @brief[zh-cn] 定义池对象的生命周期回调，由 \@PoolObject 宏自动注入实现
 * @explain[zh-cn] 本接口仅声明两个无参回调 construct/destruct，不携带任何字段，
 * 由 \@PoolObject 宏自动为池对象类实现并注入。命名沿用 TS RyFramework 的
 * construct/destruct 语义（构造/析构）。ObjectPool 在 allocate 复用对象前
 * 调用 construct，在 recycle 回收对象时调用 destruct；用户可 override 这两个
 * 方法实现自定义的初始化/清理逻辑，未实现时宏会注入空实现。
 *
 * @file[en] IPoolObject  Pool-object lifecycle interface
 * @brief[en] Defines the lifecycle callbacks of pooled objects, auto-injected by the
 * \@PoolObject macro
 * @explain[en] This interface declares only two parameterless callbacks, construct and
 * destruct, and carries no fields. The \@PoolObject macro auto-implements it for
 * pooled object classes. Naming follows the construct/destruct semantics of the
 * TS RyFramework. ObjectPool calls construct before reusing an object via
 * allocate(), and destruct when recycling via recycle(); users may override the
 * two methods for custom init/cleanup logic, otherwise the macro injects no-op
 * implementations.
 *
 * @package three.utils.pool
 */
package three.utils.pool

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
