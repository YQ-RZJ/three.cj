# 类
## class ProfFrame
```cj
public class ProfFrame
```
帧标记 — 主帧/命名帧的 start/finish

### func finish\(String\)
```cj
public static func finish(name: String): Unit
```
结束一个命名帧流

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func image\(CPointer<Unit>,UInt16,UInt16,UInt8,Bool\)
```cj
public static func image(image: CPointer < Unit >, width: UInt16, height: UInt16, offset: UInt8, flip: Bool): Unit
```
发送帧图像预览（Tracy GUI 帧列表缩略图）

参数: 

|名称|类型|描述|
|---|---|---|
|image|CPointer<Unit>||
|width|UInt16||
|height|UInt16||
|offset|UInt8||
|flip|Bool||

### func mark\(\)
```cj
public static func mark(): Unit
```
主帧结束标记（主循环每帧一次）

### func mark\(String\)
```cj
public static func mark(name: String): Unit
```
命名帧结束标记（独立帧流，如 "Render"）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func start\(String\)
```cj
public static func start(name: String): Unit
```
开始一个命名帧流（与 finish 同名配对；可多条流并行）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

