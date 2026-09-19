# 类
## class UiProgressBar
```cj
public class UiProgressBar <: UiWidget
```
进度条控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染进度条

返回: 

- 恒为 false（无交互）

### func getFraction\(\)
```cj
public func getFraction(): Float32
```
获取进度比例

返回: 

- 当前进度比例

### func init\(Float32,Vector2,String\)
```cj
public init(fraction!: Float32 = 0.0, size!: Vector2 = Vector2(- 1.0, 0.0), overlay!: String = "")
```
构造进度条控件

参数: 

|名称|类型|描述|
|---|---|---|
|fraction|Float32|进度比例（0.0~1.0，默认 0.0）|
|size|Vector2|进度条尺寸（默认 (-1.0, 0.0) 表示填充当前行宽）|
|overlay|String|叠加显示的文本（默认空字符串表示不显示）|

### func setFraction\(Float32\)
```cj
public func setFraction(f: Float32): Unit
```
设置进度比例

参数: 

|名称|类型|描述|
|---|---|---|
|f|Float32|进度比例（0.0~1.0）|

