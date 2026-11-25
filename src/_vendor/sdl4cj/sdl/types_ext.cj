/**
 * @file sdl4cj 扩展类型定义
 * @brief SDL3 输入设备与并发模块的枚举、句柄和结构体类型定义
 *
 * 本文件包含操纵杆、手柄、传感器、力反馈、线程/锁等模块的
 * 枚举、不透明句柄（指针别名）和 C 兼容结构体。
 *
 * @note 仓颉枚举是引用类型，不满足 CType 约束，foreign 函数使用 UInt32
 *       作为底层表示，调用方通过 `value()` / `fromValue()` 转换。
 * @note 值为 -1 的枚举成员（如 SDL_SENSOR_INVALID）以 UInt32 补码 0xFFFFFFFF 表示。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// 类型别名（C typedef）
// =============================================================================

/** @brief 操纵杆实例 ID（Uint32） */
public type SDL_JoystickID = UInt32
/** @brief 传感器实例 ID（Uint32） */
public type SDL_SensorID = UInt32
/** @brief 力反馈设备 ID（Uint32） */
public type SDL_HapticID = UInt32
/** @brief 线程 ID（Uint64） */
public type SDL_ThreadID = UInt64
/** @brief 时间戳（Uint64 纳秒，自 1970-01-01 UTC） */
public type SDL_Time = UInt64

// =============================================================================
// 不透明句柄（C 指针别名）
// =============================================================================

/** @brief 不透明操纵杆对象指针（SDL_Joystick *） */
public type SDL_Joystick = CPointer<Unit>
/** @brief 不透明手柄对象指针（SDL_Gamepad *） */
public type SDL_Gamepad = CPointer<Unit>
/** @brief 不透明传感器对象指针（SDL_Sensor *） */
public type SDL_Sensor = CPointer<Unit>
/** @brief 不透明力反馈设备指针（SDL_Haptic *） */
public type SDL_Haptic = CPointer<Unit>
/** @brief 不透明线程对象指针（SDL_Thread *） */
public type SDL_Thread = CPointer<Unit>
/** @brief 不透明互斥锁指针（SDL_Mutex *） */
public type SDL_Mutex = CPointer<Unit>
/** @brief 不透明信号量指针（SDL_Semaphore *） */
public type SDL_Semaphore = CPointer<Unit>
/** @brief 不透明条件变量指针（SDL_Condition *） */
public type SDL_Condition = CPointer<Unit>
/** @brief 不透明读写锁指针（SDL_RWLock *） */
public type SDL_RWLock = CPointer<Unit>

// =============================================================================
// 结构体
// =============================================================================

/**
 * @brief 全局唯一标识符（16 字节）
 * @explain 对应 C 端 SDL_GUID，用于标识操纵杆/手柄等设备。
 */
@C
public struct SDL_GUID {
    /** @brief 16 字节原始数据 */
    public var data: VArray<UInt8, $16> = VArray<UInt8, $16>(repeat: 0)
}

// =============================================================================
// 枚举
// =============================================================================

/**
 * @brief 操纵杆类型
 * @explain 定义操纵杆的物理类型。
 */
public enum SDL_JoystickType {
    /** @brief 未知类型 */
    | Unknown
    /** @brief 手柄 */
    | Gamepad
    /** @brief 方向盘 */
    | Wheel
    /** @brief 街机摇杆 */
    | ArcadeStick
    /** @brief 飞行摇杆 */
    | FlightStick
    /** @brief 跳舞毯 */
    | DancePad
    /** @brief 吉他 */
    | Guitar
    /** @brief 鼓 */
    | DrumKit
    /** @brief 街机面板 */
    | ArcadePad
    /** @brief 油门杆 */
    | Throttle
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Unknown => 0
            case Gamepad => 1
            case Wheel => 2
            case ArcadeStick => 3
            case FlightStick => 4
            case DancePad => 5
            case Guitar => 6
            case DrumKit => 7
            case ArcadePad => 8
            case Throttle => 9
            case Count => 10
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_JoystickType {
        match (v) {
            case 0 => Unknown
            case 1 => Gamepad
            case 2 => Wheel
            case 3 => ArcadeStick
            case 4 => FlightStick
            case 5 => DancePad
            case 6 => Guitar
            case 7 => DrumKit
            case 8 => ArcadePad
            case 9 => Throttle
            case _ => Count
        }
    }
}

/**
 * @brief 手柄类型
 * @explain 定义手柄的物理类型。
 */
public enum SDL_GamepadType {
    /** @brief 未知类型 */
    | Unknown
    /** @brief 标准手柄 */
    | Standard
    /** @brief Xbox 360 手柄 */
    | Xbox360
    /** @brief Xbox One 手柄 */
    | XboxOne
    /** @brief PS3 手柄 */
    | PS3
    /** @brief PS4 手柄 */
    | PS4
    /** @brief PS5 手柄 */
    | PS5
    /** @brief 任天堂 Switch Pro 手柄 */
    | NintendoSwitchPro
    /** @brief 任天堂 Switch Joy-Con 左 */
    | NintendoSwitchJoyConLeft
    /** @brief 任天堂 Switch Joy-Con 右 */
    | NintendoSwitchJoyConRight
    /** @brief 任天堂 Switch Joy-Con 对 */
    | NintendoSwitchJoyConPair
    /** @brief 任天堂 GameCube 手柄 */
    | GameCube
    /** @brief Steam 手柄 */
    | Steam
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Unknown => 0
            case Standard => 1
            case Xbox360 => 2
            case XboxOne => 3
            case PS3 => 4
            case PS4 => 5
            case PS5 => 6
            case NintendoSwitchPro => 7
            case NintendoSwitchJoyConLeft => 8
            case NintendoSwitchJoyConRight => 9
            case NintendoSwitchJoyConPair => 10
            case GameCube => 11
            case Steam => 12
            case Count => 13
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_GamepadType {
        match (v) {
            case 0 => Unknown
            case 1 => Standard
            case 2 => Xbox360
            case 3 => XboxOne
            case 4 => PS3
            case 5 => PS4
            case 6 => PS5
            case 7 => NintendoSwitchPro
            case 8 => NintendoSwitchJoyConLeft
            case 9 => NintendoSwitchJoyConRight
            case 10 => NintendoSwitchJoyConPair
            case 11 => GameCube
            case 12 => Steam
            case _ => Count
        }
    }
}

/**
 * @brief 传感器类型
 * @explain 定义传感器类型（加速度计、陀螺仪等）。
 */
public enum SDL_SensorType {
    /** @brief 无效传感器（C 端为 -1） */
    | Invalid
    /** @brief 未知类型 */
    | Unknown
    /** @brief 加速度计 */
    | Accel
    /** @brief 陀螺仪 */
    | Gyro
    /** @brief 左手柄加速度计 */
    | AccelL
    /** @brief 左手柄陀螺仪 */
    | GyroL
    /** @brief 右手柄加速度计 */
    | AccelR
    /** @brief 右手柄陀螺仪 */
    | GyroR
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32（Invalid 为 -1 的补码） */
    public func value(): UInt32 {
        match (this) {
            case Invalid => 0xFFFFFFFF
            case Unknown => 0
            case Accel => 1
            case Gyro => 2
            case AccelL => 3
            case GyroL => 4
            case AccelR => 5
            case GyroR => 6
            case Count => 7
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_SensorType {
        match (v) {
            case 0 => Unknown
            case 1 => Accel
            case 2 => Gyro
            case 3 => AccelL
            case 4 => GyroL
            case 5 => AccelR
            case 6 => GyroR
            case _ => Invalid
        }
    }
}

/**
 * @brief 电源状态
 * @explain 定义设备电源状态。
 */
public enum SDL_PowerState {
    /** @brief 无法确定电源状态（C 端为 -1） */
    | Error
    /** @brief 无法确定电源状态 */
    | Unknown
    /** @brief 未插电，使用电池 */
    | OnBattery
    /** @brief 已插电，无电池 */
    | NoBattery
    /** @brief 已插电，充电中 */
    | Charging
    /** @brief 已插电，电池已充满 */
    | Charged

    /** @brief 将枚举值转换为 UInt32（Error 为 -1 的补码） */
    public func value(): UInt32 {
        match (this) {
            case Error => 0xFFFFFFFF
            case Unknown => 0
            case OnBattery => 1
            case NoBattery => 2
            case Charging => 3
            case Charged => 4
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_PowerState {
        match (v) {
            case 0 => Unknown
            case 1 => OnBattery
            case 2 => NoBattery
            case 3 => Charging
            case 4 => Charged
            case _ => Error
        }
    }
}

/**
 * @brief 手柄轴类型
 * @explain 定义手柄摇杆/扳机轴。
 */
public enum SDL_GamepadAxis {
    /** @brief 无效轴（C 端为 -1） */
    | Invalid
    /** @brief 左摇杆 X */
    | LeftX
    /** @brief 左摇杆 Y */
    | LeftY
    /** @brief 右摇杆 X */
    | RightX
    /** @brief 右摇杆 Y */
    | RightY
    /** @brief 左扳机 */
    | LeftTrigger
    /** @brief 右扳机 */
    | RightTrigger
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32（Invalid 为 -1 的补码） */
    public func value(): UInt32 {
        match (this) {
            case Invalid => 0xFFFFFFFF
            case LeftX => 0
            case LeftY => 1
            case RightX => 2
            case RightY => 3
            case LeftTrigger => 4
            case RightTrigger => 5
            case Count => 6
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_GamepadAxis {
        match (v) {
            case 0 => LeftX
            case 1 => LeftY
            case 2 => RightX
            case 3 => RightY
            case 4 => LeftTrigger
            case 5 => RightTrigger
            case _ => Invalid
        }
    }
}

/**
 * @brief 手柄按键类型
 * @explain 定义手柄按键（以 Xbox 布局命名）。
 */
public enum SDL_GamepadButton {
    /** @brief 无效按键（C 端为 -1） */
    | Invalid
    /** @brief 底部按键（如 Xbox A） */
    | South
    /** @brief 右侧按键（如 Xbox B） */
    | East
    /** @brief 左侧按键（如 Xbox X） */
    | West
    /** @brief 顶部按键（如 Xbox Y） */
    | North
    /** @brief 返回键 */
    | Back
    /** @brief 主页键 */
    | Guide
    /** @brief 开始键 */
    | Start
    /** @brief 左摇杆按下 */
    | LeftStick
    /** @brief 右摇杆按下 */
    | RightStick
    /** @brief 左肩键 */
    | LeftShoulder
    /** @brief 右肩键 */
    | RightShoulder
    /** @brief 十字键上 */
    | DPadUp
    /** @brief 十字键下 */
    | DPadDown
    /** @brief 十字键左 */
    | DPadLeft
    /** @brief 十字键右 */
    | DPadRight

    /** @brief 将枚举值转换为 UInt32（Invalid 为 -1 的补码） */
    public func value(): UInt32 {
        match (this) {
            case Invalid => 0xFFFFFFFF
            case South => 0
            case East => 1
            case West => 2
            case North => 3
            case Back => 4
            case Guide => 5
            case Start => 6
            case LeftStick => 7
            case RightStick => 8
            case LeftShoulder => 9
            case RightShoulder => 10
            case DPadUp => 11
            case DPadDown => 12
            case DPadLeft => 13
            case DPadRight => 14
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_GamepadButton {
        match (v) {
            case 0 => South
            case 1 => East
            case 2 => West
            case 3 => North
            case 4 => Back
            case 5 => Guide
            case 6 => Start
            case 7 => LeftStick
            case 8 => RightStick
            case 9 => LeftShoulder
            case 10 => RightShoulder
            case 11 => DPadUp
            case 12 => DPadDown
            case 13 => DPadLeft
            case 14 => DPadRight
            case _ => Invalid
        }
    }
}

/**
 * @brief 操纵杆连接状态
 * @explain 定义操纵杆/手柄的连接状态。
 */
public enum SDL_JoystickConnectionState {
    /** @brief 无效状态 */
    | Invalid
    /** @brief 未知状态 */
    | Unknown
    /** @brief 有线连接 */
    | Wired
    /** @brief 无线连接 */
    | Wireless

    /** @brief 将枚举值转换为 UInt32（Invalid 为 -1 的补码） */
    public func value(): UInt32 {
        match (this) {
            case Invalid => 0xFFFFFFFF
            case Unknown => 0
            case Wired => 1
            case Wireless => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_JoystickConnectionState {
        match (v) {
            case 0 => Unknown
            case 1 => Wired
            case 2 => Wireless
            case _ => Invalid
        }
    }
}

/**
 * @brief 用户文件夹类型
 * @explain 定义 SDL_GetUserFolder 可查询的用户文件夹。
 */
public enum SDL_Folder {
    /** @brief 主目录 */
    | Home
    /** @brief 桌面 */
    | Desktop
    /** @brief 文档 */
    | Documents
    /** @brief 下载 */
    | Downloads
    /** @brief 音乐 */
    | Music
    /** @brief 图片 */
    | Pictures
    /** @brief 公共共享目录 */
    | PublicShare
    /** @brief 保存游戏目录 */
    | SavedGames
    /** @brief 截图目录 */
    | Screenshots
    /** @brief 模板目录 */
    | Templates
    /** @brief 视频目录 */
    | Videos

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Home => 0
            case Desktop => 1
            case Documents => 2
            case Downloads => 3
            case Music => 4
            case Pictures => 5
            case PublicShare => 6
            case SavedGames => 7
            case Screenshots => 8
            case Templates => 9
            case Videos => 10
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SDL_Folder {
        match (v) {
            case 0 => Home
            case 1 => Desktop
            case 2 => Documents
            case 3 => Downloads
            case 4 => Music
            case 5 => Pictures
            case 6 => PublicShare
            case 7 => SavedGames
            case 8 => Screenshots
            case 9 => Templates
            case 10 => Videos
            case _ => Home
        }
    }
}
