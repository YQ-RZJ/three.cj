/**
 * @file sdl4cj 常量定义
 * @brief SDL3 C API 的常量定义
 *
 * 本文件包含 SDL3 公共 API 的常量，包括初始化标志、窗口标志、事件类型、
 * 键码、扫描码、鼠标按键等。
 *
 * @note 这些常量直接映射自 C 头文件中的宏定义。
 * @note 位掩码常量（SDL_InitFlags、SDL_WindowFlags、SDL_Keymod 等）在
 *       foreign 函数中直接以 UInt32 / UInt64 / UInt16 传递。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// 初始化标志（SDL_InitFlags, Uint32 位掩码）
// =============================================================================

/** @brief 音频子系统（隐含 EVENTS） */
public const SDL_INIT_AUDIO: UInt32 = 0x00000010
/** @brief 视频子系统（隐含 EVENTS，应在主线程初始化） */
public const SDL_INIT_VIDEO: UInt32 = 0x00000020
/** @brief 操纵杆子系统（隐含 EVENTS） */
public const SDL_INIT_JOYSTICK: UInt32 = 0x00000200
/** @brief 力反馈子系统 */
public const SDL_INIT_HAPTIC: UInt32 = 0x00001000
/** @brief 手柄子系统（隐含 JOYSTICK） */
public const SDL_INIT_GAMEPAD: UInt32 = 0x00002000
/** @brief 事件子系统 */
public const SDL_INIT_EVENTS: UInt32 = 0x00004000
/** @brief 传感器子系统（隐含 EVENTS） */
public const SDL_INIT_SENSOR: UInt32 = 0x00008000
/** @brief 相机子系统（隐含 EVENTS，已剔除功能） */
public const SDL_INIT_CAMERA: UInt32 = 0x00010000

// =============================================================================
// 窗口标志（SDL_WindowFlags, Uint64 位掩码）
// =============================================================================

/** @brief 窗口处于全屏模式 */
public const SDL_WINDOW_FULLSCREEN: UInt64 = 0x0000000000000001
/** @brief 窗口可用于 OpenGL 上下文 */
public const SDL_WINDOW_OPENGL: UInt64 = 0x0000000000000002
/** @brief 窗口被遮挡 */
public const SDL_WINDOW_OCCLUDED: UInt64 = 0x0000000000000004
/** @brief 窗口隐藏（需 SDL_ShowWindow 显示） */
public const SDL_WINDOW_HIDDEN: UInt64 = 0x0000000000000008
/** @brief 无边框窗口 */
public const SDL_WINDOW_BORDERLESS: UInt64 = 0x0000000000000010
/** @brief 窗口可调整大小 */
public const SDL_WINDOW_RESIZABLE: UInt64 = 0x0000000000000020
/** @brief 窗口已最小化 */
public const SDL_WINDOW_MINIMIZED: UInt64 = 0x0000000000000040
/** @brief 窗口已最大化 */
public const SDL_WINDOW_MAXIMIZED: UInt64 = 0x0000000000000080
/** @brief 窗口已捕获鼠标输入 */
public const SDL_WINDOW_MOUSE_GRABBED: UInt64 = 0x0000000000000100
/** @brief 窗口拥有输入焦点 */
public const SDL_WINDOW_INPUT_FOCUS: UInt64 = 0x0000000000000200
/** @brief 窗口拥有鼠标焦点 */
public const SDL_WINDOW_MOUSE_FOCUS: UInt64 = 0x0000000000000400
/** @brief 窗口非 SDL 创建 */
public const SDL_WINDOW_EXTERNAL: UInt64 = 0x0000000000000800
/** @brief 模态窗口 */
public const SDL_WINDOW_MODAL: UInt64 = 0x0000000000001000
/** @brief 高像素密度后备缓冲 */
public const SDL_WINDOW_HIGH_PIXEL_DENSITY: UInt64 = 0x0000000000002000
/** @brief 窗口已捕获鼠标（与 MOUSE_GRABBED 无关） */
public const SDL_WINDOW_MOUSE_CAPTURE: UInt64 = 0x0000000000004000
/** @brief 窗口处于相对鼠标模式 */
public const SDL_WINDOW_MOUSE_RELATIVE_MODE: UInt64 = 0x0000000000008000
/** @brief 窗口应始终置顶 */
public const SDL_WINDOW_ALWAYS_ON_TOP: UInt64 = 0x0000000000010000
/** @brief 工具窗口（不显示在任务栏） */
public const SDL_WINDOW_UTILITY: UInt64 = 0x0000000000020000
/** @brief 工具提示窗口（不获取焦点，需父窗口） */
public const SDL_WINDOW_TOOLTIP: UInt64 = 0x0000000000040000
/** @brief 弹出菜单窗口（需父窗口） */
public const SDL_WINDOW_POPUP_MENU: UInt64 = 0x0000000000080000
/** @brief 窗口已捕获键盘输入 */
public const SDL_WINDOW_KEYBOARD_GRABBED: UInt64 = 0x0000000000100000
/** @brief 窗口可用于 Vulkan 表面 */
public const SDL_WINDOW_VULKAN: UInt64 = 0x0000000010000000
/** @brief 窗口可用于 Metal 视图 */
public const SDL_WINDOW_METAL: UInt64 = 0x0000000020000000
/** @brief 透明缓冲窗口 */
public const SDL_WINDOW_TRANSPARENT: UInt64 = 0x0000000040000000
/** @brief 窗口不可聚焦 */
public const SDL_WINDOW_NOT_FOCUSABLE: UInt64 = 0x0000000080000000

// =============================================================================
// 事件类型（SDL_EventType, 常用值；完整枚举见 types.cj）
// =============================================================================

/** @brief 用户请求退出 */
public const SDL_EVENT_QUIT: UInt32 = 0x100
/** @brief 窗口已显示 */
public const SDL_EVENT_WINDOW_SHOWN: UInt32 = 0x202
/** @brief 窗口已隐藏 */
public const SDL_EVENT_WINDOW_HIDDEN: UInt32 = 0x203
/** @brief 窗口已移动 */
public const SDL_EVENT_WINDOW_MOVED: UInt32 = 0x205
/** @brief 窗口已调整大小 */
public const SDL_EVENT_WINDOW_RESIZED: UInt32 = 0x206
/** @brief 窗口已最小化 */
public const SDL_EVENT_WINDOW_MINIMIZED: UInt32 = 0x209
/** @brief 窗口已最大化 */
public const SDL_EVENT_WINDOW_MAXIMIZED: UInt32 = 0x20A
/** @brief 窗口已恢复 */
public const SDL_EVENT_WINDOW_RESTORED: UInt32 = 0x20B
/** @brief 鼠标进入窗口 */
public const SDL_EVENT_WINDOW_MOUSE_ENTER: UInt32 = 0x20C
/** @brief 鼠标离开窗口 */
public const SDL_EVENT_WINDOW_MOUSE_LEAVE: UInt32 = 0x20D
/** @brief 窗口获得键盘焦点 */
public const SDL_EVENT_WINDOW_FOCUS_GAINED: UInt32 = 0x20E
/** @brief 窗口失去键盘焦点 */
public const SDL_EVENT_WINDOW_FOCUS_LOST: UInt32 = 0x20F
/** @brief 窗口管理器请求关闭窗口 */
public const SDL_EVENT_WINDOW_CLOSE_REQUESTED: UInt32 = 0x210
/** @brief 窗口被销毁 */
public const SDL_EVENT_WINDOW_DESTROYED: UInt32 = 0x219
/** @brief 按键按下 */
public const SDL_EVENT_KEY_DOWN: UInt32 = 0x300
/** @brief 按键释放 */
public const SDL_EVENT_KEY_UP: UInt32 = 0x301
/** @brief 文本编辑（组合） */
public const SDL_EVENT_TEXT_EDITING: UInt32 = 0x302
/** @brief 文本输入 */
public const SDL_EVENT_TEXT_INPUT: UInt32 = 0x303
/** @brief 鼠标移动 */
public const SDL_EVENT_MOUSE_MOTION: UInt32 = 0x400
/** @brief 鼠标按键按下 */
public const SDL_EVENT_MOUSE_BUTTON_DOWN: UInt32 = 0x401
/** @brief 鼠标按键释放 */
public const SDL_EVENT_MOUSE_BUTTON_UP: UInt32 = 0x402
/** @brief 鼠标滚轮 */
public const SDL_EVENT_MOUSE_WHEEL: UInt32 = 0x403
/** @brief 手指按下（触摸屏） */
public const SDL_EVENT_FINGER_DOWN: UInt32 = 0x700
/** @brief 手指抬起（触摸屏） */
public const SDL_EVENT_FINGER_UP: UInt32 = 0x701
/** @brief 手指移动（触摸屏） */
public const SDL_EVENT_FINGER_MOTION: UInt32 = 0x702
/** @brief 手指取消（触摸屏） */
public const SDL_EVENT_FINGER_CANCELED: UInt32 = 0x703

// =============================================================================
// 键盘修饰符（SDL_Keymod, Uint16 位掩码）
// =============================================================================

/** @brief 无修饰符 */
public const SDL_KMOD_NONE: UInt16 = 0x0000
/** @brief 左 Shift */
public const SDL_KMOD_LSHIFT: UInt16 = 0x0001
/** @brief 右 Shift */
public const SDL_KMOD_RSHIFT: UInt16 = 0x0002
/** @brief 左 Ctrl */
public const SDL_KMOD_LCTRL: UInt16 = 0x0040
/** @brief 右 Ctrl */
public const SDL_KMOD_RCTRL: UInt16 = 0x0080
/** @brief 左 Alt */
public const SDL_KMOD_LALT: UInt16 = 0x0100
/** @brief 右 Alt */
public const SDL_KMOD_RALT: UInt16 = 0x0200
/** @brief 左 GUI（Win/Command） */
public const SDL_KMOD_LGUI: UInt16 = 0x0400
/** @brief 右 GUI（Win/Command） */
public const SDL_KMOD_RGUI: UInt16 = 0x0800
/** @brief 数字键盘 */
public const SDL_KMOD_NUM: UInt16 = 0x1000
/** @brief 大写锁定 */
public const SDL_KMOD_CAPS: UInt16 = 0x2000
/** @brief 模式键 */
public const SDL_KMOD_MODE: UInt16 = 0x4000
/** @brief Shift 组合掩码 */
public const SDL_KMOD_SHIFT: UInt16 = 0x0003
/** @brief Ctrl 组合掩码 */
public const SDL_KMOD_CTRL: UInt16 = 0x00C0
/** @brief Alt 组合掩码 */
public const SDL_KMOD_ALT: UInt16 = 0x0300
/** @brief GUI 组合掩码 */
public const SDL_KMOD_GUI: UInt16 = 0x0C00

// =============================================================================
// 鼠标按键（SDL_BUTTON_*）
// =============================================================================

/** @brief 鼠标左键索引 */
public const SDL_BUTTON_LEFT: UInt8 = 1
/** @brief 鼠标中键索引 */
public const SDL_BUTTON_MIDDLE: UInt8 = 2
/** @brief 鼠标右键索引 */
public const SDL_BUTTON_RIGHT: UInt8 = 3
/** @brief 鼠标 X1 键索引 */
public const SDL_BUTTON_X1: UInt8 = 4
/** @brief 鼠标 X2 键索引 */
public const SDL_BUTTON_X2: UInt8 = 5
/** @brief 鼠标左键状态掩码 */
public const SDL_BUTTON_LMASK: UInt32 = 0x0001
/** @brief 鼠标中键状态掩码 */
public const SDL_BUTTON_MMASK: UInt32 = 0x0002
/** @brief 鼠标右键状态掩码 */
public const SDL_BUTTON_RMASK: UInt32 = 0x0004
/** @brief 鼠标 X1 键状态掩码 */
public const SDL_BUTTON_X1MASK: UInt32 = 0x0008
/** @brief 鼠标 X2 键状态掩码 */
public const SDL_BUTTON_X2MASK: UInt32 = 0x0010

// =============================================================================
// 虚拟键码（SDLK_*, 常用值）
// =============================================================================

/** @brief 回车键 */
public const SDLK_RETURN: UInt32 = 0x0000000d
/** @brief Esc 键 */
public const SDLK_ESCAPE: UInt32 = 0x0000001b
/** @brief 退格键 */
public const SDLK_BACKSPACE: UInt32 = 0x00000008
/** @brief Tab 键 */
public const SDLK_TAB: UInt32 = 0x00000009
/** @brief 空格键 */
public const SDLK_SPACE: UInt32 = 0x00000020
/** @brief 数字键 0 */
public const SDLK_0: UInt32 = 0x00000030
/** @brief 数字键 1 */
public const SDLK_1: UInt32 = 0x00000031
/** @brief 数字键 2 */
public const SDLK_2: UInt32 = 0x00000032
/** @brief 数字键 3 */
public const SDLK_3: UInt32 = 0x00000033
/** @brief 数字键 4 */
public const SDLK_4: UInt32 = 0x00000034
/** @brief 数字键 5 */
public const SDLK_5: UInt32 = 0x00000035
/** @brief 数字键 6 */
public const SDLK_6: UInt32 = 0x00000036
/** @brief 数字键 7 */
public const SDLK_7: UInt32 = 0x00000037
/** @brief 数字键 8 */
public const SDLK_8: UInt32 = 0x00000038
/** @brief 数字键 9 */
public const SDLK_9: UInt32 = 0x00000039
/** @brief 字母键 A */
public const SDLK_a: UInt32 = 0x00000061
/** @brief 字母键 B */
public const SDLK_b: UInt32 = 0x00000062
/** @brief 字母键 C */
public const SDLK_c: UInt32 = 0x00000063
/** @brief 字母键 D */
public const SDLK_d: UInt32 = 0x00000064
/** @brief 字母键 E */
public const SDLK_e: UInt32 = 0x00000065
/** @brief 字母键 F */
public const SDLK_f: UInt32 = 0x00000066
/** @brief 字母键 G */
public const SDLK_g: UInt32 = 0x00000067
/** @brief 字母键 H */
public const SDLK_h: UInt32 = 0x00000068
/** @brief 字母键 I */
public const SDLK_i: UInt32 = 0x00000069
/** @brief 字母键 J */
public const SDLK_j: UInt32 = 0x0000006a
/** @brief 字母键 K */
public const SDLK_k: UInt32 = 0x0000006b
/** @brief 字母键 L */
public const SDLK_l: UInt32 = 0x0000006c
/** @brief 字母键 M */
public const SDLK_m: UInt32 = 0x0000006d
/** @brief 字母键 N */
public const SDLK_n: UInt32 = 0x0000006e
/** @brief 字母键 O */
public const SDLK_o: UInt32 = 0x0000006f
/** @brief 字母键 P */
public const SDLK_p: UInt32 = 0x00000070
/** @brief 字母键 Q */
public const SDLK_q: UInt32 = 0x00000071
/** @brief 字母键 R */
public const SDLK_r: UInt32 = 0x00000072
/** @brief 字母键 S */
public const SDLK_s: UInt32 = 0x00000073
/** @brief 字母键 T */
public const SDLK_t: UInt32 = 0x00000074
/** @brief 字母键 U */
public const SDLK_u: UInt32 = 0x00000075
/** @brief 字母键 V */
public const SDLK_v: UInt32 = 0x00000076
/** @brief 字母键 W */
public const SDLK_w: UInt32 = 0x00000077
/** @brief 字母键 X */
public const SDLK_x: UInt32 = 0x00000078
/** @brief 字母键 Y */
public const SDLK_y: UInt32 = 0x00000079
/** @brief 字母键 Z */
public const SDLK_z: UInt32 = 0x0000007a
/** @brief Delete 键 */
public const SDLK_DELETE: UInt32 = 0x0000007f
/** @brief 大写锁定键 */
public const SDLK_CAPSLOCK: UInt32 = 0x40000039
/** @brief 功能键 F1 */
public const SDLK_F1: UInt32 = 0x4000003a
/** @brief 功能键 F2 */
public const SDLK_F2: UInt32 = 0x4000003b
/** @brief 功能键 F3 */
public const SDLK_F3: UInt32 = 0x4000003c
/** @brief 功能键 F4 */
public const SDLK_F4: UInt32 = 0x4000003d
/** @brief 功能键 F5 */
public const SDLK_F5: UInt32 = 0x4000003e
/** @brief 功能键 F6 */
public const SDLK_F6: UInt32 = 0x4000003f
/** @brief 功能键 F7 */
public const SDLK_F7: UInt32 = 0x40000040
/** @brief 功能键 F8 */
public const SDLK_F8: UInt32 = 0x40000041
/** @brief 功能键 F9 */
public const SDLK_F9: UInt32 = 0x40000042
/** @brief 功能键 F10 */
public const SDLK_F10: UInt32 = 0x40000043
/** @brief 功能键 F11 */
public const SDLK_F11: UInt32 = 0x40000044
/** @brief 功能键 F12 */
public const SDLK_F12: UInt32 = 0x40000045
/** @brief Home 键 */
public const SDLK_HOME: UInt32 = 0x4000004a
/** @brief PageUp 键 */
public const SDLK_PAGEUP: UInt32 = 0x4000004b
/** @brief End 键 */
public const SDLK_END: UInt32 = 0x4000004d
/** @brief PageDown 键 */
public const SDLK_PAGEDOWN: UInt32 = 0x4000004e
/** @brief 方向键 右 */
public const SDLK_RIGHT: UInt32 = 0x4000004f
/** @brief 方向键 左 */
public const SDLK_LEFT: UInt32 = 0x40000050
/** @brief 方向键 下 */
public const SDLK_DOWN: UInt32 = 0x40000051
/** @brief 方向键 上 */
public const SDLK_UP: UInt32 = 0x40000052
/** @brief 左 Ctrl */
public const SDLK_LCTRL: UInt32 = 0x400000e0
/** @brief 左 Shift */
public const SDLK_LSHIFT: UInt32 = 0x400000e1
/** @brief 左 Alt */
public const SDLK_LALT: UInt32 = 0x400000e2
/** @brief 右 Ctrl */
public const SDLK_RCTRL: UInt32 = 0x400000e4
/** @brief 右 Shift */
public const SDLK_RSHIFT: UInt32 = 0x400000e5
/** @brief 右 Alt */
public const SDLK_RALT: UInt32 = 0x400000e6

// =============================================================================
// 物理扫描码（SDL_SCANCODE_*, 常用值）
// =============================================================================

/** @brief 扫描码 A */
public const SDL_SCANCODE_A: UInt32 = 4
/** @brief 扫描码 B */
public const SDL_SCANCODE_B: UInt32 = 5
/** @brief 扫描码 C */
public const SDL_SCANCODE_C: UInt32 = 6
/** @brief 扫描码 D */
public const SDL_SCANCODE_D: UInt32 = 7
/** @brief 扫描码 E */
public const SDL_SCANCODE_E: UInt32 = 8
/** @brief 扫描码 F */
public const SDL_SCANCODE_F: UInt32 = 9
/** @brief 扫描码 G */
public const SDL_SCANCODE_G: UInt32 = 10
/** @brief 扫描码 H */
public const SDL_SCANCODE_H: UInt32 = 11
/** @brief 扫描码 I */
public const SDL_SCANCODE_I: UInt32 = 12
/** @brief 扫描码 J */
public const SDL_SCANCODE_J: UInt32 = 13
/** @brief 扫描码 K */
public const SDL_SCANCODE_K: UInt32 = 14
/** @brief 扫描码 L */
public const SDL_SCANCODE_L: UInt32 = 15
/** @brief 扫描码 M */
public const SDL_SCANCODE_M: UInt32 = 16
/** @brief 扫描码 N */
public const SDL_SCANCODE_N: UInt32 = 17
/** @brief 扫描码 O */
public const SDL_SCANCODE_O: UInt32 = 18
/** @brief 扫描码 P */
public const SDL_SCANCODE_P: UInt32 = 19
/** @brief 扫描码 Q */
public const SDL_SCANCODE_Q: UInt32 = 20
/** @brief 扫描码 R */
public const SDL_SCANCODE_R: UInt32 = 21
/** @brief 扫描码 S */
public const SDL_SCANCODE_S: UInt32 = 22
/** @brief 扫描码 T */
public const SDL_SCANCODE_T: UInt32 = 23
/** @brief 扫描码 U */
public const SDL_SCANCODE_U: UInt32 = 24
/** @brief 扫描码 V */
public const SDL_SCANCODE_V: UInt32 = 25
/** @brief 扫描码 W */
public const SDL_SCANCODE_W: UInt32 = 26
/** @brief 扫描码 X */
public const SDL_SCANCODE_X: UInt32 = 27
/** @brief 扫描码 Y */
public const SDL_SCANCODE_Y: UInt32 = 28
/** @brief 扫描码 Z */
public const SDL_SCANCODE_Z: UInt32 = 29
/** @brief 扫描码 0 */
public const SDL_SCANCODE_0: UInt32 = 39
/** @brief 扫描码 1 */
public const SDL_SCANCODE_1: UInt32 = 30
/** @brief 扫描码 2 */
public const SDL_SCANCODE_2: UInt32 = 31
/** @brief 扫描码 3 */
public const SDL_SCANCODE_3: UInt32 = 32
/** @brief 扫描码 4 */
public const SDL_SCANCODE_4: UInt32 = 33
/** @brief 扫描码 5 */
public const SDL_SCANCODE_5: UInt32 = 34
/** @brief 扫描码 6 */
public const SDL_SCANCODE_6: UInt32 = 35
/** @brief 扫描码 7 */
public const SDL_SCANCODE_7: UInt32 = 36
/** @brief 扫描码 8 */
public const SDL_SCANCODE_8: UInt32 = 37
/** @brief 扫描码 9 */
public const SDL_SCANCODE_9: UInt32 = 38
/** @brief 扫描码 回车 */
public const SDL_SCANCODE_RETURN: UInt32 = 40
/** @brief 扫描码 Esc */
public const SDL_SCANCODE_ESCAPE: UInt32 = 41
/** @brief 扫描码 退格 */
public const SDL_SCANCODE_BACKSPACE: UInt32 = 42
/** @brief 扫描码 Tab */
public const SDL_SCANCODE_TAB: UInt32 = 43
/** @brief 扫描码 空格 */
public const SDL_SCANCODE_SPACE: UInt32 = 44
/** @brief 扫描码 大写锁定 */
public const SDL_SCANCODE_CAPSLOCK: UInt32 = 57
/** @brief 扫描码 F1 */
public const SDL_SCANCODE_F1: UInt32 = 58
/** @brief 扫描码 F2 */
public const SDL_SCANCODE_F2: UInt32 = 59
/** @brief 扫描码 F3 */
public const SDL_SCANCODE_F3: UInt32 = 60
/** @brief 扫描码 F4 */
public const SDL_SCANCODE_F4: UInt32 = 61
/** @brief 扫描码 F5 */
public const SDL_SCANCODE_F5: UInt32 = 62
/** @brief 扫描码 F6 */
public const SDL_SCANCODE_F6: UInt32 = 63
/** @brief 扫描码 F7 */
public const SDL_SCANCODE_F7: UInt32 = 64
/** @brief 扫描码 F8 */
public const SDL_SCANCODE_F8: UInt32 = 65
/** @brief 扫描码 F9 */
public const SDL_SCANCODE_F9: UInt32 = 66
/** @brief 扫描码 F10 */
public const SDL_SCANCODE_F10: UInt32 = 67
/** @brief 扫描码 F11 */
public const SDL_SCANCODE_F11: UInt32 = 68
/** @brief 扫描码 F12 */
public const SDL_SCANCODE_F12: UInt32 = 69
/** @brief 扫描码 Delete */
public const SDL_SCANCODE_DELETE: UInt32 = 76
/** @brief 扫描码 方向键 右 */
public const SDL_SCANCODE_RIGHT: UInt32 = 79
/** @brief 扫描码 方向键 左 */
public const SDL_SCANCODE_LEFT: UInt32 = 80
/** @brief 扫描码 方向键 下 */
public const SDL_SCANCODE_DOWN: UInt32 = 81
/** @brief 扫描码 方向键 上 */
public const SDL_SCANCODE_UP: UInt32 = 82
/** @brief 扫描码 左 Ctrl */
public const SDL_SCANCODE_LCTRL: UInt32 = 224
/** @brief 扫描码 左 Shift */
public const SDL_SCANCODE_LSHIFT: UInt32 = 225
/** @brief 扫描码 左 Alt */
public const SDL_SCANCODE_LALT: UInt32 = 226
/** @brief 扫描码 右 Ctrl */
public const SDL_SCANCODE_RCTRL: UInt32 = 228
/** @brief 扫描码 右 Shift */
public const SDL_SCANCODE_RSHIFT: UInt32 = 229
/** @brief 扫描码 右 Alt */
public const SDL_SCANCODE_RALT: UInt32 = 230

// =============================================================================
// 窗口原生句柄属性名（跨平台获取 bgfx 所需 nwh）
// =============================================================================

/** @brief Windows 平台原生窗口句柄属性名 */
public const SDL_PROP_WINDOW_WIN32_HWND_POINTER: String = "SDL.window.win32.hwnd"
/** @brief macOS Cocoa 平台原生窗口句柄属性名 */
public const SDL_PROP_WINDOW_COCOA_WINDOW_POINTER: String = "SDL.window.cocoa.window"
/** @brief X11 平台原生窗口句柄属性名 */
public const SDL_PROP_WINDOW_X11_WINDOW_NUMBER: String = "SDL.window.x11.window"
/** @brief Wayland 平台原生窗口句柄属性名 */
public const SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER: String = "SDL.window.wayland.surface"
/** @brief Android 平台原生窗口句柄属性名 */
public const SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER: String = "SDL.window.android.window"
/** @brief iOS 平台原生窗口句柄属性名 */
public const SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER: String = "SDL.window.uikit.window"
/** @brief OHOS 平台原生窗口句柄属性名（OHNativeWindow*，可绑定 OpenGL/bgfx 等渲染后端） */
public const SDL_PROP_WINDOW_OHOS_WINDOW_POINTER: String = "SDL.window.ohos.window"
