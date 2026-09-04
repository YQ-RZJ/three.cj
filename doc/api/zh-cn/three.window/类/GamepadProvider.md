# 类
## class GamepadProvider
```cj
public class GamepadProvider <: InputProvider
```
手柄输入提供者

### func \`init\`\(\)
```cj
public override func `init`(): Unit
```
初始化（窗口绑定后调用）

### func beginFrame\(\)
```cj
public override func beginFrame(): Unit
```
每帧开始：轮询手柄状态

### func closeGamepad\(\)
```cj
public func closeGamepad(): Unit
```
关闭手柄

### func getGamepadAxis\(GamepadAxis\)
```cj
public func getGamepadAxis(axis: GamepadAxis): Int16
```
获取手柄轴值（范围 -32768 ~ 32767）

参数: 

|名称|类型|描述|
|---|---|---|
|axis|GamepadAxis|轴（如 GamepadAxis.LeftX）|

返回: 

- 轴值；未连接返回 0

### func getGamepadButton\(GamepadButton\)
```cj
public func getGamepadButton(button: GamepadButton): Bool
```
获取手柄按键状态

参数: 

|名称|类型|描述|
|---|---|---|
|button|GamepadButton|按键（如 GamepadButton.South）|

返回: 

- 是否按下；未连接返回 false

### func getGamepadInstanceID\(\)
```cj
public func getGamepadInstanceID(): Int64
```
获取手柄实例 ID

返回: 

- 手柄实例 ID；未打开返回 -1

### func getGamepadName\(\)
```cj
public func getGamepadName(): String
```
获取手柄名称

返回: 

- 手柄名称；未连接返回空串

### func init\(\)
```cj
public init()
```
构造手柄提供者

### func isGamepadConnected\(\)
```cj
public func isGamepadConnected(): Bool
```
查询手柄是否已连接

返回: 

- 已连接返回 true；未打开返回 false

### func openGamepadAt\(Int32\)
```cj
public func openGamepadAt(index: Int32): Bool
```
打开指定索引的手柄

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int32|手柄索引（从 0 开始）|

返回: 

- 是否成功

### func openGamepad\(\)
```cj
public func openGamepad(): Bool
```
打开第一个已连接的手柄

返回: 

- 是否成功

### func shutdown\(\)
```cj
public override func shutdown(): Unit
```
清理资源

