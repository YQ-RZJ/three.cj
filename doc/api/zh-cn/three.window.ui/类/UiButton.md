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


### func init\(String,Vector2\)
```cj
public init(label!: String, size!: Vector2 = Vector2(0.0, 0.0))
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|size|Vector2||

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

