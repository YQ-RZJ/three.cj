/**
 * @file sdl4cj 输入设备公共函数包装
 * @brief SDL3 操纵杆 / 手柄 / 传感器 / 力反馈模块的仓颉安全包装函数
 * @explain 本文件为输入设备模块的每个 foreign 函数提供 `_cj` 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中。
 * @note 字符串参数使用 CString，返回 CString 的可调用 `.toString()` 转 String。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// 操纵杆（SDL_joystick.h）
// =============================================================================

/**
 * @brief 锁定操纵杆子系统（防止设备列表变化）
 */
public func SDL_LockJoysticks_cj(): Unit {
    unsafe {
        SDL_LockJoysticks()
    }
}

/**
 * @brief 尝试锁定操纵杆子系统（非阻塞）
 * @return Bool 成功返回 true
 */
public func SDL_TryLockJoysticks_cj(): Bool {
    return unsafe {
        SDL_TryLockJoysticks()
    }
}

/**
 * @brief 解锁操纵杆子系统
 */
public func SDL_UnlockJoysticks_cj(): Unit {
    unsafe {
        SDL_UnlockJoysticks()
    }
}

/**
 * @brief 判断系统是否有操纵杆
 * @return Bool 有返回 true
 */
public func SDL_HasJoystick_cj(): Bool {
    return unsafe {
        SDL_HasJoystick()
    }
}

/**
 * @brief 获取所有操纵杆实例 ID 数组
 * @param count 输出数量指针
 * @return CPointer<UInt32> 操纵杆 ID 数组（用完用 LibC.free 释放）
 */
public func SDL_GetJoysticks_cj(count: CPointer<Int32>): CPointer<UInt32> {
    return unsafe {
        SDL_GetJoysticks(count)
    }
}

/**
 * @brief 按 ID 获取操纵杆名称
 * @param instance_id 操纵杆实例 ID
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetJoystickNameForID_cj(instance_id: UInt32): CString {
    return unsafe {
        SDL_GetJoystickNameForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取操纵杆路径
 * @param instance_id 操纵杆实例 ID
 * @return CString 路径（可用 .toString() 转 String）
 */
public func SDL_GetJoystickPathForID_cj(instance_id: UInt32): CString {
    return unsafe {
        SDL_GetJoystickPathForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取操纵杆玩家索引
 * @param instance_id 操纵杆实例 ID
 * @return Int32 玩家索引（-1 表示未分配）
 */
public func SDL_GetJoystickPlayerIndexForID_cj(instance_id: UInt32): Int32 {
    return unsafe {
        SDL_GetJoystickPlayerIndexForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取操纵杆 GUID
 * @param instance_id 操纵杆实例 ID
 * @return SDL_GUID 设备 GUID
 */
public func SDL_GetJoystickGUIDForID_cj(instance_id: UInt32): SDL_GUID {
    return unsafe {
        SDL_GetJoystickGUIDForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取操纵杆厂商 ID
 * @param instance_id 操纵杆实例 ID
 * @return UInt16 厂商 ID
 */
public func SDL_GetJoystickVendorForID_cj(instance_id: UInt32): UInt16 {
    return unsafe {
        SDL_GetJoystickVendorForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取操纵杆产品 ID
 * @param instance_id 操纵杆实例 ID
 * @return UInt16 产品 ID
 */
public func SDL_GetJoystickProductForID_cj(instance_id: UInt32): UInt16 {
    return unsafe {
        SDL_GetJoystickProductForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取操纵杆产品版本
 * @param instance_id 操纵杆实例 ID
 * @return UInt16 产品版本
 */
public func SDL_GetJoystickProductVersionForID_cj(instance_id: UInt32): UInt16 {
    return unsafe {
        SDL_GetJoystickProductVersionForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取操纵杆类型
 * @param instance_id 操纵杆实例 ID
 * @return UInt32 操纵杆类型（SDL_JoystickType）
 */
public func SDL_GetJoystickTypeForID_cj(instance_id: UInt32): UInt32 {
    return unsafe {
        SDL_GetJoystickTypeForID(instance_id)
    }
}

/**
 * @brief 打开操纵杆
 * @param instance_id 操纵杆实例 ID
 * @return SDL_Joystick 操纵杆指针（null 表示失败）
 */
public func SDL_OpenJoystick_cj(instance_id: UInt32): SDL_Joystick {
    return unsafe {
        SDL_OpenJoystick(instance_id)
    }
}

/**
 * @brief 按 ID 获取已打开的操纵杆
 * @param instance_id 操纵杆实例 ID
 * @return SDL_Joystick 操纵杆指针
 */
public func SDL_GetJoystickFromID_cj(instance_id: UInt32): SDL_Joystick {
    return unsafe {
        SDL_GetJoystickFromID(instance_id)
    }
}

/**
 * @brief 按玩家索引获取操纵杆
 * @param player_index 玩家索引
 * @return SDL_Joystick 操纵杆指针
 */
public func SDL_GetJoystickFromPlayerIndex_cj(player_index: Int32): SDL_Joystick {
    return unsafe {
        SDL_GetJoystickFromPlayerIndex(player_index)
    }
}

/**
 * @brief 判断操纵杆是否为虚拟设备
 * @param instance_id 操纵杆实例 ID
 * @return Bool 是虚拟设备返回 true
 */
public func SDL_IsJoystickVirtual_cj(instance_id: UInt32): Bool {
    return unsafe {
        SDL_IsJoystickVirtual(instance_id)
    }
}

/**
 * @brief 获取操纵杆属性集合 ID
 * @param joystick 操纵杆指针
 * @return UInt32 属性集合 ID
 */
public func SDL_GetJoystickProperties_cj(joystick: SDL_Joystick): UInt32 {
    return unsafe {
        SDL_GetJoystickProperties(joystick)
    }
}

/**
 * @brief 获取操纵杆名称
 * @param joystick 操纵杆指针
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetJoystickName_cj(joystick: SDL_Joystick): CString {
    return unsafe {
        SDL_GetJoystickName(joystick)
    }
}

/**
 * @brief 获取操纵杆路径
 * @param joystick 操纵杆指针
 * @return CString 路径（可用 .toString() 转 String）
 */
public func SDL_GetJoystickPath_cj(joystick: SDL_Joystick): CString {
    return unsafe {
        SDL_GetJoystickPath(joystick)
    }
}

/**
 * @brief 获取操纵杆玩家索引
 * @param joystick 操纵杆指针
 * @return Int32 玩家索引（-1 表示未分配）
 */
public func SDL_GetJoystickPlayerIndex_cj(joystick: SDL_Joystick): Int32 {
    return unsafe {
        SDL_GetJoystickPlayerIndex(joystick)
    }
}

/**
 * @brief 设置操纵杆玩家索引
 * @param joystick 操纵杆指针
 * @param player_index 玩家索引
 * @return Bool 成功返回 true
 */
public func SDL_SetJoystickPlayerIndex_cj(joystick: SDL_Joystick, player_index: Int32): Bool {
    return unsafe {
        SDL_SetJoystickPlayerIndex(joystick, player_index)
    }
}

/**
 * @brief 获取操纵杆 GUID
 * @param joystick 操纵杆指针
 * @return SDL_GUID 设备 GUID
 */
public func SDL_GetJoystickGUID_cj(joystick: SDL_Joystick): SDL_GUID {
    return unsafe {
        SDL_GetJoystickGUID(joystick)
    }
}

/**
 * @brief 获取操纵杆厂商 ID
 * @param joystick 操纵杆指针
 * @return UInt16 厂商 ID
 */
public func SDL_GetJoystickVendor_cj(joystick: SDL_Joystick): UInt16 {
    return unsafe {
        SDL_GetJoystickVendor(joystick)
    }
}

/**
 * @brief 获取操纵杆产品 ID
 * @param joystick 操纵杆指针
 * @return UInt16 产品 ID
 */
public func SDL_GetJoystickProduct_cj(joystick: SDL_Joystick): UInt16 {
    return unsafe {
        SDL_GetJoystickProduct(joystick)
    }
}

/**
 * @brief 获取操纵杆产品版本
 * @param joystick 操纵杆指针
 * @return UInt16 产品版本
 */
public func SDL_GetJoystickProductVersion_cj(joystick: SDL_Joystick): UInt16 {
    return unsafe {
        SDL_GetJoystickProductVersion(joystick)
    }
}

/**
 * @brief 获取操纵杆固件版本
 * @param joystick 操纵杆指针
 * @return UInt16 固件版本
 */
public func SDL_GetJoystickFirmwareVersion_cj(joystick: SDL_Joystick): UInt16 {
    return unsafe {
        SDL_GetJoystickFirmwareVersion(joystick)
    }
}

/**
 * @brief 获取操纵杆序列号
 * @param joystick 操纵杆指针
 * @return CString 序列号（可用 .toString() 转 String）
 */
public func SDL_GetJoystickSerial_cj(joystick: SDL_Joystick): CString {
    return unsafe {
        SDL_GetJoystickSerial(joystick)
    }
}

/**
 * @brief 获取操纵杆类型
 * @param joystick 操纵杆指针
 * @return UInt32 操纵杆类型（SDL_JoystickType）
 */
public func SDL_GetJoystickType_cj(joystick: SDL_Joystick): UInt32 {
    return unsafe {
        SDL_GetJoystickType(joystick)
    }
}

/**
 * @brief 解析 GUID 中的厂商/产品/版本信息
 * @param guid 设备 GUID
 * @param vendor 输出厂商 ID 指针
 * @param product 输出产品 ID 指针
 * @param version 输出版本指针
 * @param crc16 输出 CRC 指针
 */
public func SDL_GetJoystickGUIDInfo_cj(guid: SDL_GUID, vendor: CPointer<UInt16>, product: CPointer<UInt16>, version: CPointer<UInt16>, crc16: CPointer<UInt16>): Unit {
    unsafe {
        SDL_GetJoystickGUIDInfo(guid, vendor, product, version, crc16)
    }
}

/**
 * @brief 判断操纵杆是否已连接
 * @param joystick 操纵杆指针
 * @return Bool 已连接返回 true
 */
public func SDL_JoystickConnected_cj(joystick: SDL_Joystick): Bool {
    return unsafe {
        SDL_JoystickConnected(joystick)
    }
}

/**
 * @brief 获取操纵杆实例 ID
 * @param joystick 操纵杆指针
 * @return UInt32 实例 ID
 */
public func SDL_GetJoystickID_cj(joystick: SDL_Joystick): UInt32 {
    return unsafe {
        SDL_GetJoystickID(joystick)
    }
}

/**
 * @brief 获取操纵杆轴数量
 * @param joystick 操纵杆指针
 * @return Int32 轴数量
 */
public func SDL_GetNumJoystickAxes_cj(joystick: SDL_Joystick): Int32 {
    return unsafe {
        SDL_GetNumJoystickAxes(joystick)
    }
}

/**
 * @brief 获取操纵杆轨迹球数量
 * @param joystick 操纵杆指针
 * @return Int32 轨迹球数量
 */
public func SDL_GetNumJoystickBalls_cj(joystick: SDL_Joystick): Int32 {
    return unsafe {
        SDL_GetNumJoystickBalls(joystick)
    }
}

/**
 * @brief 获取操纵杆帽开关数量
 * @param joystick 操纵杆指针
 * @return Int32 帽开关数量
 */
public func SDL_GetNumJoystickHats_cj(joystick: SDL_Joystick): Int32 {
    return unsafe {
        SDL_GetNumJoystickHats(joystick)
    }
}

/**
 * @brief 获取操纵杆按键数量
 * @param joystick 操纵杆指针
 * @return Int32 按键数量
 */
public func SDL_GetNumJoystickButtons_cj(joystick: SDL_Joystick): Int32 {
    return unsafe {
        SDL_GetNumJoystickButtons(joystick)
    }
}

/**
 * @brief 获取操纵杆轴值
 * @param joystick 操纵杆指针
 * @param axis 轴索引
 * @return Int16 轴值（-32768 ~ 32767）
 */
public func SDL_GetJoystickAxis_cj(joystick: SDL_Joystick, axis: Int32): Int16 {
    return unsafe {
        SDL_GetJoystickAxis(joystick, axis)
    }
}

/**
 * @brief 获取操纵杆轨迹球位移
 * @param joystick 操纵杆指针
 * @param ball 轨迹球索引
 * @param dx 输出 X 位移指针
 * @param dy 输出 Y 位移指针
 * @return Bool 成功返回 true
 */
public func SDL_GetJoystickBall_cj(joystick: SDL_Joystick, ball: Int32, dx: CPointer<Int16>, dy: CPointer<Int16>): Bool {
    return unsafe {
        SDL_GetJoystickBall(joystick, ball, dx, dy)
    }
}

/**
 * @brief 获取操纵杆帽开关状态
 * @param joystick 操纵杆指针
 * @param hat 帽开关索引
 * @return UInt8 帽开关状态（SDL_HAT_*）
 */
public func SDL_GetJoystickHat_cj(joystick: SDL_Joystick, hat: Int32): UInt8 {
    return unsafe {
        SDL_GetJoystickHat(joystick, hat)
    }
}

/**
 * @brief 获取操纵杆按键状态
 * @param joystick 操纵杆指针
 * @param button 按键索引
 * @return Bool 按下返回 true
 */
public func SDL_GetJoystickButton_cj(joystick: SDL_Joystick, button: Int32): Bool {
    return unsafe {
        SDL_GetJoystickButton(joystick, button)
    }
}

/**
 * @brief 设置操纵杆事件是否启用
 * @param enabled 是否启用
 */
public func SDL_SetJoystickEventsEnabled_cj(enabled: Bool): Unit {
    unsafe {
        SDL_SetJoystickEventsEnabled(enabled)
    }
}

/**
 * @brief 判断操纵杆事件是否启用
 * @return Bool 启用返回 true
 */
public func SDL_JoystickEventsEnabled_cj(): Bool {
    return unsafe {
        SDL_JoystickEventsEnabled()
    }
}

/**
 * @brief 关闭操纵杆
 * @param joystick 操纵杆指针
 */
public func SDL_CloseJoystick_cj(joystick: SDL_Joystick): Unit {
    unsafe {
        SDL_CloseJoystick(joystick)
    }
}

// =============================================================================
// 手柄（SDL_gamepad.h）
// =============================================================================

/**
 * @brief 判断系统是否有手柄
 * @return Bool 有返回 true
 */
public func SDL_HasGamepad_cj(): Bool {
    return unsafe {
        SDL_HasGamepad()
    }
}

/**
 * @brief 获取所有手柄实例 ID 数组
 * @param count 输出数量指针
 * @return CPointer<UInt32> 手柄 ID 数组（用完用 LibC.free 释放）
 */
public func SDL_GetGamepads_cj(count: CPointer<Int32>): CPointer<UInt32> {
    return unsafe {
        SDL_GetGamepads(count)
    }
}

/**
 * @brief 判断指定操纵杆是否为手柄
 * @param instance_id 操纵杆实例 ID
 * @return Bool 是手柄返回 true
 */
public func SDL_IsGamepad_cj(instance_id: UInt32): Bool {
    return unsafe {
        SDL_IsGamepad(instance_id)
    }
}

/**
 * @brief 按 ID 获取手柄名称
 * @param instance_id 手柄实例 ID
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetGamepadNameForID_cj(instance_id: UInt32): CString {
    return unsafe {
        SDL_GetGamepadNameForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取手柄路径
 * @param instance_id 手柄实例 ID
 * @return CString 路径（可用 .toString() 转 String）
 */
public func SDL_GetGamepadPathForID_cj(instance_id: UInt32): CString {
    return unsafe {
        SDL_GetGamepadPathForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取手柄玩家索引
 * @param instance_id 手柄实例 ID
 * @return Int32 玩家索引（-1 表示未分配）
 */
public func SDL_GetGamepadPlayerIndexForID_cj(instance_id: UInt32): Int32 {
    return unsafe {
        SDL_GetGamepadPlayerIndexForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取手柄 GUID
 * @param instance_id 手柄实例 ID
 * @return SDL_GUID 设备 GUID
 */
public func SDL_GetGamepadGUIDForID_cj(instance_id: UInt32): SDL_GUID {
    return unsafe {
        SDL_GetGamepadGUIDForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取手柄厂商 ID
 * @param instance_id 手柄实例 ID
 * @return UInt16 厂商 ID
 */
public func SDL_GetGamepadVendorForID_cj(instance_id: UInt32): UInt16 {
    return unsafe {
        SDL_GetGamepadVendorForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取手柄产品 ID
 * @param instance_id 手柄实例 ID
 * @return UInt16 产品 ID
 */
public func SDL_GetGamepadProductForID_cj(instance_id: UInt32): UInt16 {
    return unsafe {
        SDL_GetGamepadProductForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取手柄产品版本
 * @param instance_id 手柄实例 ID
 * @return UInt16 产品版本
 */
public func SDL_GetGamepadProductVersionForID_cj(instance_id: UInt32): UInt16 {
    return unsafe {
        SDL_GetGamepadProductVersionForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取手柄类型
 * @param instance_id 手柄实例 ID
 * @return UInt32 手柄类型（SDL_GamepadType）
 */
public func SDL_GetGamepadTypeForID_cj(instance_id: UInt32): UInt32 {
    return unsafe {
        SDL_GetGamepadTypeForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取手柄真实类型
 * @param instance_id 手柄实例 ID
 * @return UInt32 真实手柄类型（SDL_GamepadType）
 */
public func SDL_GetRealGamepadTypeForID_cj(instance_id: UInt32): UInt32 {
    return unsafe {
        SDL_GetRealGamepadTypeForID(instance_id)
    }
}

/**
 * @brief 打开手柄
 * @param instance_id 手柄实例 ID
 * @return SDL_Gamepad 手柄指针（null 表示失败）
 */
public func SDL_OpenGamepad_cj(instance_id: UInt32): SDL_Gamepad {
    return unsafe {
        SDL_OpenGamepad(instance_id)
    }
}

/**
 * @brief 按 ID 获取已打开的手柄
 * @param instance_id 手柄实例 ID
 * @return SDL_Gamepad 手柄指针
 */
public func SDL_GetGamepadFromID_cj(instance_id: UInt32): SDL_Gamepad {
    return unsafe {
        SDL_GetGamepadFromID(instance_id)
    }
}

/**
 * @brief 按玩家索引获取手柄
 * @param player_index 玩家索引
 * @return SDL_Gamepad 手柄指针
 */
public func SDL_GetGamepadFromPlayerIndex_cj(player_index: Int32): SDL_Gamepad {
    return unsafe {
        SDL_GetGamepadFromPlayerIndex(player_index)
    }
}

/**
 * @brief 获取手柄属性集合 ID
 * @param gamepad 手柄指针
 * @return UInt32 属性集合 ID
 */
public func SDL_GetGamepadProperties_cj(gamepad: SDL_Gamepad): UInt32 {
    return unsafe {
        SDL_GetGamepadProperties(gamepad)
    }
}

/**
 * @brief 获取手柄实例 ID
 * @param gamepad 手柄指针
 * @return UInt32 实例 ID
 */
public func SDL_GetGamepadID_cj(gamepad: SDL_Gamepad): UInt32 {
    return unsafe {
        SDL_GetGamepadID(gamepad)
    }
}

/**
 * @brief 获取手柄名称
 * @param gamepad 手柄指针
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetGamepadName_cj(gamepad: SDL_Gamepad): CString {
    return unsafe {
        SDL_GetGamepadName(gamepad)
    }
}

/**
 * @brief 获取手柄路径
 * @param gamepad 手柄指针
 * @return CString 路径（可用 .toString() 转 String）
 */
public func SDL_GetGamepadPath_cj(gamepad: SDL_Gamepad): CString {
    return unsafe {
        SDL_GetGamepadPath(gamepad)
    }
}

/**
 * @brief 获取手柄类型
 * @param gamepad 手柄指针
 * @return UInt32 手柄类型（SDL_GamepadType）
 */
public func SDL_GetGamepadType_cj(gamepad: SDL_Gamepad): UInt32 {
    return unsafe {
        SDL_GetGamepadType(gamepad)
    }
}

/**
 * @brief 获取手柄真实类型
 * @param gamepad 手柄指针
 * @return UInt32 真实手柄类型（SDL_GamepadType）
 */
public func SDL_GetRealGamepadType_cj(gamepad: SDL_Gamepad): UInt32 {
    return unsafe {
        SDL_GetRealGamepadType(gamepad)
    }
}

/**
 * @brief 获取手柄玩家索引
 * @param gamepad 手柄指针
 * @return Int32 玩家索引（-1 表示未分配）
 */
public func SDL_GetGamepadPlayerIndex_cj(gamepad: SDL_Gamepad): Int32 {
    return unsafe {
        SDL_GetGamepadPlayerIndex(gamepad)
    }
}

/**
 * @brief 设置手柄玩家索引
 * @param gamepad 手柄指针
 * @param player_index 玩家索引
 * @return Bool 成功返回 true
 */
public func SDL_SetGamepadPlayerIndex_cj(gamepad: SDL_Gamepad, player_index: Int32): Bool {
    return unsafe {
        SDL_SetGamepadPlayerIndex(gamepad, player_index)
    }
}

/**
 * @brief 获取手柄厂商 ID
 * @param gamepad 手柄指针
 * @return UInt16 厂商 ID
 */
public func SDL_GetGamepadVendor_cj(gamepad: SDL_Gamepad): UInt16 {
    return unsafe {
        SDL_GetGamepadVendor(gamepad)
    }
}

/**
 * @brief 获取手柄产品 ID
 * @param gamepad 手柄指针
 * @return UInt16 产品 ID
 */
public func SDL_GetGamepadProduct_cj(gamepad: SDL_Gamepad): UInt16 {
    return unsafe {
        SDL_GetGamepadProduct(gamepad)
    }
}

/**
 * @brief 获取手柄产品版本
 * @param gamepad 手柄指针
 * @return UInt16 产品版本
 */
public func SDL_GetGamepadProductVersion_cj(gamepad: SDL_Gamepad): UInt16 {
    return unsafe {
        SDL_GetGamepadProductVersion(gamepad)
    }
}

/**
 * @brief 获取手柄固件版本
 * @param gamepad 手柄指针
 * @return UInt16 固件版本
 */
public func SDL_GetGamepadFirmwareVersion_cj(gamepad: SDL_Gamepad): UInt16 {
    return unsafe {
        SDL_GetGamepadFirmwareVersion(gamepad)
    }
}

/**
 * @brief 获取手柄序列号
 * @param gamepad 手柄指针
 * @return CString 序列号（可用 .toString() 转 String）
 */
public func SDL_GetGamepadSerial_cj(gamepad: SDL_Gamepad): CString {
    return unsafe {
        SDL_GetGamepadSerial(gamepad)
    }
}

/**
 * @brief 获取手柄连接状态
 * @param gamepad 手柄指针
 * @return UInt32 连接状态（SDL_JoystickConnectionState）
 */
public func SDL_GetGamepadConnectionState_cj(gamepad: SDL_Gamepad): UInt32 {
    return unsafe {
        SDL_GetGamepadConnectionState(gamepad)
    }
}

/**
 * @brief 获取手柄电源信息
 * @param gamepad 手柄指针
 * @param percent 输出电量百分比指针
 * @return UInt32 电源状态（SDL_PowerState）
 */
public func SDL_GetGamepadPowerInfo_cj(gamepad: SDL_Gamepad, percent: CPointer<Int32>): UInt32 {
    return unsafe {
        SDL_GetGamepadPowerInfo(gamepad, percent)
    }
}

/**
 * @brief 判断手柄是否已连接
 * @param gamepad 手柄指针
 * @return Bool 已连接返回 true
 */
public func SDL_GamepadConnected_cj(gamepad: SDL_Gamepad): Bool {
    return unsafe {
        SDL_GamepadConnected(gamepad)
    }
}

/**
 * @brief 获取手柄对应的操纵杆
 * @param gamepad 手柄指针
 * @return SDL_Joystick 操纵杆指针
 */
public func SDL_GetGamepadJoystick_cj(gamepad: SDL_Gamepad): SDL_Joystick {
    return unsafe {
        SDL_GetGamepadJoystick(gamepad)
    }
}

/**
 * @brief 设置手柄事件是否启用
 * @param enabled 是否启用
 */
public func SDL_SetGamepadEventsEnabled_cj(enabled: Bool): Unit {
    unsafe {
        SDL_SetGamepadEventsEnabled(enabled)
    }
}

/**
 * @brief 判断手柄事件是否启用
 * @return Bool 启用返回 true
 */
public func SDL_GamepadEventsEnabled_cj(): Bool {
    return unsafe {
        SDL_GamepadEventsEnabled()
    }
}

/**
 * @brief 更新手柄状态（手动泵取）
 */
public func SDL_UpdateGamepads_cj(): Unit {
    unsafe {
        SDL_UpdateGamepads()
    }
}

/**
 * @brief 获取手柄轴值
 * @param gamepad 手柄指针
 * @param axis 轴类型（SDL_GamepadAxis）
 * @return Int16 轴值（-32768 ~ 32767）
 */
public func SDL_GetGamepadAxis_cj(gamepad: SDL_Gamepad, axis: UInt32): Int16 {
    return unsafe {
        SDL_GetGamepadAxis(gamepad, axis)
    }
}

/**
 * @brief 获取手柄按键状态
 * @param gamepad 手柄指针
 * @param button 按键类型（SDL_GamepadButton）
 * @return Bool 按下返回 true
 */
public func SDL_GetGamepadButton_cj(gamepad: SDL_Gamepad, button: UInt32): Bool {
    return unsafe {
        SDL_GetGamepadButton(gamepad, button)
    }
}

/**
 * @brief 从字符串解析手柄轴类型
 * @param str 字符串（如 "leftx"）
 * @return UInt32 轴类型（SDL_GamepadAxis）
 */
public func SDL_GetGamepadAxisFromString_cj(str: CString): UInt32 {
    return unsafe {
        SDL_GetGamepadAxisFromString(str)
    }
}

/**
 * @brief 获取手柄轴类型字符串
 * @param axis 轴类型（SDL_GamepadAxis）
 * @return CString 字符串（可用 .toString() 转 String）
 */
public func SDL_GetGamepadStringForAxis_cj(axis: UInt32): CString {
    return unsafe {
        SDL_GetGamepadStringForAxis(axis)
    }
}

/**
 * @brief 从字符串解析手柄按键类型
 * @param str 字符串（如 "a"）
 * @return UInt32 按键类型（SDL_GamepadButton）
 */
public func SDL_GetGamepadButtonFromString_cj(str: CString): UInt32 {
    return unsafe {
        SDL_GetGamepadButtonFromString(str)
    }
}

/**
 * @brief 获取手柄按键类型字符串
 * @param button 按键类型（SDL_GamepadButton）
 * @return CString 字符串（可用 .toString() 转 String）
 */
public func SDL_GetGamepadStringForButton_cj(button: UInt32): CString {
    return unsafe {
        SDL_GetGamepadStringForButton(button)
    }
}

/**
 * @brief 关闭手柄
 * @param gamepad 手柄指针
 */
public func SDL_CloseGamepad_cj(gamepad: SDL_Gamepad): Unit {
    unsafe {
        SDL_CloseGamepad(gamepad)
    }
}

// =============================================================================
// 传感器（SDL_sensor.h）
// =============================================================================

/**
 * @brief 获取所有传感器实例 ID 数组
 * @param count 输出数量指针
 * @return CPointer<UInt32> 传感器 ID 数组（用完用 LibC.free 释放）
 */
public func SDL_GetSensors_cj(count: CPointer<Int32>): CPointer<UInt32> {
    return unsafe {
        SDL_GetSensors(count)
    }
}

/**
 * @brief 按 ID 获取传感器名称
 * @param instance_id 传感器实例 ID
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetSensorNameForID_cj(instance_id: UInt32): CString {
    return unsafe {
        SDL_GetSensorNameForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取传感器类型
 * @param instance_id 传感器实例 ID
 * @return UInt32 传感器类型（SDL_SensorType）
 */
public func SDL_GetSensorTypeForID_cj(instance_id: UInt32): UInt32 {
    return unsafe {
        SDL_GetSensorTypeForID(instance_id)
    }
}

/**
 * @brief 按 ID 获取传感器非便携类型
 * @param instance_id 传感器实例 ID
 * @return Int32 非便携类型
 */
public func SDL_GetSensorNonPortableTypeForID_cj(instance_id: UInt32): Int32 {
    return unsafe {
        SDL_GetSensorNonPortableTypeForID(instance_id)
    }
}

/**
 * @brief 打开传感器
 * @param instance_id 传感器实例 ID
 * @return SDL_Sensor 传感器指针（null 表示失败）
 */
public func SDL_OpenSensor_cj(instance_id: UInt32): SDL_Sensor {
    return unsafe {
        SDL_OpenSensor(instance_id)
    }
}

/**
 * @brief 按 ID 获取已打开的传感器
 * @param instance_id 传感器实例 ID
 * @return SDL_Sensor 传感器指针
 */
public func SDL_GetSensorFromID_cj(instance_id: UInt32): SDL_Sensor {
    return unsafe {
        SDL_GetSensorFromID(instance_id)
    }
}

/**
 * @brief 获取传感器属性集合 ID
 * @param sensor 传感器指针
 * @return UInt32 属性集合 ID
 */
public func SDL_GetSensorProperties_cj(sensor: SDL_Sensor): UInt32 {
    return unsafe {
        SDL_GetSensorProperties(sensor)
    }
}

/**
 * @brief 获取传感器名称
 * @param sensor 传感器指针
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetSensorName_cj(sensor: SDL_Sensor): CString {
    return unsafe {
        SDL_GetSensorName(sensor)
    }
}

/**
 * @brief 获取传感器类型
 * @param sensor 传感器指针
 * @return UInt32 传感器类型（SDL_SensorType）
 */
public func SDL_GetSensorType_cj(sensor: SDL_Sensor): UInt32 {
    return unsafe {
        SDL_GetSensorType(sensor)
    }
}

/**
 * @brief 获取传感器非便携类型
 * @param sensor 传感器指针
 * @return Int32 非便携类型
 */
public func SDL_GetSensorNonPortableType_cj(sensor: SDL_Sensor): Int32 {
    return unsafe {
        SDL_GetSensorNonPortableType(sensor)
    }
}

/**
 * @brief 获取传感器实例 ID
 * @param sensor 传感器指针
 * @return UInt32 实例 ID
 */
public func SDL_GetSensorID_cj(sensor: SDL_Sensor): UInt32 {
    return unsafe {
        SDL_GetSensorID(sensor)
    }
}

/**
 * @brief 获取传感器数据
 * @param sensor 传感器指针
 * @param data 输出数据数组指针
 * @param num_values 数据数量
 * @return Bool 成功返回 true
 */
public func SDL_GetSensorData_cj(sensor: SDL_Sensor, data: CPointer<Float32>, num_values: Int32): Bool {
    return unsafe {
        SDL_GetSensorData(sensor, data, num_values)
    }
}

/**
 * @brief 关闭传感器
 * @param sensor 传感器指针
 */
public func SDL_CloseSensor_cj(sensor: SDL_Sensor): Unit {
    unsafe {
        SDL_CloseSensor(sensor)
    }
}

/**
 * @brief 更新传感器状态（手动泵取）
 */
public func SDL_UpdateSensors_cj(): Unit {
    unsafe {
        SDL_UpdateSensors()
    }
}

// =============================================================================
// 力反馈（SDL_haptic.h）
// =============================================================================

/**
 * @brief 获取所有力反馈设备 ID 数组
 * @param count 输出数量指针
 * @return CPointer<UInt32> 力反馈设备 ID 数组（用完用 LibC.free 释放）
 */
public func SDL_GetHaptics_cj(count: CPointer<Int32>): CPointer<UInt32> {
    return unsafe {
        SDL_GetHaptics(count)
    }
}

/**
 * @brief 按 ID 获取力反馈设备名称
 * @param instance_id 力反馈设备 ID
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetHapticNameForID_cj(instance_id: UInt32): CString {
    return unsafe {
        SDL_GetHapticNameForID(instance_id)
    }
}

/**
 * @brief 打开力反馈设备
 * @param instance_id 力反馈设备 ID
 * @return SDL_Haptic 力反馈设备指针（null 表示失败）
 */
public func SDL_OpenHaptic_cj(instance_id: UInt32): SDL_Haptic {
    return unsafe {
        SDL_OpenHaptic(instance_id)
    }
}

/**
 * @brief 获取力反馈设备名称
 * @param haptic 力反馈设备指针
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetHapticName_cj(haptic: SDL_Haptic): CString {
    return unsafe {
        SDL_GetHapticName(haptic)
    }
}

/**
 * @brief 从鼠标打开力反馈设备
 * @return SDL_Haptic 力反馈设备指针（null 表示失败）
 */
public func SDL_OpenHapticFromMouse_cj(): SDL_Haptic {
    return unsafe {
        SDL_OpenHapticFromMouse()
    }
}

/**
 * @brief 从操纵杆打开力反馈设备
 * @param joystick 操纵杆指针
 * @return SDL_Haptic 力反馈设备指针（null 表示失败）
 */
public func SDL_OpenHapticFromJoystick_cj(joystick: SDL_Joystick): SDL_Haptic {
    return unsafe {
        SDL_OpenHapticFromJoystick(joystick)
    }
}

/**
 * @brief 关闭力反馈设备
 * @param haptic 力反馈设备指针
 */
public func SDL_CloseHaptic_cj(haptic: SDL_Haptic): Unit {
    unsafe {
        SDL_CloseHaptic(haptic)
    }
}

/**
 * @brief 获取力反馈设备轴数量
 * @param haptic 力反馈设备指针
 * @return Int32 轴数量
 */
public func SDL_GetNumHapticAxes_cj(haptic: SDL_Haptic): Int32 {
    return unsafe {
        SDL_GetNumHapticAxes(haptic)
    }
}

/**
 * @brief 判断力反馈设备是否支持简单振动
 * @param haptic 力反馈设备指针
 * @return Bool 支持返回 true
 */
public func SDL_HapticRumbleSupported_cj(haptic: SDL_Haptic): Bool {
    return unsafe {
        SDL_HapticRumbleSupported(haptic)
    }
}

/**
 * @brief 初始化简单振动
 * @param haptic 力反馈设备指针
 * @return Bool 成功返回 true
 */
public func SDL_InitHapticRumble_cj(haptic: SDL_Haptic): Bool {
    return unsafe {
        SDL_InitHapticRumble(haptic)
    }
}

/**
 * @brief 播放简单振动
 * @param haptic 力反馈设备指针
 * @param strength 振动强度（0.0 ~ 1.0）
 * @param length 振动时长（毫秒）
 * @return Bool 成功返回 true
 */
public func SDL_PlayHapticRumble_cj(haptic: SDL_Haptic, strength: Float32, length: UInt32): Bool {
    return unsafe {
        SDL_PlayHapticRumble(haptic, strength, length)
    }
}

/**
 * @brief 停止简单振动
 * @param haptic 力反馈设备指针
 * @return Bool 成功返回 true
 */
public func SDL_StopHapticRumble_cj(haptic: SDL_Haptic): Bool {
    return unsafe {
        SDL_StopHapticRumble(haptic)
    }
}
