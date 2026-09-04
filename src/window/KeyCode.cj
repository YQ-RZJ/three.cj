/**
 * @file[zh-cn] KeyCode 键盘/鼠标常量（three.window 子包）
 * @brief[zh-cn] three.window 自有的键盘/鼠标常量（替代直接依赖 sdl4cj 的 SDL_SCANCODE_* / SDL_BUTTON_*）
 * @explain[zh-cn] 设计目标：上层（WindowEngine/InputEngine 使用者）只需依赖 three，无需 import sdl4cj。
 * 数值与 SDL3 物理键码一一对应（跨平台一致），由 WindowEngine 事件泵内部映射。
 * 用法：
 * if (win.isKeyDown(KeyCode.ESCAPE)) { ... }
 * if (input.isMouseButtonDown(MouseButton.LEFT)) { ... }
 *
 * @file[en] KeyCode  Keyboard/mouse constants (three.window sub-package)
 * @brief[en] Built-in keyboard/mouse constants of three.window (replacing direct use of sdl4cj's SDL_SCANCODE_* / SDL_BUTTON_*)
 * @explain[en] Design goal: upper layers (WindowEngine/InputEngine users) only need to depend on three, without importing sdl4cj.
 * The values correspond one-to-one with SDL3 physical key codes (consistent across platforms),
 * mapped internally by the WindowEngine event pump.
 * Usage:
 * if (win.isKeyDown(KeyCode.ESCAPE)) { ... }
 * if (input.isMouseButtonDown(MouseButton.LEFT)) { ... }
 */
package three.window

/**
 * @brief[zh-cn] 键盘扫描码常量（对应 SDL_SCANCODE_* 数值，UInt32）
 * @explain[zh-cn] 完整覆盖 SDL3 的 SDL_Scancode 枚举（含 UNKNOWN=0 / RESERVED=400 / COUNT=512 保留项）。
 *
 * @brief[en] Keyboard scancode constants (matching SDL_SCANCODE_* values, UInt32)
 * @explain[en] Fully covers the SDL3 SDL_Scancode enum (including the UNKNOWN=0 / RESERVED=400 / COUNT=512 reserved entries).
 */
public class KeyCode {
    /**
     * @brief[zh-cn] 未知/无按键
     *
     * @brief[en] Unknown/no key
     */
    public static let UNKNOWN: UInt32 = 0

    // ===== 字母键 A-Z =====
    /**
     * @brief[zh-cn] A 键
     *
     * @brief[en] The A key
     */
    public static let A: UInt32 = 4
    /**
     * @brief[zh-cn] B 键
     *
     * @brief[en] The B key
     */
    public static let B: UInt32 = 5
    /**
     * @brief[zh-cn] C 键
     *
     * @brief[en] The C key
     */
    public static let C: UInt32 = 6
    /**
     * @brief[zh-cn] D 键
     *
     * @brief[en] The D key
     */
    public static let D: UInt32 = 7
    /**
     * @brief[zh-cn] E 键
     *
     * @brief[en] The E key
     */
    public static let E: UInt32 = 8
    /**
     * @brief[zh-cn] F 键
     *
     * @brief[en] The F key
     */
    public static let F: UInt32 = 9
    /**
     * @brief[zh-cn] G 键
     *
     * @brief[en] The G key
     */
    public static let G: UInt32 = 10
    /**
     * @brief[zh-cn] H 键
     *
     * @brief[en] The H key
     */
    public static let H: UInt32 = 11
    /**
     * @brief[zh-cn] I 键
     *
     * @brief[en] The I key
     */
    public static let I: UInt32 = 12
    /**
     * @brief[zh-cn] J 键
     *
     * @brief[en] The J key
     */
    public static let J: UInt32 = 13
    /**
     * @brief[zh-cn] K 键
     *
     * @brief[en] The K key
     */
    public static let K: UInt32 = 14
    /**
     * @brief[zh-cn] L 键
     *
     * @brief[en] The L key
     */
    public static let L: UInt32 = 15
    /**
     * @brief[zh-cn] M 键
     *
     * @brief[en] The M key
     */
    public static let M: UInt32 = 16
    /**
     * @brief[zh-cn] N 键
     *
     * @brief[en] The N key
     */
    public static let N: UInt32 = 17
    /**
     * @brief[zh-cn] O 键
     *
     * @brief[en] The O key
     */
    public static let O: UInt32 = 18
    /**
     * @brief[zh-cn] P 键
     *
     * @brief[en] The P key
     */
    public static let P: UInt32 = 19
    /**
     * @brief[zh-cn] Q 键
     *
     * @brief[en] The Q key
     */
    public static let Q: UInt32 = 20
    /**
     * @brief[zh-cn] R 键
     *
     * @brief[en] The R key
     */
    public static let R: UInt32 = 21
    /**
     * @brief[zh-cn] S 键
     *
     * @brief[en] The S key
     */
    public static let S: UInt32 = 22
    /**
     * @brief[zh-cn] T 键
     *
     * @brief[en] The T key
     */
    public static let T: UInt32 = 23
    /**
     * @brief[zh-cn] U 键
     *
     * @brief[en] The U key
     */
    public static let U: UInt32 = 24
    /**
     * @brief[zh-cn] V 键
     *
     * @brief[en] The V key
     */
    public static let V: UInt32 = 25
    /**
     * @brief[zh-cn] W 键
     *
     * @brief[en] The W key
     */
    public static let W: UInt32 = 26
    /**
     * @brief[zh-cn] X 键
     *
     * @brief[en] The X key
     */
    public static let X: UInt32 = 27
    /**
     * @brief[zh-cn] Y 键
     *
     * @brief[en] The Y key
     */
    public static let Y: UInt32 = 28
    /**
     * @brief[zh-cn] Z 键
     *
     * @brief[en] The Z key
     */
    public static let Z: UInt32 = 29

    // ===== 数字键 1-0 =====
    /**
     * @brief[zh-cn] 数字键 1
     *
     * @brief[en] The 1 key
     */
    public static let NUM_1: UInt32 = 30
    /**
     * @brief[zh-cn] 数字键 2
     *
     * @brief[en] The 2 key
     */
    public static let NUM_2: UInt32 = 31
    /**
     * @brief[zh-cn] 数字键 3
     *
     * @brief[en] The 3 key
     */
    public static let NUM_3: UInt32 = 32
    /**
     * @brief[zh-cn] 数字键 4
     *
     * @brief[en] The 4 key
     */
    public static let NUM_4: UInt32 = 33
    /**
     * @brief[zh-cn] 数字键 5
     *
     * @brief[en] The 5 key
     */
    public static let NUM_5: UInt32 = 34
    /**
     * @brief[zh-cn] 数字键 6
     *
     * @brief[en] The 6 key
     */
    public static let NUM_6: UInt32 = 35
    /**
     * @brief[zh-cn] 数字键 7
     *
     * @brief[en] The 7 key
     */
    public static let NUM_7: UInt32 = 36
    /**
     * @brief[zh-cn] 数字键 8
     *
     * @brief[en] The 8 key
     */
    public static let NUM_8: UInt32 = 37
    /**
     * @brief[zh-cn] 数字键 9
     *
     * @brief[en] The 9 key
     */
    public static let NUM_9: UInt32 = 38
    /**
     * @brief[zh-cn] 数字键 0
     *
     * @brief[en] The 0 key
     */
    public static let NUM_0: UInt32 = 39

    // ===== 编辑/功能键 =====
    /**
     * @brief[zh-cn] 回车
     *
     * @brief[en] The Return (Enter) key
     */
    public static let RETURN: UInt32 = 40
    /**
     * @brief[zh-cn] ESC 键
     *
     * @brief[en] The Escape key
     */
    public static let ESCAPE: UInt32 = 41
    /**
     * @brief[zh-cn] 退格
     *
     * @brief[en] The Backspace key
     */
    public static let BACKSPACE: UInt32 = 42
    /**
     * @brief[zh-cn] Tab 键
     *
     * @brief[en] The Tab key
     */
    public static let TAB: UInt32 = 43
    /**
     * @brief[zh-cn] 空格键
     *
     * @brief[en] The Space key
     */
    public static let SPACE: UInt32 = 44
    /**
     * @brief[zh-cn] 减号/下划线
     *
     * @brief[en] The Minus/underscore key
     */
    public static let MINUS: UInt32 = 45
    /**
     * @brief[zh-cn] 等号/加号
     *
     * @brief[en] The Equals/plus key
     */
    public static let EQUALS: UInt32 = 46
    /**
     * @brief[zh-cn] 左方括号
     *
     * @brief[en] The Left bracket key
     */
    public static let LEFTBRACKET: UInt32 = 47
    /**
     * @brief[zh-cn] 右方括号
     *
     * @brief[en] The Right bracket key
     */
    public static let RIGHTBRACKET: UInt32 = 48
    /**
     * @brief[zh-cn] 反斜杠
     *
     * @brief[en] The Backslash key
     */
    public static let BACKSLASH: UInt32 = 49
    /**
     * @brief[zh-cn] 非美式键盘 # 键
     *
     * @brief[en] The non-US hash (#) key
     */
    public static let NONUSHASH: UInt32 = 50
    /**
     * @brief[zh-cn] 分号
     *
     * @brief[en] The Semicolon key
     */
    public static let SEMICOLON: UInt32 = 51
    /**
     * @brief[zh-cn] 单引号
     *
     * @brief[en] The Apostrophe key
     */
    public static let APOSTROPHE: UInt32 = 52
    /**
     * @brief[zh-cn] 重音符（`）
     *
     * @brief[en] The Grave accent (`) key
     */
    public static let GRAVE: UInt32 = 53
    /**
     * @brief[zh-cn] 逗号
     *
     * @brief[en] The Comma key
     */
    public static let COMMA: UInt32 = 54
    /**
     * @brief[zh-cn] 句号
     *
     * @brief[en] The Period key
     */
    public static let PERIOD: UInt32 = 55
    /**
     * @brief[zh-cn] 斜杠/问号
     *
     * @brief[en] The Slash/question mark key
     */
    public static let SLASH: UInt32 = 56
    /**
     * @brief[zh-cn] 大写锁定
     *
     * @brief[en] The Caps Lock key
     */
    public static let CAPSLOCK: UInt32 = 57

    // ===== 功能键 F1-F12 =====
    /**
     * @brief[zh-cn] 功能键 F1
     *
     * @brief[en] The F1 function key
     */
    public static let F1: UInt32 = 58
    /**
     * @brief[zh-cn] 功能键 F2
     *
     * @brief[en] The F2 function key
     */
    public static let F2: UInt32 = 59
    /**
     * @brief[zh-cn] 功能键 F3
     *
     * @brief[en] The F3 function key
     */
    public static let F3: UInt32 = 60
    /**
     * @brief[zh-cn] 功能键 F4
     *
     * @brief[en] The F4 function key
     */
    public static let F4: UInt32 = 61
    /**
     * @brief[zh-cn] 功能键 F5
     *
     * @brief[en] The F5 function key
     */
    public static let F5: UInt32 = 62
    /**
     * @brief[zh-cn] 功能键 F6
     *
     * @brief[en] The F6 function key
     */
    public static let F6: UInt32 = 63
    /**
     * @brief[zh-cn] 功能键 F7
     *
     * @brief[en] The F7 function key
     */
    public static let F7: UInt32 = 64
    /**
     * @brief[zh-cn] 功能键 F8
     *
     * @brief[en] The F8 function key
     */
    public static let F8: UInt32 = 65
    /**
     * @brief[zh-cn] 功能键 F9
     *
     * @brief[en] The F9 function key
     */
    public static let F9: UInt32 = 66
    /**
     * @brief[zh-cn] 功能键 F10
     *
     * @brief[en] The F10 function key
     */
    public static let F10: UInt32 = 67
    /**
     * @brief[zh-cn] 功能键 F11
     *
     * @brief[en] The F11 function key
     */
    public static let F11: UInt32 = 68
    /**
     * @brief[zh-cn] 功能键 F12
     *
     * @brief[en] The F12 function key
     */
    public static let F12: UInt32 = 69

    // ===== 导航/编辑键 =====
    /**
     * @brief[zh-cn] 打印屏幕
     *
     * @brief[en] The Print Screen key
     */
    public static let PRINTSCREEN: UInt32 = 70
    /**
     * @brief[zh-cn] 滚动锁定
     *
     * @brief[en] The Scroll Lock key
     */
    public static let SCROLLLOCK: UInt32 = 71
    /**
     * @brief[zh-cn] 暂停
     *
     * @brief[en] The Pause key
     */
    public static let PAUSE: UInt32 = 72
    /**
     * @brief[zh-cn] 插入
     *
     * @brief[en] The Insert key
     */
    public static let INSERT: UInt32 = 73
    /**
     * @brief[zh-cn] Home 键
     *
     * @brief[en] The Home key
     */
    public static let HOME: UInt32 = 74
    /**
     * @brief[zh-cn] 上翻页
     *
     * @brief[en] The Page Up key
     */
    public static let PAGEUP: UInt32 = 75
    /**
     * @brief[zh-cn] 删除
     *
     * @brief[en] The Delete key
     */
    public static let DELETE: UInt32 = 76
    /**
     * @brief[zh-cn] End 键
     *
     * @brief[en] The End key
     */
    public static let END: UInt32 = 77
    /**
     * @brief[zh-cn] 下翻页
     *
     * @brief[en] The Page Down key
     */
    public static let PAGEDOWN: UInt32 = 78
    /**
     * @brief[zh-cn] 右方向键
     *
     * @brief[en] The Right arrow key
     */
    public static let RIGHT: UInt32 = 79
    /**
     * @brief[zh-cn] 左方向键
     *
     * @brief[en] The Left arrow key
     */
    public static let LEFT: UInt32 = 80
    /**
     * @brief[zh-cn] 下方向键
     *
     * @brief[en] The Down arrow key
     */
    public static let DOWN: UInt32 = 81
    /**
     * @brief[zh-cn] 上方向键
     *
     * @brief[en] The Up arrow key
     */
    public static let UP: UInt32 = 82

    // ===== 数字小键盘 =====
    /**
     * @brief[zh-cn] 数字锁定
     *
     * @brief[en] The Num Lock (Clear) key
     */
    public static let NUMLOCKCLEAR: UInt32 = 83
    /**
     * @brief[zh-cn] 小键盘除号
     *
     * @brief[en] Keypad divide (/)
     */
    public static let KP_DIVIDE: UInt32 = 84
    /**
     * @brief[zh-cn] 小键盘乘号
     *
     * @brief[en] Keypad multiply (*)
     */
    public static let KP_MULTIPLY: UInt32 = 85
    /**
     * @brief[zh-cn] 小键盘减号
     *
     * @brief[en] Keypad minus (-)
     */
    public static let KP_MINUS: UInt32 = 86
    /**
     * @brief[zh-cn] 小键盘加号
     *
     * @brief[en] Keypad plus (+)
     */
    public static let KP_PLUS: UInt32 = 87
    /**
     * @brief[zh-cn] 小键盘回车
     *
     * @brief[en] Keypad Enter
     */
    public static let KP_ENTER: UInt32 = 88
    /**
     * @brief[zh-cn] 小键盘 1
     *
     * @brief[en] Keypad 1
     */
    public static let KP_1: UInt32 = 89
    /**
     * @brief[zh-cn] 小键盘 2
     *
     * @brief[en] Keypad 2
     */
    public static let KP_2: UInt32 = 90
    /**
     * @brief[zh-cn] 小键盘 3
     *
     * @brief[en] Keypad 3
     */
    public static let KP_3: UInt32 = 91
    /**
     * @brief[zh-cn] 小键盘 4
     *
     * @brief[en] Keypad 4
     */
    public static let KP_4: UInt32 = 92
    /**
     * @brief[zh-cn] 小键盘 5
     *
     * @brief[en] Keypad 5
     */
    public static let KP_5: UInt32 = 93
    /**
     * @brief[zh-cn] 小键盘 6
     *
     * @brief[en] Keypad 6
     */
    public static let KP_6: UInt32 = 94
    /**
     * @brief[zh-cn] 小键盘 7
     *
     * @brief[en] Keypad 7
     */
    public static let KP_7: UInt32 = 95
    /**
     * @brief[zh-cn] 小键盘 8
     *
     * @brief[en] Keypad 8
     */
    public static let KP_8: UInt32 = 96
    /**
     * @brief[zh-cn] 小键盘 9
     *
     * @brief[en] Keypad 9
     */
    public static let KP_9: UInt32 = 97
    /**
     * @brief[zh-cn] 小键盘 0
     *
     * @brief[en] Keypad 0
     */
    public static let KP_0: UInt32 = 98
    /**
     * @brief[zh-cn] 小键盘句点
     *
     * @brief[en] Keypad period (.)
     */
    public static let KP_PERIOD: UInt32 = 99
    /**
     * @brief[zh-cn] 非美式键盘 \\ 键
     *
     * @brief[en] The non-US backslash (\) key
     */
    public static let NONUSBACKSLASH: UInt32 = 100
    /**
     * @brief[zh-cn] 应用键（菜单键）
     *
     * @brief[en] The Application (menu) key
     */
    public static let APPLICATION: UInt32 = 101
    /**
     * @brief[zh-cn] 电源键
     *
     * @brief[en] The Power key
     */
    public static let POWER: UInt32 = 102
    /**
     * @brief[zh-cn] 小键盘等号
     *
     * @brief[en] Keypad equals (=)
     */
    public static let KP_EQUALS: UInt32 = 103

    // ===== 功能键 F13-F24 =====
    /**
     * @brief[zh-cn] 功能键 F13
     *
     * @brief[en] The F13 function key
     */
    public static let F13: UInt32 = 104
    /**
     * @brief[zh-cn] 功能键 F14
     *
     * @brief[en] The F14 function key
     */
    public static let F14: UInt32 = 105
    /**
     * @brief[zh-cn] 功能键 F15
     *
     * @brief[en] The F15 function key
     */
    public static let F15: UInt32 = 106
    /**
     * @brief[zh-cn] 功能键 F16
     *
     * @brief[en] The F16 function key
     */
    public static let F16: UInt32 = 107
    /**
     * @brief[zh-cn] 功能键 F17
     *
     * @brief[en] The F17 function key
     */
    public static let F17: UInt32 = 108
    /**
     * @brief[zh-cn] 功能键 F18
     *
     * @brief[en] The F18 function key
     */
    public static let F18: UInt32 = 109
    /**
     * @brief[zh-cn] 功能键 F19
     *
     * @brief[en] The F19 function key
     */
    public static let F19: UInt32 = 110
    /**
     * @brief[zh-cn] 功能键 F20
     *
     * @brief[en] The F20 function key
     */
    public static let F20: UInt32 = 111
    /**
     * @brief[zh-cn] 功能键 F21
     *
     * @brief[en] The F21 function key
     */
    public static let F21: UInt32 = 112
    /**
     * @brief[zh-cn] 功能键 F22
     *
     * @brief[en] The F22 function key
     */
    public static let F22: UInt32 = 113
    /**
     * @brief[zh-cn] 功能键 F23
     *
     * @brief[en] The F23 function key
     */
    public static let F23: UInt32 = 114
    /**
     * @brief[zh-cn] 功能键 F24
     *
     * @brief[en] The F24 function key
     */
    public static let F24: UInt32 = 115

    // ===== 通用功能键 =====
    /**
     * @brief[zh-cn] 执行
     *
     * @brief[en] The Execute key
     */
    public static let EXECUTE: UInt32 = 116
    /**
     * @brief[zh-cn] 帮助
     *
     * @brief[en] The Help key
     */
    public static let HELP: UInt32 = 117
    /**
     * @brief[zh-cn] 菜单
     *
     * @brief[en] The Menu key
     */
    public static let MENU: UInt32 = 118
    /**
     * @brief[zh-cn] 选择
     *
     * @brief[en] The Select key
     */
    public static let SELECT: UInt32 = 119
    /**
     * @brief[zh-cn] 停止
     *
     * @brief[en] The Stop key
     */
    public static let STOP: UInt32 = 120
    /**
     * @brief[zh-cn] 重做
     *
     * @brief[en] The Again (redo) key
     */
    public static let AGAIN: UInt32 = 121
    /**
     * @brief[zh-cn] 撤销
     *
     * @brief[en] The Undo key
     */
    public static let UNDO: UInt32 = 122
    /**
     * @brief[zh-cn] 剪切
     *
     * @brief[en] The Cut key
     */
    public static let CUT: UInt32 = 123
    /**
     * @brief[zh-cn] 复制
     *
     * @brief[en] The Copy key
     */
    public static let COPY: UInt32 = 124
    /**
     * @brief[zh-cn] 粘贴
     *
     * @brief[en] The Paste key
     */
    public static let PASTE: UInt32 = 125
    /**
     * @brief[zh-cn] 查找
     *
     * @brief[en] The Find key
     */
    public static let FIND: UInt32 = 126
    /**
     * @brief[zh-cn] 静音
     *
     * @brief[en] The Mute key
     */
    public static let MUTE: UInt32 = 127
    /**
     * @brief[zh-cn] 音量+
     *
     * @brief[en] Volume up
     */
    public static let VOLUMEUP: UInt32 = 128
    /**
     * @brief[zh-cn] 音量-
     *
     * @brief[en] Volume down
     */
    public static let VOLUMEDOWN: UInt32 = 129

    // ===== 锁定键（旧式） =====
    /**
     * @brief[zh-cn] 锁定大写锁定
     *
     * @brief[en] The Locking Caps Lock key
     */
    public static let LOCKINGCAPSLOCK: UInt32 = 130
    /**
     * @brief[zh-cn] 锁定数字锁定
     *
     * @brief[en] The Locking Num Lock key
     */
    public static let LOCKINGNUMLOCK: UInt32 = 131
    /**
     * @brief[zh-cn] 锁定滚动锁定
     *
     * @brief[en] The Locking Scroll Lock key
     */
    public static let LOCKINGSCROLLLOCK: UInt32 = 132
    /**
     * @brief[zh-cn] 小键盘逗号
     *
     * @brief[en] Keypad comma (,)
     */
    public static let KP_COMMA: UInt32 = 133
    /**
     * @brief[zh-cn] 小键盘等号（AS/400）
     *
     * @brief[en] Keypad equals (AS/400)
     */
    public static let KP_EQUALSAS400: UInt32 = 134

    // ===== 国际键 =====
    /**
     * @brief[zh-cn] 国际键 1（罗马字符）
     *
     * @brief[en] International key 1 (Ro)
     */
    public static let INTERNATIONAL1: UInt32 = 135
    /**
     * @brief[zh-cn] 国际键 2（假名）
     *
     * @brief[en] International key 2 (Kana)
     */
    public static let INTERNATIONAL2: UInt32 = 136
    /**
     * @brief[zh-cn] 国际键 3（日元）
     *
     * @brief[en] International key 3 (Yen)
     */
    public static let INTERNATIONAL3: UInt32 = 137
    /**
     * @brief[zh-cn] 国际键 4
     *
     * @brief[en] International key 4
     */
    public static let INTERNATIONAL4: UInt32 = 138
    /**
     * @brief[zh-cn] 国际键 5
     *
     * @brief[en] International key 5
     */
    public static let INTERNATIONAL5: UInt32 = 139
    /**
     * @brief[zh-cn] 国际键 6
     *
     * @brief[en] International key 6
     */
    public static let INTERNATIONAL6: UInt32 = 140
    /**
     * @brief[zh-cn] 国际键 7
     *
     * @brief[en] International key 7
     */
    public static let INTERNATIONAL7: UInt32 = 141
    /**
     * @brief[zh-cn] 国际键 8
     *
     * @brief[en] International key 8
     */
    public static let INTERNATIONAL8: UInt32 = 142
    /**
     * @brief[zh-cn] 国际键 9
     *
     * @brief[en] International key 9
     */
    public static let INTERNATIONAL9: UInt32 = 143
    /**
     * @brief[zh-cn] 语言切换键 1（日文/韩文等键盘）
     *
     * @brief[en] Language switch key 1 (Japanese/Korean, etc. keyboards)
     */
    public static let LANG1: UInt32 = 144
    /**
     * @brief[zh-cn] 语言切换键 2
     *
     * @brief[en] Language switch key 2
     */
    public static let LANG2: UInt32 = 145
    /**
     * @brief[zh-cn] 语言切换键 3
     *
     * @brief[en] Language switch key 3
     */
    public static let LANG3: UInt32 = 146
    /**
     * @brief[zh-cn] 语言切换键 4
     *
     * @brief[en] Language switch key 4
     */
    public static let LANG4: UInt32 = 147
    /**
     * @brief[zh-cn] 语言切换键 5
     *
     * @brief[en] Language switch key 5
     */
    public static let LANG5: UInt32 = 148
    /**
     * @brief[zh-cn] 语言切换键 6
     *
     * @brief[en] Language switch key 6
     */
    public static let LANG6: UInt32 = 149
    /**
     * @brief[zh-cn] 语言切换键 7
     *
     * @brief[en] Language switch key 7
     */
    public static let LANG7: UInt32 = 150
    /**
     * @brief[zh-cn] 语言切换键 8
     *
     * @brief[en] Language switch key 8
     */
    public static let LANG8: UInt32 = 151
    /**
     * @brief[zh-cn] 语言切换键 9
     *
     * @brief[en] Language switch key 9
     */
    public static let LANG9: UInt32 = 152

    // ===== 遗留/扩展键 =====
    /**
     * @brief[zh-cn] 清除/替换（日文键盘）
     *
     * @brief[en] Alt-Erase (Japanese keyboard)
     */
    public static let ALTERASE: UInt32 = 153
    /**
     * @brief[zh-cn] 系统请求
     *
     * @brief[en] The SysRq (system request) key
     */
    public static let SYSREQ: UInt32 = 154
    /**
     * @brief[zh-cn] 取消
     *
     * @brief[en] The Cancel key
     */
    public static let CANCEL: UInt32 = 155
    /**
     * @brief[zh-cn] 清除
     *
     * @brief[en] The Clear key
     */
    public static let CLEAR: UInt32 = 156
    /**
     * @brief[zh-cn] 前页（旧式）
     *
     * @brief[en] The Prior key (legacy)
     */
    public static let PRIOR: UInt32 = 157
    /**
     * @brief[zh-cn] 回车（旧式）
     *
     * @brief[en] The Return key (legacy)
     */
    public static let RETURN2: UInt32 = 158
    /**
     * @brief[zh-cn] 分隔符
     *
     * @brief[en] The Separator key
     */
    public static let SEPARATOR: UInt32 = 159
    /**
     * @brief[zh-cn] 输出（旧式）
     *
     * @brief[en] The Out key (legacy)
     */
    public static let OUT: UInt32 = 160
    /**
     * @brief[zh-cn] 运算（旧式）
     *
     * @brief[en] The Oper key (legacy)
     */
    public static let OPER: UInt32 = 161
    /**
     * @brief[zh-cn] 再次清除
     *
     * @brief[en] The Clear Again key
     */
    public static let CLEARAGAIN: UInt32 = 162
    /**
     * @brief[zh-cn] 光标选择（旧式）
     *
     * @brief[en] The CrSel key (legacy)
     */
    public static let CRSEL: UInt32 = 163
    /**
     * @brief[zh-cn] 扩展选择（旧式）
     *
     * @brief[en] The ExSel key (legacy)
     */
    public static let EXSEL: UInt32 = 164

    // ===== 扩展小键盘（金融/计算器键盘） =====
    /**
     * @brief[zh-cn] 小键盘 00
     *
     * @brief[en] Keypad 00
     */
    public static let KP_00: UInt32 = 176
    /**
     * @brief[zh-cn] 小键盘 000
     *
     * @brief[en] Keypad 000
     */
    public static let KP_000: UInt32 = 177
    /**
     * @brief[zh-cn] 千位分隔符
     *
     * @brief[en] The Thousands Separator key
     */
    public static let THOUSANDSSEPARATOR: UInt32 = 178
    /**
     * @brief[zh-cn] 十进制分隔符
     *
     * @brief[en] The Decimal Separator key
     */
    public static let DECIMALSEPARATOR: UInt32 = 179
    /**
     * @brief[zh-cn] 货币单位
     *
     * @brief[en] The Currency Unit key
     */
    public static let CURRENCYUNIT: UInt32 = 180
    /**
     * @brief[zh-cn] 货币辅单位
     *
     * @brief[en] The Currency Sub-Unit key
     */
    public static let CURRENCYSUBUNIT: UInt32 = 181
    /**
     * @brief[zh-cn] 小键盘左括号
     *
     * @brief[en] Keypad left parenthesis (()
     */
    public static let KP_LEFTPAREN: UInt32 = 182
    /**
     * @brief[zh-cn] 小键盘右括号
     *
     * @brief[en] Keypad right parenthesis ())
     */
    public static let KP_RIGHTPAREN: UInt32 = 183
    /**
     * @brief[zh-cn] 小键盘左花括号
     *
     * @brief[en] Keypad left brace ({)
     */
    public static let KP_LEFTBRACE: UInt32 = 184
    /**
     * @brief[zh-cn] 小键盘右花括号
     *
     * @brief[en] Keypad right brace (})
     */
    public static let KP_RIGHTBRACE: UInt32 = 185
    /**
     * @brief[zh-cn] 小键盘 Tab
     *
     * @brief[en] Keypad Tab
     */
    public static let KP_TAB: UInt32 = 186
    /**
     * @brief[zh-cn] 小键盘退格
     *
     * @brief[en] Keypad Backspace
     */
    public static let KP_BACKSPACE: UInt32 = 187
    /**
     * @brief[zh-cn] 小键盘 A
     *
     * @brief[en] Keypad A
     */
    public static let KP_A: UInt32 = 188
    /**
     * @brief[zh-cn] 小键盘 B
     *
     * @brief[en] Keypad B
     */
    public static let KP_B: UInt32 = 189
    /**
     * @brief[zh-cn] 小键盘 C
     *
     * @brief[en] Keypad C
     */
    public static let KP_C: UInt32 = 190
    /**
     * @brief[zh-cn] 小键盘 D
     *
     * @brief[en] Keypad D
     */
    public static let KP_D: UInt32 = 191
    /**
     * @brief[zh-cn] 小键盘 E
     *
     * @brief[en] Keypad E
     */
    public static let KP_E: UInt32 = 192
    /**
     * @brief[zh-cn] 小键盘 F
     *
     * @brief[en] Keypad F
     */
    public static let KP_F: UInt32 = 193
    /**
     * @brief[zh-cn] 小键盘异或
     *
     * @brief[en] Keypad XOR (^)
     */
    public static let KP_XOR: UInt32 = 194
    /**
     * @brief[zh-cn] 小键盘幂
     *
     * @brief[en] Keypad power (^)
     */
    public static let KP_POWER: UInt32 = 195
    /**
     * @brief[zh-cn] 小键盘百分号
     *
     * @brief[en] Keypad percent (%)
     */
    public static let KP_PERCENT: UInt32 = 196
    /**
     * @brief[zh-cn] 小键盘小于
     *
     * @brief[en] Keypad less-than (<)
     */
    public static let KP_LESS: UInt32 = 197
    /**
     * @brief[zh-cn] 小键盘大于
     *
     * @brief[en] Keypad greater-than (>)
     */
    public static let KP_GREATER: UInt32 = 198
    /**
     * @brief[zh-cn] 小键盘与
     *
     * @brief[en] Keypad ampersand (&)
     */
    public static let KP_AMPERSAND: UInt32 = 199
    /**
     * @brief[zh-cn] 小键盘双与
     *
     * @brief[en] Keypad double ampersand (&&)
     */
    public static let KP_DBLAMPERSAND: UInt32 = 200
    /**
     * @brief[zh-cn] 小键盘竖线
     *
     * @brief[en] Keypad vertical bar (|)
     */
    public static let KP_VERTICALBAR: UInt32 = 201
    /**
     * @brief[zh-cn] 小键盘双竖线
     *
     * @brief[en] Keypad double vertical bar (||)
     */
    public static let KP_DBLVERTICALBAR: UInt32 = 202
    /**
     * @brief[zh-cn] 小键盘冒号
     *
     * @brief[en] Keypad colon (:)
     */
    public static let KP_COLON: UInt32 = 203
    /**
     * @brief[zh-cn] 小键盘井号
     *
     * @brief[en] Keypad hash (#)
     */
    public static let KP_HASH: UInt32 = 204
    /**
     * @brief[zh-cn] 小键盘空格
     *
     * @brief[en] Keypad space
     */
    public static let KP_SPACE: UInt32 = 205
    /**
     * @brief[zh-cn] 小键盘 @
     *
     * @brief[en] Keypad at sign (@)
     */
    public static let KP_AT: UInt32 = 206
    /**
     * @brief[zh-cn] 小键盘感叹号
     *
     * @brief[en] Keypad exclamation (!)
     */
    public static let KP_EXCLAM: UInt32 = 207
    /**
     * @brief[zh-cn] 小键盘内存存储
     *
     * @brief[en] Keypad memory store
     */
    public static let KP_MEMSTORE: UInt32 = 208
    /**
     * @brief[zh-cn] 小键盘内存读取
     *
     * @brief[en] Keypad memory recall
     */
    public static let KP_MEMRECALL: UInt32 = 209
    /**
     * @brief[zh-cn] 小键盘内存清除
     *
     * @brief[en] Keypad memory clear
     */
    public static let KP_MEMCLEAR: UInt32 = 210
    /**
     * @brief[zh-cn] 小键盘内存加
     *
     * @brief[en] Keypad memory add
     */
    public static let KP_MEMADD: UInt32 = 211
    /**
     * @brief[zh-cn] 小键盘内存减
     *
     * @brief[en] Keypad memory subtract
     */
    public static let KP_MEMSUBTRACT: UInt32 = 212
    /**
     * @brief[zh-cn] 小键盘内存乘
     *
     * @brief[en] Keypad memory multiply
     */
    public static let KP_MEMMULTIPLY: UInt32 = 213
    /**
     * @brief[zh-cn] 小键盘内存除
     *
     * @brief[en] Keypad memory divide
     */
    public static let KP_MEMDIVIDE: UInt32 = 214
    /**
     * @brief[zh-cn] 小键盘正负号
     *
     * @brief[en] Keypad plus/minus (+/-)
     */
    public static let KP_PLUSMINUS: UInt32 = 215
    /**
     * @brief[zh-cn] 小键盘清除
     *
     * @brief[en] Keypad clear
     */
    public static let KP_CLEAR: UInt32 = 216
    /**
     * @brief[zh-cn] 小键盘清除输入
     *
     * @brief[en] Keypad clear entry
     */
    public static let KP_CLEARENTRY: UInt32 = 217
    /**
     * @brief[zh-cn] 小键盘二进制
     *
     * @brief[en] Keypad binary
     */
    public static let KP_BINARY: UInt32 = 218
    /**
     * @brief[zh-cn] 小键盘八进制
     *
     * @brief[en] Keypad octal
     */
    public static let KP_OCTAL: UInt32 = 219
    /**
     * @brief[zh-cn] 小键盘十进制
     *
     * @brief[en] Keypad decimal
     */
    public static let KP_DECIMAL: UInt32 = 220
    /**
     * @brief[zh-cn] 小键盘十六进制
     *
     * @brief[en] Keypad hexadecimal
     */
    public static let KP_HEXADECIMAL: UInt32 = 221

    // ===== 修饰键 =====
    /**
     * @brief[zh-cn] 左 Ctrl
     *
     * @brief[en] Left Ctrl
     */
    public static let LCTRL: UInt32 = 224
    /**
     * @brief[zh-cn] 左 Shift
     *
     * @brief[en] Left Shift
     */
    public static let LSHIFT: UInt32 = 225
    /**
     * @brief[zh-cn] 左 Alt
     *
     * @brief[en] Left Alt
     */
    public static let LALT: UInt32 = 226
    /**
     * @brief[zh-cn] 左 GUI（Win/Command）
     *
     * @brief[en] Left GUI (Windows/Command)
     */
    public static let LGUI: UInt32 = 227
    /**
     * @brief[zh-cn] 右 Ctrl
     *
     * @brief[en] Right Ctrl
     */
    public static let RCTRL: UInt32 = 228
    /**
     * @brief[zh-cn] 右 Shift
     *
     * @brief[en] Right Shift
     */
    public static let RSHIFT: UInt32 = 229
    /**
     * @brief[zh-cn] 右 Alt
     *
     * @brief[en] Right Alt
     */
    public static let RALT: UInt32 = 230
    /**
     * @brief[zh-cn] 右 GUI（Win/Command）
     *
     * @brief[en] Right GUI (Windows/Command)
     */
    public static let RGUI: UInt32 = 231

    // ===== 系统/多媒体键 =====
    /**
     * @brief[zh-cn] 模式切换（日文键盘）
     *
     * @brief[en] The Mode switch key (Japanese keyboard)
     */
    public static let MODE: UInt32 = 257
    /**
     * @brief[zh-cn] 睡眠
     *
     * @brief[en] The Sleep key
     */
    public static let SLEEP: UInt32 = 258
    /**
     * @brief[zh-cn] 唤醒
     *
     * @brief[en] The Wake key
     */
    public static let WAKE: UInt32 = 259
    /**
     * @brief[zh-cn] 频道+
     *
     * @brief[en] Channel increment
     */
    public static let CHANNEL_INCREMENT: UInt32 = 260
    /**
     * @brief[zh-cn] 频道-
     *
     * @brief[en] Channel decrement
     */
    public static let CHANNEL_DECREMENT: UInt32 = 261
    /**
     * @brief[zh-cn] 媒体播放
     *
     * @brief[en] Media play
     */
    public static let MEDIA_PLAY: UInt32 = 262
    /**
     * @brief[zh-cn] 媒体暂停
     *
     * @brief[en] Media pause
     */
    public static let MEDIA_PAUSE: UInt32 = 263
    /**
     * @brief[zh-cn] 媒体录制
     *
     * @brief[en] Media record
     */
    public static let MEDIA_RECORD: UInt32 = 264
    /**
     * @brief[zh-cn] 媒体快进
     *
     * @brief[en] Media fast forward
     */
    public static let MEDIA_FAST_FORWARD: UInt32 = 265
    /**
     * @brief[zh-cn] 媒体快退
     *
     * @brief[en] Media rewind
     */
    public static let MEDIA_REWIND: UInt32 = 266
    /**
     * @brief[zh-cn] 下一曲
     *
     * @brief[en] Media next track
     */
    public static let MEDIA_NEXT_TRACK: UInt32 = 267
    /**
     * @brief[zh-cn] 上一曲
     *
     * @brief[en] Media previous track
     */
    public static let MEDIA_PREVIOUS_TRACK: UInt32 = 268
    /**
     * @brief[zh-cn] 媒体停止
     *
     * @brief[en] Media stop
     */
    public static let MEDIA_STOP: UInt32 = 269
    /**
     * @brief[zh-cn] 弹出光驱
     *
     * @brief[en] Media eject
     */
    public static let MEDIA_EJECT: UInt32 = 270
    /**
     * @brief[zh-cn] 播放/暂停
     *
     * @brief[en] Media play/pause
     */
    public static let MEDIA_PLAY_PAUSE: UInt32 = 271
    /**
     * @brief[zh-cn] 媒体选择
     *
     * @brief[en] Media select
     */
    public static let MEDIA_SELECT: UInt32 = 272

    // ===== 应用控制键（AC_*） =====
    /**
     * @brief[zh-cn] 新建
     *
     * @brief[en] AC New
     */
    public static let AC_NEW: UInt32 = 273
    /**
     * @brief[zh-cn] 打开
     *
     * @brief[en] AC Open
     */
    public static let AC_OPEN: UInt32 = 274
    /**
     * @brief[zh-cn] 关闭
     *
     * @brief[en] AC Close
     */
    public static let AC_CLOSE: UInt32 = 275
    /**
     * @brief[zh-cn] 退出
     *
     * @brief[en] AC Exit
     */
    public static let AC_EXIT: UInt32 = 276
    /**
     * @brief[zh-cn] 保存
     *
     * @brief[en] AC Save
     */
    public static let AC_SAVE: UInt32 = 277
    /**
     * @brief[zh-cn] 打印
     *
     * @brief[en] AC Print
     */
    public static let AC_PRINT: UInt32 = 278
    /**
     * @brief[zh-cn] 属性
     *
     * @brief[en] AC Properties
     */
    public static let AC_PROPERTIES: UInt32 = 279
    /**
     * @brief[zh-cn] 搜索
     *
     * @brief[en] AC Search
     */
    public static let AC_SEARCH: UInt32 = 280
    /**
     * @brief[zh-cn] 主页
     *
     * @brief[en] AC Home
     */
    public static let AC_HOME: UInt32 = 281
    /**
     * @brief[zh-cn] 后退
     *
     * @brief[en] AC Back
     */
    public static let AC_BACK: UInt32 = 282
    /**
     * @brief[zh-cn] 前进
     *
     * @brief[en] AC Forward
     */
    public static let AC_FORWARD: UInt32 = 283
    /**
     * @brief[zh-cn] 停止
     *
     * @brief[en] AC Stop
     */
    public static let AC_STOP: UInt32 = 284
    /**
     * @brief[zh-cn] 刷新
     *
     * @brief[en] AC Refresh
     */
    public static let AC_REFRESH: UInt32 = 285
    /**
     * @brief[zh-cn] 书签
     *
     * @brief[en] AC Bookmarks
     */
    public static let AC_BOOKMARKS: UInt32 = 286

    // ===== 手机/功能机键 =====
    /**
     * @brief[zh-cn] 左软键
     *
     * @brief[en] The Soft Left key
     */
    public static let SOFTLEFT: UInt32 = 287
    /**
     * @brief[zh-cn] 右软键
     *
     * @brief[en] The Soft Right key
     */
    public static let SOFTRIGHT: UInt32 = 288
    /**
     * @brief[zh-cn] 拨号
     *
     * @brief[en] The Call key
     */
    public static let CALL: UInt32 = 289
    /**
     * @brief[zh-cn] 挂断
     *
     * @brief[en] The End Call key
     */
    public static let ENDCALL: UInt32 = 290

    // ===== 保留项 =====
    /**
     * @brief[zh-cn] 保留（不映射到真实键）
     *
     * @brief[en] Reserved (not mapped to a real key)
     */
    public static let RESERVED: UInt32 = 400
    /**
     * @brief[zh-cn] 扫描码总数（非真实按键）
     *
     * @brief[en] Total scancode count (not a real key)
     */
    public static let COUNT: UInt32 = 512
}

/**
 * @brief[zh-cn] 鼠标按键常量（对应 SDL_BUTTON_* 数值，UInt8）
 *
 * @brief[en] Mouse button constants (matching SDL_BUTTON_* values, UInt8)
 */
public class MouseButton {
    /**
     * @brief[zh-cn] 左键
     *
     * @brief[en] Left button
     */
    public static let LEFT: UInt8 = 1
    /**
     * @brief[zh-cn] 中键
     *
     * @brief[en] Middle button
     */
    public static let MIDDLE: UInt8 = 2
    /**
     * @brief[zh-cn] 右键
     *
     * @brief[en] Right button
     */
    public static let RIGHT: UInt8 = 3
    /**
     * @brief[zh-cn] 侧键 1（后退）
     *
     * @brief[en] Side button 1 (back)
     */
    public static let X1: UInt8 = 4
    /**
     * @brief[zh-cn] 侧键 2（前进）
     *
     * @brief[en] Side button 2 (forward)
     */
    public static let X2: UInt8 = 5
}
