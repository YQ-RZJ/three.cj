# Class
## class UiTextColored
```cj
public class UiTextColored <: UiWidget
```
Colored text widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the colored text

Return: 

- Widget interaction result; always false for this widget

### func init\(String,Color\)
```cj
public init(text!: String, color!: Color = Color(1.0, 1.0, 1.0))
```
Constructs a colored text widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|Text to display|
|color|Color|Text color (RGB components in [0, 1]), defaults to white|

