/**
 * @file[zh-cn] 检查器基类
 * @brief[zh-cn] 调试检查器基类，提供启用/禁用和更新接口
 * @explain[zh-cn] 
 * InspectorBase 是渲染调试检查器的基类，提供 enabled 开关以及 show/hide/update 方法。
 * 子类可扩展为帧率监控、draw call 统计等调试工具。
 *
 * @file[en] InspectorBase
 * @brief[en] Debug inspector base class, providing enable/disable and update interfaces
 * @explain[en] 
 * InspectorBase is the base class for rendering debug inspectors, providing an enabled switch and show/hide/update methods.
 * Subclasses can be extended for frame rate monitoring, draw call statistics, and other debugging tools.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 调试检查器基类
 * @explain[zh-cn] 
 * 提供 enabled 开关以及 show/hide/update 方法，子类可扩展为各种调试工具。
 *
 * @brief[en] Debug inspector base class
 * @explain[en] 
 * Provides an enabled switch and show/hide/update methods; subclasses can be extended for various debugging tools.
 */
public open class InspectorBase {
    /**
     * @brief[zh-cn] 是否启用检查器
     *
     * @brief[en] Whether the inspector is enabled
     */
    public var enabled: Bool

    /**
     * @brief[zh-cn] 构造默认检查器（禁用状态）
     *
     * @brief[en] Constructs a default inspector (disabled state)
     */
    public init() { this.enabled = false }

    /**
     * @brief[zh-cn] 更新检查器（子类覆写）
     *
     * @brief[en] Updates the inspector (override in subclasses)
     */
    public func update(): Unit { }

    /**
     * @brief[zh-cn] 显示检查器
     *
     * @brief[en] Shows the inspector
     */
    public func show(): Unit { this.enabled = true }

    /**
     * @brief[zh-cn] 隐藏检查器
     *
     * @brief[en] Hides the inspector
     */
    public func hide(): Unit { this.enabled = false }
}
