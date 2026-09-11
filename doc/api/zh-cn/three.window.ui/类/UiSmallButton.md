# 类
## class UiSmallButton
```cj
public class UiSmallButton <: UiWidget
```
小按钮控件（无边框，适合工具栏）

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String\)
```cj
public init(label!: String)
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiSmallButton
```


参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit||

