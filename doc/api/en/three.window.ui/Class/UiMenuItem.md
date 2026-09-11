# Class
## class UiMenuItem
```cj
public class UiMenuItem <: UiWidget
```
Menu item widget

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,String,Bool,Bool\)
```cj
public init(label!: String, shortcut!: String = "", selected!: Bool = false, enabled!: Bool = true)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|shortcut|String||
|selected|Bool||
|enabled|Bool||

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiMenuItem
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit||

