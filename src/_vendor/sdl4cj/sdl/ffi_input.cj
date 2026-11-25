/**
 * @file sdl4cj 输入设备 CFFI 函数声明
 * @brief SDL3 操纵杆 / 手柄 / 传感器 / 力反馈模块的 foreign 函数声明
 * @explain 本文件包含 SDL3 输入设备模块的 foreign 函数声明（包级私有）。
 *         外部调用请使用 `ffi_input_exports.cj` 中的 `_cj` 包装。
 * @note 枚举参数/返回值使用 UInt32 底层表示，位掩码使用 UInt32/UInt16。
 * @note SDL_GUID 结构体以 `@C` 结构体传递（16 字节）。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// 操纵杆（SDL_joystick.h）
// =============================================================================

@FastNative
foreign func SDL_LockJoysticks(): Unit
@FastNative
foreign func SDL_TryLockJoysticks(): Bool
@FastNative
foreign func SDL_UnlockJoysticks(): Unit
@FastNative
foreign func SDL_HasJoystick(): Bool
@FastNative
foreign func SDL_GetJoysticks(count: CPointer<Int32>): CPointer<UInt32>
@FastNative
foreign func SDL_GetJoystickNameForID(instance_id: UInt32): CString
@FastNative
foreign func SDL_GetJoystickPathForID(instance_id: UInt32): CString
@FastNative
foreign func SDL_GetJoystickPlayerIndexForID(instance_id: UInt32): Int32
@FastNative
foreign func SDL_GetJoystickGUIDForID(instance_id: UInt32): SDL_GUID
@FastNative
foreign func SDL_GetJoystickVendorForID(instance_id: UInt32): UInt16
@FastNative
foreign func SDL_GetJoystickProductForID(instance_id: UInt32): UInt16
@FastNative
foreign func SDL_GetJoystickProductVersionForID(instance_id: UInt32): UInt16
@FastNative
foreign func SDL_GetJoystickTypeForID(instance_id: UInt32): UInt32
foreign func SDL_OpenJoystick(instance_id: UInt32): SDL_Joystick
@FastNative
foreign func SDL_GetJoystickFromID(instance_id: UInt32): SDL_Joystick
@FastNative
foreign func SDL_GetJoystickFromPlayerIndex(player_index: Int32): SDL_Joystick
@FastNative
foreign func SDL_IsJoystickVirtual(instance_id: UInt32): Bool
@FastNative
foreign func SDL_GetJoystickProperties(joystick: SDL_Joystick): UInt32
@FastNative
foreign func SDL_GetJoystickName(joystick: SDL_Joystick): CString
@FastNative
foreign func SDL_GetJoystickPath(joystick: SDL_Joystick): CString
@FastNative
foreign func SDL_GetJoystickPlayerIndex(joystick: SDL_Joystick): Int32
@FastNative
foreign func SDL_SetJoystickPlayerIndex(joystick: SDL_Joystick, player_index: Int32): Bool
@FastNative
foreign func SDL_GetJoystickGUID(joystick: SDL_Joystick): SDL_GUID
@FastNative
foreign func SDL_GetJoystickVendor(joystick: SDL_Joystick): UInt16
@FastNative
foreign func SDL_GetJoystickProduct(joystick: SDL_Joystick): UInt16
@FastNative
foreign func SDL_GetJoystickProductVersion(joystick: SDL_Joystick): UInt16
@FastNative
foreign func SDL_GetJoystickFirmwareVersion(joystick: SDL_Joystick): UInt16
@FastNative
foreign func SDL_GetJoystickSerial(joystick: SDL_Joystick): CString
@FastNative
foreign func SDL_GetJoystickType(joystick: SDL_Joystick): UInt32
@FastNative
foreign func SDL_GetJoystickGUIDInfo(guid: SDL_GUID, vendor: CPointer<UInt16>, product: CPointer<UInt16>, version: CPointer<UInt16>, crc16: CPointer<UInt16>): Unit
@FastNative
foreign func SDL_JoystickConnected(joystick: SDL_Joystick): Bool
@FastNative
foreign func SDL_GetJoystickID(joystick: SDL_Joystick): UInt32
@FastNative
foreign func SDL_GetNumJoystickAxes(joystick: SDL_Joystick): Int32
@FastNative
foreign func SDL_GetNumJoystickBalls(joystick: SDL_Joystick): Int32
@FastNative
foreign func SDL_GetNumJoystickHats(joystick: SDL_Joystick): Int32
@FastNative
foreign func SDL_GetNumJoystickButtons(joystick: SDL_Joystick): Int32
@FastNative
foreign func SDL_GetJoystickAxis(joystick: SDL_Joystick, axis: Int32): Int16
@FastNative
foreign func SDL_GetJoystickBall(joystick: SDL_Joystick, ball: Int32, dx: CPointer<Int16>, dy: CPointer<Int16>): Bool
@FastNative
foreign func SDL_GetJoystickHat(joystick: SDL_Joystick, hat: Int32): UInt8
@FastNative
foreign func SDL_GetJoystickButton(joystick: SDL_Joystick, button: Int32): Bool
@FastNative
foreign func SDL_SetJoystickEventsEnabled(enabled: Bool): Unit
@FastNative
foreign func SDL_JoystickEventsEnabled(): Bool
foreign func SDL_CloseJoystick(joystick: SDL_Joystick): Unit

// =============================================================================
// 手柄（SDL_gamepad.h）
// =============================================================================

@FastNative
foreign func SDL_HasGamepad(): Bool
@FastNative
foreign func SDL_GetGamepads(count: CPointer<Int32>): CPointer<UInt32>
@FastNative
foreign func SDL_IsGamepad(instance_id: UInt32): Bool
@FastNative
foreign func SDL_GetGamepadNameForID(instance_id: UInt32): CString
@FastNative
foreign func SDL_GetGamepadPathForID(instance_id: UInt32): CString
@FastNative
foreign func SDL_GetGamepadPlayerIndexForID(instance_id: UInt32): Int32
@FastNative
foreign func SDL_GetGamepadGUIDForID(instance_id: UInt32): SDL_GUID
@FastNative
foreign func SDL_GetGamepadVendorForID(instance_id: UInt32): UInt16
@FastNative
foreign func SDL_GetGamepadProductForID(instance_id: UInt32): UInt16
@FastNative
foreign func SDL_GetGamepadProductVersionForID(instance_id: UInt32): UInt16
@FastNative
foreign func SDL_GetGamepadTypeForID(instance_id: UInt32): UInt32
@FastNative
foreign func SDL_GetRealGamepadTypeForID(instance_id: UInt32): UInt32
foreign func SDL_OpenGamepad(instance_id: UInt32): SDL_Gamepad
@FastNative
foreign func SDL_GetGamepadFromID(instance_id: UInt32): SDL_Gamepad
@FastNative
foreign func SDL_GetGamepadFromPlayerIndex(player_index: Int32): SDL_Gamepad
@FastNative
foreign func SDL_GetGamepadProperties(gamepad: SDL_Gamepad): UInt32
@FastNative
foreign func SDL_GetGamepadID(gamepad: SDL_Gamepad): UInt32
@FastNative
foreign func SDL_GetGamepadName(gamepad: SDL_Gamepad): CString
@FastNative
foreign func SDL_GetGamepadPath(gamepad: SDL_Gamepad): CString
@FastNative
foreign func SDL_GetGamepadType(gamepad: SDL_Gamepad): UInt32
@FastNative
foreign func SDL_GetRealGamepadType(gamepad: SDL_Gamepad): UInt32
@FastNative
foreign func SDL_GetGamepadPlayerIndex(gamepad: SDL_Gamepad): Int32
@FastNative
foreign func SDL_SetGamepadPlayerIndex(gamepad: SDL_Gamepad, player_index: Int32): Bool
@FastNative
foreign func SDL_GetGamepadVendor(gamepad: SDL_Gamepad): UInt16
@FastNative
foreign func SDL_GetGamepadProduct(gamepad: SDL_Gamepad): UInt16
@FastNative
foreign func SDL_GetGamepadProductVersion(gamepad: SDL_Gamepad): UInt16
@FastNative
foreign func SDL_GetGamepadFirmwareVersion(gamepad: SDL_Gamepad): UInt16
@FastNative
foreign func SDL_GetGamepadSerial(gamepad: SDL_Gamepad): CString
@FastNative
foreign func SDL_GetGamepadConnectionState(gamepad: SDL_Gamepad): UInt32
@FastNative
foreign func SDL_GetGamepadPowerInfo(gamepad: SDL_Gamepad, percent: CPointer<Int32>): UInt32
@FastNative
foreign func SDL_GamepadConnected(gamepad: SDL_Gamepad): Bool
@FastNative
foreign func SDL_GetGamepadJoystick(gamepad: SDL_Gamepad): SDL_Joystick
@FastNative
foreign func SDL_SetGamepadEventsEnabled(enabled: Bool): Unit
@FastNative
foreign func SDL_GamepadEventsEnabled(): Bool
@FastNative
foreign func SDL_UpdateGamepads(): Unit
@FastNative
foreign func SDL_GetGamepadAxis(gamepad: SDL_Gamepad, axis: UInt32): Int16
@FastNative
foreign func SDL_GetGamepadButton(gamepad: SDL_Gamepad, button: UInt32): Bool
@FastNative
foreign func SDL_GetGamepadAxisFromString(str: CString): UInt32
@FastNative
foreign func SDL_GetGamepadStringForAxis(axis: UInt32): CString
@FastNative
foreign func SDL_GetGamepadButtonFromString(str: CString): UInt32
@FastNative
foreign func SDL_GetGamepadStringForButton(button: UInt32): CString
foreign func SDL_CloseGamepad(gamepad: SDL_Gamepad): Unit

// =============================================================================
// 传感器（SDL_sensor.h）
// =============================================================================

@FastNative
foreign func SDL_GetSensors(count: CPointer<Int32>): CPointer<UInt32>
@FastNative
foreign func SDL_GetSensorNameForID(instance_id: UInt32): CString
@FastNative
foreign func SDL_GetSensorTypeForID(instance_id: UInt32): UInt32
@FastNative
foreign func SDL_GetSensorNonPortableTypeForID(instance_id: UInt32): Int32
foreign func SDL_OpenSensor(instance_id: UInt32): SDL_Sensor
@FastNative
foreign func SDL_GetSensorFromID(instance_id: UInt32): SDL_Sensor
@FastNative
foreign func SDL_GetSensorProperties(sensor: SDL_Sensor): UInt32
@FastNative
foreign func SDL_GetSensorName(sensor: SDL_Sensor): CString
@FastNative
foreign func SDL_GetSensorType(sensor: SDL_Sensor): UInt32
@FastNative
foreign func SDL_GetSensorNonPortableType(sensor: SDL_Sensor): Int32
@FastNative
foreign func SDL_GetSensorID(sensor: SDL_Sensor): UInt32
@FastNative
foreign func SDL_GetSensorData(sensor: SDL_Sensor, data: CPointer<Float32>, num_values: Int32): Bool
foreign func SDL_CloseSensor(sensor: SDL_Sensor): Unit
@FastNative
foreign func SDL_UpdateSensors(): Unit

// =============================================================================
// 力反馈（SDL_haptic.h）
// =============================================================================

@FastNative
foreign func SDL_GetHaptics(count: CPointer<Int32>): CPointer<UInt32>
@FastNative
foreign func SDL_GetHapticNameForID(instance_id: UInt32): CString
foreign func SDL_OpenHaptic(instance_id: UInt32): SDL_Haptic
@FastNative
foreign func SDL_GetHapticName(haptic: SDL_Haptic): CString
foreign func SDL_OpenHapticFromMouse(): SDL_Haptic
foreign func SDL_OpenHapticFromJoystick(joystick: SDL_Joystick): SDL_Haptic
foreign func SDL_CloseHaptic(haptic: SDL_Haptic): Unit
@FastNative
foreign func SDL_GetNumHapticAxes(haptic: SDL_Haptic): Int32
@FastNative
foreign func SDL_HapticRumbleSupported(haptic: SDL_Haptic): Bool
@FastNative
foreign func SDL_InitHapticRumble(haptic: SDL_Haptic): Bool
@FastNative
foreign func SDL_PlayHapticRumble(haptic: SDL_Haptic, strength: Float32, length: UInt32): Bool
@FastNative
foreign func SDL_StopHapticRumble(haptic: SDL_Haptic): Bool
