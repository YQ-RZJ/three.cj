# Class
## class UiSmallButton
```cj
public class UiSmallButton <: UiWidget
```
Small button widget (borderless, suitable for toolbars)

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String\)
```cj
public init(label!: String)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiSmallButton
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit||

