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
Renders the small button and triggers the callback on click

Return: 

- Whether the button was clicked this frame

### func init\(String\)
```cj
public init(label!: String)
```
Constructs a small button widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Button label text|

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiSmallButton
```
Sets the click callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|Closure executed on click|

Return: 

- this (for chaining)

