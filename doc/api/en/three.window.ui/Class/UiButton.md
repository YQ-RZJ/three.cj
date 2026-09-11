# Class
## class UiButton
```cj
public class UiButton <: UiWidget
```
Button widget

### func draw\(\)
```cj
public override func draw(): Bool
```


### func init\(String,Vector2\)
```cj
public init(label!: String, size!: Vector2 = Vector2(0.0, 0.0))
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|size|Vector2||

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiButton
```
Sets the click callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|Closure executed on click|

Return: 

- this (for chaining)

