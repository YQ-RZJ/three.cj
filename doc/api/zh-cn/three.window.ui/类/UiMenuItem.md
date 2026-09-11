# 类
## class UiMenuItem
```cj
public class UiMenuItem <: UiWidget
```
菜单项控件

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,String,Bool,Bool\)
```cj
public init(label!: String, shortcut!: String = "", selected!: Bool = false, enabled!: Bool = true)
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||
|shortcut|String||
|selected|Bool||
|enabled|Bool||

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiMenuItem
```


参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit||

