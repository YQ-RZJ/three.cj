/**
 * @file sdl4cj CFFI 类型定义
 * @brief SDL3 C API 的枚举、句柄和结构体类型定义
 *
 * 本文件包含 SDL3 公共 API 的枚举、不透明句柄（指针别名）和 C 兼容结构体。
 *
 * @note 仓颉枚举是引用类型，不满足 CType 约束，不能直接用作 foreign 函数
 *       参数/返回值类型。foreign 函数使用 UInt32（底层 C 枚举表示），
 *       调用方通过 `EnumType.value()` 和 `EnumType.fromValue(u32)` 转换。
 * @note 位掩码类型（如 SDL_InitFlags、SDL_WindowFlags）以常量形式定义在
 *       constants.cj，foreign 函数直接使用 UInt32 / UInt64。
 * @note SDL_Event 是 C 联合体（union），仓颉侧用 `VArray<UInt8, $128>`
 *       申请同样大小的内存来替代 union 占据的内存空间，通过指针重解释
 *       读取具体事件字段。
 * @note 被仓颉保留字覆盖的字段名使用反引号转义（如 `type`）。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// 类型别名（C typedef）
// =============================================================================

/** @brief 窗口 ID（Uint32） */
public type SDL_WindowID = UInt32
/** @brief 显示器 ID（Uint32） */
public type SDL_DisplayID = UInt32
/** @brief 键盘实例 ID（Uint32） */
public type SDL_KeyboardID = UInt32
/** @brief 鼠标实例 ID（Uint32） */
public type SDL_MouseID = UInt32
/** @brief 触摸设备 ID（Uint64） */
public type SDL_TouchID = UInt64
/** @brief 触摸手指 ID（Uint64） */
public type SDL_FingerID = UInt64
/** @brief 定时器 ID（Int32） */
public type SDL_TimerID = Int32
/** @brief 属性集合 ID（Uint32） */
public type SDL_PropertiesID = UInt32
/** @brief 物理键码（SDL_Scancode, Uint32） */
public type SDL_Scancode = UInt32
/** @brief 虚拟键码（SDL_Keycode, Uint32） */
public type SDL_Keycode = UInt32
/** @brief 键盘修饰符位掩码（SDL_Keymod, Uint16） */
public type SDL_Keymod = UInt16
/** @brief 鼠标按键位掩码（SDL_MouseButtonFlags, Uint32） */
public type SDL_MouseButtonFlags = UInt32

// =============================================================================
// 不透明句柄（C 指针别名）
// =============================================================================

/** @brief 不透明窗口对象指针（SDL_Window *） */
public type SDL_Window = CPointer<Unit>
/** @brief 不透明光标对象指针（SDL_Cursor *） */
public type SDL_Cursor = CPointer<Unit>
/** @brief 不透明表面对象指针（SDL_Surface *） */
public type SDL_Surface = CPointer<Unit>

/** @brief 不透明渲染器对象指针（SDL_Renderer *） */
public type SDL_Renderer = CPointer<Unit>
/** @brief 不透明调色板对象指针（SDL_Palette *） */
public type SDL_Palette = CPointer<Unit>
/** @brief 不透明像素格式详情指针（SDL_PixelFormatDetails *） */
public type SDL_PixelFormatDetails = CPointer<Unit>
/** @brief 不透明显示模式指针（SDL_DisplayMode *） */
public type SDL_DisplayMode = CPointer<Unit>

// =============================================================================
// 枚举
// =============================================================================

/**
 * @brief SDL 事件类型
 * @explain 定义所有 SDL 事件类型的枚举值，用于判断事件种类。
 *         完整的事件类型常量见 constants.cj 中的 SDL_EVENT_*。
 */
public enum SDL_EventType {
    /** @brief 用户请求退出 */
    | Quit
    /** @brief 窗口已显示 */
    | WindowShown
    /** @brief 窗口已隐藏 */
    | WindowHidden
    /** @brief 窗口已移动（data1, data2 为坐标） */
    | WindowMoved
    /** @brief 窗口已调整大小（data1 x data2） */
    | WindowResized
    /** @brief 窗口已最小化 */
    | WindowMinimized
    /** @brief 窗口已最大化 */
    | WindowMaximized
    /** @brief 窗口已恢复 */
    | WindowRestored
    /** @brief 鼠标进入窗口 */
    | WindowMouseEnter
    /** @brief 鼠标离开窗口 */
    | WindowMouseLeave
    /** @brief 窗口获得键盘焦点 */
    | WindowFocusGained
    /** @brief 窗口失去键盘焦点 */
    | WindowFocusLost
    /** @brief 窗口管理器请求关闭窗口 */
    | WindowCloseRequested
    /** @brief 窗口被销毁 */
    | WindowDestroyed
    /** @brief 按键按下 */
    | KeyDown
    /** @brief 按键释放 */
    | KeyUp
    /** @brief 文本输入（组合） */
    | TextEditing
    /** @brief 文本输入 */
    | TextInput
    /** @brief 鼠标移动 */
    | MouseMotion
    /** @brief 鼠标按键按下 */
    | MouseButtonDown
    /** @brief 鼠标按键释放 */
    | MouseButtonUp
    /** @brief 鼠标滚轮 */
    | MouseWheel
    /** @brief 手指按下（触摸屏） */
    | FingerDown
    /** @brief 手指抬起（触摸屏） */
    | FingerUp
    /** @brief 手指移动（触摸屏） */
    | FingerMotion
    /** @brief 手指取消（触摸屏） */
    | FingerCanceled

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容） */
    public func value(): UInt32 {
        match (this) {
            case Quit => 0x100
            case WindowShown => 0x202
            case WindowHidden => 0x203
            case WindowMoved => 0x204
            case WindowResized => 0x205
            case WindowMinimized => 0x208
            case WindowMaximized => 0x209
            case WindowRestored => 0x20A
            case WindowMouseEnter => 0x20B
            case WindowMouseLeave => 0x20C
            case WindowFocusGained => 0x20D
            case WindowFocusLost => 0x20E
            case WindowCloseRequested => 0x20F
            case WindowDestroyed => 0x216
            case KeyDown => 0x300
            case KeyUp => 0x301
            case TextEditing => 0x302
            case TextInput => 0x303
            case MouseMotion => 0x400
            case MouseButtonDown => 0x401
            case MouseButtonUp => 0x402
            case MouseWheel => 0x403
            case FingerDown => 0x700
            case FingerUp => 0x701
            case FingerMotion => 0x702
            case FingerCanceled => 0x703
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值返回 Quit） */
    public static func fromValue(v: UInt32): SDL_EventType {
        match (v) {
            case 0x100 => Quit
            case 0x202 => WindowShown
            case 0x203 => WindowHidden
            case 0x204 => WindowMoved
            case 0x205 => WindowResized
            case 0x208 => WindowMinimized
            case 0x209 => WindowMaximized
            case 0x20A => WindowRestored
            case 0x20B => WindowMouseEnter
            case 0x20C => WindowMouseLeave
            case 0x20D => WindowFocusGained
            case 0x20E => WindowFocusLost
            case 0x20F => WindowCloseRequested
            case 0x216 => WindowDestroyed
            case 0x300 => KeyDown
            case 0x301 => KeyUp
            case 0x302 => TextEditing
            case 0x303 => TextInput
            case 0x400 => MouseMotion
            case 0x401 => MouseButtonDown
            case 0x402 => MouseButtonUp
            case 0x403 => MouseWheel
            case 0x700 => FingerDown
            case 0x701 => FingerUp
            case 0x702 => FingerMotion
            case 0x703 => FingerCanceled
            case _ => Quit
        }
    }
}

/**
 * @brief SDL 日志优先级
 * @explain 定义日志输出的优先级级别。
 */
public enum SDL_LogPriority {
    /** @brief 无效优先级 */
    | Invalid
    /** @brief 追踪（最详细） */
    | Trace
    /** @brief 详细 */
    | Verbose
    /** @brief 调试 */
    | Debug
    /** @brief 信息 */
    | Info
    /** @brief 警告 */
    | Warn
    /** @brief 错误 */
    | Error
    /** @brief 严重错误 */
    | Critical
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Invalid => 0
            case Trace => 1
            case Verbose => 2
            case Debug => 3
            case Info => 4
            case Warn => 5
            case Error => 6
            case Critical => 7
            case Count => 8
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_LogPriority {
        match (v) {
            case 0 => Invalid
            case 1 => Trace
            case 2 => Verbose
            case 3 => Debug
            case 4 => Info
            case 5 => Warn
            case 6 => Error
            case 7 => Critical
            case _ => Count
        }
    }
}

/**
 * @brief SDL 提示（Hint）优先级
 * @explain 定义设置提示时的优先级，决定是否覆盖已有值。
 */
public enum SDL_HintPriority {
    /** @brief 默认优先级 */
    | Default
    /** @brief 普通优先级 */
    | Normal
    /** @brief 覆盖已有值 */
    | Override

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Default => 0
            case Normal => 1
            case Override => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_HintPriority {
        match (v) {
            case 0 => Default
            case 1 => Normal
            case 2 => Override
            case _ => Default
        }
    }
}

/**
 * @brief SDL 属性类型
 * @explain 定义属性集合中属性值的类型。
 */
public enum SDL_PropertyType {
    /** @brief 无效属性 */
    | Invalid
    /** @brief 指针类型 */
    | Pointer
    /** @brief 字符串类型 */
    | String
    /** @brief 整数类型 */
    | Number
    /** @brief 浮点类型 */
    | Float
    /** @brief 布尔类型 */
    | Boolean

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Invalid => 0
            case Pointer => 1
            case String => 2
            case Number => 3
            case Float => 4
            case Boolean => 5
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_PropertyType {
        match (v) {
            case 0 => Invalid
            case 1 => Pointer
            case 2 => String
            case 3 => Number
            case 4 => Float
            case 5 => Boolean
            case _ => Invalid
        }
    }
}

/**
 * @brief SDL 系统光标类型
 * @explain 定义可创建的内置系统光标。
 */
public enum SDL_SystemCursor {
    /** @brief 默认箭头光标 */
    | Default
    /** @brief 文本输入 I 型光标 */
    | Text
    /** @brief 等待光标 */
    | Wait
    /** @brief 十字光标 */
    | Crosshair
    /** @brief 手型光标 */
    | Hand
    /** @brief 调整大小：水平 */
    | SizeHor
    /** @brief 调整大小：垂直 */
    | SizeVer
    /** @brief 调整大小：左上-右下 */
    | SizeNwse
    /** @brief 调整大小：右上-左下 */
    | SizeNesw
    /** @brief 调整大小：上下左右 */
    | SizeAll
    /** @brief 禁止光标 */
    | No
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Default => 0
            case Text => 1
            case Wait => 2
            case Crosshair => 3
            case Hand => 4
            case SizeHor => 5
            case SizeVer => 6
            case SizeNwse => 7
            case SizeNesw => 8
            case SizeAll => 9
            case No => 10
            case Count => 11
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_SystemCursor {
        match (v) {
            case 0 => Default
            case 1 => Text
            case 2 => Wait
            case 3 => Crosshair
            case 4 => Hand
            case 5 => SizeHor
            case 6 => SizeVer
            case 7 => SizeNwse
            case 8 => SizeNesw
            case 9 => SizeAll
            case 10 => No
            case _ => Count
        }
    }
}

/**
 * @brief SDL 触摸设备类型
 * @explain 定义触摸设备的类型。
 */
public enum SDL_TouchDeviceType {
    /** @brief 无效类型 */
    | Invalid
    /** @brief 直接触摸屏 */
    | Direct
    /** @brief 间接触摸板 */
    | IndirectAbsolute
    /** @brief 间接触摸板（相对坐标） */
    | IndirectRelative

    /** @brief 将枚举值转换为 UInt32（Invalid 在 C 端为 -1，以 UInt32 补码表示） */
    public func value(): UInt32 {
        match (this) {
            case Invalid => 0xFFFFFFFF
            case Direct => 0
            case IndirectAbsolute => 1
            case IndirectRelative => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_TouchDeviceType {
        match (v) {
            case 0 => Direct
            case 1 => IndirectAbsolute
            case 2 => IndirectRelative
            case _ => Invalid
        }
    }
}

/**
 * @brief SDL 像素格式
 * @explain 定义常用的像素格式枚举值（完整值见 constants.cj 的 SDL_PIXELFORMAT_*）。
 */
public enum SDL_PixelFormat {
    /** @brief 未知格式 */
    | Unknown
    /** @brief 索引 1 位 */
    | Index1LSB
    /** @brief 索引 8 位 */
    | Index8
    /** @brief RGB332 */
    | RGB332
    /** @brief XRGB4444 */
    | XRGB4444
    /** @brief XBGR4444 */
    | XBGR4444
    /** @brief XRGB1555 */
    | XRGB1555
    /** @brief XBGR1555 */
    | XBGR1555
    /** @brief ARGB8888 */
    | ARGB8888
    /** @brief RGBA8888 */
    | RGBA8888
    /** @brief ABGR8888 */
    | ABGR8888
    /** @brief BGRA8888 */
    | BGRA8888
    /** @brief RGB24 */
    | RGB24
    /** @brief BGR24 */
    | BGR24
    /** @brief RGBX8888 */
    | RGBX8888
    /** @brief BGRX8888 */
    | BGRX8888

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Unknown => 0
            case Index1LSB => 0x11100100
            case Index8 => 0x11800800
            case RGB332 => 0x11810800
            case XRGB4444 => 0x11820C00
            case XBGR4444 => 0x11900C00
            case XRGB1555 => 0x11821000
            case XBGR1555 => 0x11901000
            case ARGB8888 => 0x11862004
            case RGBA8888 => 0x11862005
            case ABGR8888 => 0x11872004
            case BGRA8888 => 0x11872005
            case RGB24 => 0x11861801
            case BGR24 => 0x11871801
            case RGBX8888 => 0x11862800
            case BGRX8888 => 0x11872800
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_PixelFormat {
        match (v) {
            case 0 => Unknown
            case 0x11100100 => Index1LSB
            case 0x11800800 => Index8
            case 0x11810800 => RGB332
            case 0x11820C00 => XRGB4444
            case 0x11900C00 => XBGR4444
            case 0x11821000 => XRGB1555
            case 0x11901000 => XBGR1555
            case 0x11862004 => ARGB8888
            case 0x11862005 => RGBA8888
            case 0x11872004 => ABGR8888
            case 0x11872005 => BGRA8888
            case 0x11861801 => RGB24
            case 0x11871801 => BGR24
            case 0x11862800 => RGBX8888
            case 0x11872800 => BGRX8888
            case _ => Unknown
        }
    }
}

// =============================================================================
// 结构体
// =============================================================================

/**
 * @brief 二维点（整数坐标）
 * @explain 对应 C 端 SDL_Point。
 */
@C
public struct SDL_Point {
    /** @brief X 坐标 */
    public var x: Int32 = 0
    /** @brief Y 坐标 */
    public var y: Int32 = 0
}

/**
 * @brief 二维点（浮点坐标）
 * @explain 对应 C 端 SDL_FPoint。
 */
@C
public struct SDL_FPoint {
    /** @brief X 坐标 */
    public var x: Float32 = 0.0
    /** @brief Y 坐标 */
    public var y: Float32 = 0.0
}

/**
 * @brief 矩形（整数坐标，原点在左上角）
 * @explain 对应 C 端 SDL_Rect。
 */
@C
public struct SDL_Rect {
    /** @brief 左上角 X 坐标 */
    public var x: Int32 = 0
    /** @brief 左上角 Y 坐标 */
    public var y: Int32 = 0
    /** @brief 宽度 */
    public var w: Int32 = 0
    /** @brief 高度 */
    public var h: Int32 = 0
}

/**
 * @brief 矩形（浮点坐标，原点在左上角）
 * @explain 对应 C 端 SDL_FRect。
 */
@C
public struct SDL_FRect {
    /** @brief 左上角 X 坐标 */
    public var x: Float32 = 0.0
    /** @brief 左上角 Y 坐标 */
    public var y: Float32 = 0.0
    /** @brief 宽度 */
    public var w: Float32 = 0.0
    /** @brief 高度 */
    public var h: Float32 = 0.0
}

/**
 * @brief RGBA 颜色
 * @explain 对应 C 端 SDL_Color，四个分量各占 1 字节。
 */
@C
public struct SDL_Color {
    /** @brief 红色分量 */
    public var r: UInt8 = 0
    /** @brief 绿色分量 */
    public var g: UInt8 = 0
    /** @brief 蓝色分量 */
    public var b: UInt8 = 0
    /** @brief 透明度分量 */
    public var a: UInt8 = 0
}

/**
 * @brief RGBA 颜色（浮点，0.0~1.0）
 * @explain 对应 C 端 SDL_FColor。
 */
@C
public struct SDL_FColor {
    /** @brief 红色分量 */
    public var r: Float32 = 0.0
    /** @brief 绿色分量 */
    public var g: Float32 = 0.0
    /** @brief 蓝色分量 */
    public var b: Float32 = 0.0
    /** @brief 透明度分量 */
    public var a: Float32 = 0.0
}

/**
 * @brief 所有事件共有的头部数据
 * @explain 对应 C 端 SDL_CommonEvent。
 */
@C
public struct SDL_CommonEvent {
    /** @brief 事件类型 */
    public var `type`: UInt32 = 0
    /** @brief 时间戳（纳秒，SDL_GetTicksNS() 产生） */
    public var timestamp: UInt64 = 0
}

/**
 * @brief 窗口事件
 * @explain 对应 C 端 SDL_WindowEvent。
 */
@C
public struct SDL_WindowEvent {
    /** @brief 事件类型（SDL_EVENT_WINDOW_*） */
    public var `type`: UInt32 = 0
    /** @brief 保留字段 */
    public var reserved: UInt32 = 0
    /** @brief 时间戳（纳秒） */
    public var timestamp: UInt64 = 0
    /** @brief 关联窗口 ID */
    public var windowID: UInt32 = 0
    /** @brief 事件相关数据 1 */
    public var data1: Int32 = 0
    /** @brief 事件相关数据 2 */
    public var data2: Int32 = 0
}

/**
 * @brief 键盘事件
 * @explain 对应 C 端 SDL_KeyboardEvent。
 */
@C
public struct SDL_KeyboardEvent {
    /** @brief 事件类型（SDL_EVENT_KEY_DOWN 或 SDL_EVENT_KEY_UP） */
    public var `type`: UInt32 = 0
    /** @brief 保留字段 */
    public var reserved: UInt32 = 0
    /** @brief 时间戳（纳秒） */
    public var timestamp: UInt64 = 0
    /** @brief 拥有键盘焦点的窗口 ID */
    public var windowID: UInt32 = 0
    /** @brief 键盘实例 ID（0 表示未知或虚拟） */
    public var which: UInt32 = 0
    /** @brief SDL 物理键码 */
    public var scancode: UInt32 = 0
    /** @brief SDL 虚拟键码 */
    public var key: UInt32 = 0
    /** @brief 当前按键修饰符 */
    public var mod: UInt16 = 0
    /** @brief 平台相关扫描码 */
    public var raw: UInt16 = 0
    /** @brief 是否按下 */
    public var down: Bool = false
    /** @brief 是否重复触发 */
    public var repeat: Bool = false
}

/**
 * @brief 鼠标移动事件
 * @explain 对应 C 端 SDL_MouseMotionEvent。
 */
@C
public struct SDL_MouseMotionEvent {
    /** @brief 事件类型（SDL_EVENT_MOUSE_MOTION） */
    public var `type`: UInt32 = 0
    /** @brief 保留字段 */
    public var reserved: UInt32 = 0
    /** @brief 时间戳（纳秒） */
    public var timestamp: UInt64 = 0
    /** @brief 拥有鼠标焦点的窗口 ID */
    public var windowID: UInt32 = 0
    /** @brief 鼠标实例 ID（0 表示未知） */
    public var which: UInt32 = 0
    /** @brief 当前按键状态 */
    public var state: UInt32 = 0
    /** @brief X 坐标（相对窗口） */
    public var x: Float32 = 0.0
    /** @brief Y 坐标（相对窗口） */
    public var y: Float32 = 0.0
    /** @brief X 方向相对移动 */
    public var xrel: Float32 = 0.0
    /** @brief Y 方向相对移动 */
    public var yrel: Float32 = 0.0
}

/**
 * @brief 鼠标按键事件
 * @explain 对应 C 端 SDL_MouseButtonEvent。
 */
@C
public struct SDL_MouseButtonEvent {
    /** @brief 事件类型（SDL_EVENT_MOUSE_BUTTON_DOWN 或 UP） */
    public var `type`: UInt32 = 0
    /** @brief 保留字段 */
    public var reserved: UInt32 = 0
    /** @brief 时间戳（纳秒） */
    public var timestamp: UInt64 = 0
    /** @brief 拥有鼠标焦点的窗口 ID */
    public var windowID: UInt32 = 0
    /** @brief 鼠标实例 ID（0 表示未知） */
    public var which: UInt32 = 0
    /** @brief 鼠标按键索引 */
    public var button: UInt8 = 0
    /** @brief 是否按下 */
    public var down: Bool = false
    /** @brief 点击次数（1 单击，2 双击） */
    public var clicks: UInt8 = 0
    /** @brief 填充字段 */
    public var padding: UInt8 = 0
    /** @brief X 坐标（相对窗口） */
    public var x: Float32 = 0.0
    /** @brief Y 坐标（相对窗口） */
    public var y: Float32 = 0.0
}

/**
 * @brief 鼠标滚轮事件
 * @explain 对应 C 端 SDL_MouseWheelEvent。
 */
@C
public struct SDL_MouseWheelEvent {
    /** @brief 事件类型（SDL_EVENT_MOUSE_WHEEL） */
    public var `type`: UInt32 = 0
    /** @brief 保留字段 */
    public var reserved: UInt32 = 0
    /** @brief 时间戳（纳秒） */
    public var timestamp: UInt64 = 0
    /** @brief 拥有鼠标焦点的窗口 ID */
    public var windowID: UInt32 = 0
    /** @brief 鼠标实例 ID（0 表示未知） */
    public var which: UInt32 = 0
    /** @brief 滚轮 X 方向滚动量 */
    public var x: Float32 = 0.0
    /** @brief 滚轮 Y 方向滚动量 */
    public var y: Float32 = 0.0
    /** @brief 滚动方向 */
    public var direction: UInt32 = 0
    /** @brief 鼠标精确滚动 */
    public var preciseX: Float32 = 0.0
    /** @brief 鼠标精确滚动 */
    public var preciseY: Float32 = 0.0
    /** @brief 鼠标滚轮位置 X */
    public var mouseX: Float32 = 0.0
    /** @brief 鼠标滚轮位置 Y */
    public var mouseY: Float32 = 0.0
}

/**
 * @brief 触摸手指事件
 * @explain 对应 C 端 SDL_TouchFingerEvent。
 */
@C
public struct SDL_TouchFingerEvent {
    /** @brief 事件类型（SDL_EVENT_FINGER_*） */
    public var `type`: UInt32 = 0
    /** @brief 保留字段 */
    public var reserved: UInt32 = 0
    /** @brief 时间戳（纳秒） */
    public var timestamp: UInt64 = 0
    /** @brief 触摸设备 ID */
    public var touchID: UInt64 = 0
    /** @brief 手指 ID */
    public var fingerID: UInt64 = 0
    /** @brief X 坐标（归一化 0~1） */
    public var x: Float32 = 0.0
    /** @brief Y 坐标（归一化 0~1） */
    public var y: Float32 = 0.0
    /** @brief X 方向移动（归一化 -1~1） */
    public var dx: Float32 = 0.0
    /** @brief Y 方向移动（归一化 -1~1） */
    public var dy: Float32 = 0.0
    /** @brief 压力（归一化 0~1） */
    public var pressure: Float32 = 0.0
    /** @brief 手指所在窗口 ID */
    public var windowID: UInt32 = 0
}

/**
 * @brief 退出事件
 * @explain 对应 C 端 SDL_QuitEvent。
 */
@C
public struct SDL_QuitEvent {
    /** @brief 事件类型（SDL_EVENT_QUIT） */
    public var `type`: UInt32 = 0
    /** @brief 保留字段 */
    public var reserved: UInt32 = 0
    /** @brief 时间戳（纳秒） */
    public var timestamp: UInt64 = 0
}

/**
 * @brief 文本输入事件
 * @explain 对应 C 端 SDL_TextInputEvent。包含窗口 ID 和 UTF-8 文本缓冲。
 *         SDL3 中 text 字段为 char[SDL_TEXTEDITINGEVENT_TEXT_SIZE]（32 字节）。
 */
@C
public struct SDL_TextInputEvent {
    /** @brief 事件类型（SDL_EVENT_TEXT_INPUT） */
    public var `type`: UInt32 = 0
    /** @brief 保留字段 */
    public var reserved: UInt32 = 0
    /** @brief 时间戳（纳秒） */
    public var timestamp: UInt64 = 0
    /** @brief 拥有焦点的窗口 ID */
    public var windowID: UInt32 = 0
    /** @brief UTF-8 文本（32 字节缓冲） */
    public var text: CPointer<Int8> = CPointer<Int8>()
}

/**
 * @brief SDL 事件（C 联合体）
 * @explain 对应 C 端 `typedef union SDL_Event`。C 联合体无法直接在仓颉
 *         中表示，因此用 128 字节的 `VArray<UInt8, $128>` 申请同样大小的
 *         内存来替代 union 占据的内存空间。通过 `CPointer<SDL_Event>`
 *         传给 SDL_PollEvent 等函数；读取具体事件时，将指针重解释为
 *        对应的具体事件结构体（如 SDL_KeyboardEvent）再读取字段。
 */
@C
public struct SDL_Event {
    /** @brief 128 字节原始缓冲，与 C 端 SDL_Event union 大小一致 */
    public var data: VArray<UInt8, $128> = VArray<UInt8, $128>(repeat: 0)
}
