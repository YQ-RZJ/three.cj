# 类
## class UiKeyboard
```cj
public class UiKeyboard
```
=============================================================================

### func getKeyName\(Int32\)
```cj
public static func getKeyName(key: Int32): String
```
获取键名

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32||

### func getKeyPressedAmount\(Int32,Float32,Float32\)
```cj
public static func getKeyPressedAmount(key: Int32, repeatDelay: Float32, rate: Float32): Int32
```
指定键按下次数

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32||
|repeatDelay|Float32||
|rate|Float32||

### func isKeyDown\(Int32\)
```cj
public static func isKeyDown(key: Int32): Bool
```
指定键是否按下

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32||

### func isKeyPressed\(Int32,Bool\)
```cj
public static func isKeyPressed(key: Int32, repeat_!: Bool = true): Bool
```
指定键是否刚按下（含重复）

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32||
|repeat_|Bool||

### func isKeyReleased\(Int32\)
```cj
public static func isKeyReleased(key: Int32): Bool
```
指定键是否刚释放

参数: 

|名称|类型|描述|
|---|---|---|
|key|Int32||

