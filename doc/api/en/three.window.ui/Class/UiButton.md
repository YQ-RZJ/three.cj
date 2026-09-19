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
Renders the button and triggers the callback on click

Return: 

- Whether the button was clicked this frame

### func init\(String,Vector2\)
```cj
public init(label!: String, size!: Vector2 = Vector2(0.0, 0.0))
```
Constructs a button widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Button label text|
|size|Vector2|Button size (default (0,0) means auto-calculated)|

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

