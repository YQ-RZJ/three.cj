# Class
## class UiTextDisabled
```cj
public class UiTextDisabled <: UiWidget
```
Disabled style text widget (grayed out)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the grayed-out disabled text

Return: 

- Widget interaction result; always false for this widget

### func init\(String\)
```cj
public init(text!: String)
```
Constructs a disabled-style text widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|Text to display|

