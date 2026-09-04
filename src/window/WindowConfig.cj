/**
 * @file[zh-cn] WindowConfig 窗口创建配置
 * @brief[zh-cn] 本文件定义窗口创建配置结构
 * @explain[zh-cn] 描述 WindowEngine.start 创建窗口时指定的窗口属性。
 *
 * @file[en] WindowConfig Window creation configuration
 * @brief[en] This file defines the window creation configuration structure
 * @explain[en] Describes the window attributes specified when WindowEngine.start creates a window.
 */
package three.window

/**
 * @brief[zh-cn] 窗口创建配置
 * @explain[zh-cn] 创建后仍可通过 WindowEngine 的对应方法（setResizable/setFullscreen/setOpacity 等）动态调整。
 *
 * @brief[en] Window creation configuration
 * @explain[en] After creation, the window can still be adjusted dynamically via the corresponding WindowEngine methods (setResizable/setFullscreen/setOpacity, etc.).
 */
public class WindowConfig {
    /**
     * @brief[zh-cn] 是否可由用户调整大小（对应 SDL_WINDOW_RESIZABLE，默认 true——保持现有行为）
     *
     * @brief[en] Whether the user can resize the window (SDL_WINDOW_RESIZABLE; defaults to true to keep existing behavior)
     */
    public var resizable: Bool = true
    /**
     * @brief[zh-cn] 是否全屏窗口（对应 SDL_WINDOW_FULLSCREEN，默认 false）
     *
     * @brief[en] Whether the window is fullscreen (SDL_WINDOW_FULLSCREEN; defaults to false)
     */
    public var fullscreen: Bool = false
    /**
     * @brief[zh-cn] 是否无边框窗口（对应 SDL_WINDOW_BORDERLESS，默认 false）
     *
     * @brief[en] Whether the window is borderless (SDL_WINDOW_BORDERLESS; defaults to false)
     */
    public var borderless: Bool = false
    /**
     * @brief[zh-cn] 是否置顶（对应 SDL_WINDOW_ALWAYS_ON_TOP，默认 false）
     *
     * @brief[en] Whether the window stays on top (SDL_WINDOW_ALWAYS_ON_TOP; defaults to false)
     */
    public var alwaysOnTop: Bool = false
    /**
     * @brief[zh-cn] 是否启用高像素密度 HiDPI（对应 SDL_WINDOW_HIGH_PIXEL_DENSITY，默认 true）
     *
     * @brief[en] Whether high pixel density (HiDPI) is enabled (SDL_WINDOW_HIGH_PIXEL_DENSITY; defaults to true)
     */
    public var highPixelDensity: Bool = true
    /**
     * @brief[zh-cn] 窗口透明度（0.0=完全透明，1.0=不透明；默认 1.0——创建后通过 SDL_SetWindowOpacity 应用）
     *
     * @brief[en] Window opacity (0.0=fully transparent, 1.0=opaque; defaults to 1.0, applied after creation via SDL_SetWindowOpacity)
     */
    public var opacity: Float32 = 1.0
    /**
     * @brief[zh-cn] 最小宽度（0=不限制；创建后通过 SDL_SetWindowMinimumSize 应用）
     *
     * @brief[en] Minimum width (0=unlimited; applied after creation via SDL_SetWindowMinimumSize)
     */
    public var minWidth: Int32 = 0
    /**
     * @brief[zh-cn] 最小高度（0=不限制；创建后通过 SDL_SetWindowMinimumSize 应用）
     *
     * @brief[en] Minimum height (0=unlimited; applied after creation via SDL_SetWindowMinimumSize)
     */
    public var minHeight: Int32 = 0
    /**
     * @brief[zh-cn] 最大宽度（0=不限制；创建后通过 SDL_SetWindowMaximumSize 应用）
     *
     * @brief[en] Maximum width (0=unlimited; applied after creation via SDL_SetWindowMaximumSize)
     */
    public var maxWidth: Int32 = 0
    /**
     * @brief[zh-cn] 最大高度（0=不限制；创建后通过 SDL_SetWindowMaximumSize 应用）
     *
     * @brief[en] Maximum height (0=unlimited; applied after creation via SDL_SetWindowMaximumSize)
     */
    public var maxHeight: Int32 = 0

    /**
     * @brief[zh-cn] 构造默认窗口配置
     *
     * @brief[en] Constructs the default window configuration
     */
    public init() {}
}
