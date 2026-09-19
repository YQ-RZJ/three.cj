# 类
## class UiDummy
```cj
public class UiDummy <: UiWidget
```
占位符控件（指定大小的空白）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染指定尺寸的空白占位

返回: 

- 控件交互结果，本控件恒为 false

### func init\(Vector2\)
```cj
public init(size!: Vector2 = Vector2(0.0, 0.0))
```
构造占位符控件

参数: 

|名称|类型|描述|
|---|---|---|
|size|Vector2|占位尺寸，默认 (0, 0)|

