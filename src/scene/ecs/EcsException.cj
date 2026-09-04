/**
 * @file[zh-cn] EcsException ECS 框架异常
 * @brief[zh-cn] ECS 运行时的所有框架级错误统一抛出该异常
 * @explain[zh-cn] 触发场景：向实体重复添加同类型组件、向管理器重复添加同 ID 系统、
 * 回收仍挂在实体上的组件、添加未通过 @Component 注册的组件（cptId 为 NUM_NONE）
 *
 * @file[en] EcsException  ECS framework exception
 * @brief[en] All framework-level errors at ECS runtime are thrown as this exception type
 * @explain[en] Trigger scenarios: adding a duplicate component type to an entity, adding a duplicate
 * system ID to the manager, recycling a component still attached to an entity, adding a
 * component not registered via @Component (cptId is NUM_NONE)
 */
package three.scene.ecs

/**
 * @brief[zh-cn] ECS 框架异常类
 * @explain[zh-cn] ECS 运行时的所有框架级错误统一抛出该异常
 *
 * @brief[en] ECS framework exception class
 * @explain[en] All framework-level errors at ECS runtime are thrown as this exception type
 */
public class EcsException <: Exception {
    /**
     * @brief[zh-cn] 构造异常
     * @param[zh-cn] message 异常消息
     *
     * @brief[en] Construct an exception
     * @param[en] message Exception message
     */
    public init(message: String) {
        super(message)
    }
}
