# 类
## class UiButton
```cj
public class UiButton <: UiWidget
```
按钮控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染按钮，点击时触发回调

返回: 

- 本次点击是否发生

### func init\(String,Vector2\)
```cj
public init(label!: String, size!: Vector2 = Vector2(0.0, 0.0))
```
构造按钮控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|按钮标签文本|
|size|Vector2|按钮尺寸（默认 (0,0) 表示自动计算）|

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiButton
```
设置点击回调

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit|点击时执行的闭包|

返回: 

- this（链式调用）

