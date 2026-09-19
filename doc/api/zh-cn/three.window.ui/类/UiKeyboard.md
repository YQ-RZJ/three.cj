# 类
## class UiKeyboard
```cj
public class UiKeyboard
```
键盘状态查询工具类（静态方法，封装 ImGui 键盘查询 API）

### func getKeyName\(Int32\)
```cj
public static func getKeyName(key: Int32): String
```
获取键名

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32|键码（ImGuiKey）|

返回: 

- 键对应的名称字符串

### func getKeyPressedAmount\(Int32,Float32,Float32\)
```cj
public static func getKeyPressedAmount(key: Int32, repeatDelay: Float32, rate: Float32): Int32
```
获取指定键的连续按下次数（受按住重复触发影响）

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32|键码（ImGuiKey）|
|repeatDelay|Float32|重复触发前延迟|
|rate|Float32|重复触发速率|

返回: 

- 键的按下次数

### func isKeyDown\(Int32\)
```cj
public static func isKeyDown(key: Int32): Bool
```
指定键是否按下

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32|键码（ImGuiKey）|

返回: 

- 键当前是否处于按下状态

### func isKeyPressed\(Int32,Bool\)
```cj
public static func isKeyPressed(key: Int32, repeat_!: Bool = true): Bool
```
指定键是否刚按下（含重复）

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32|键码（ImGuiKey）|
|repeat_|Bool|是否包含重复触发（默认 true）|

返回: 

- 键本次是否刚按下

### func isKeyReleased\(Int32\)
```cj
public static func isKeyReleased(key: Int32): Bool
```
指定键是否刚释放

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32|键码（ImGuiKey）|

返回: 

- 键本次是否刚释放

