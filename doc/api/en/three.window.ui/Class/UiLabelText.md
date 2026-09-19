# Class
## class UiLabelText
```cj
public class UiLabelText <: UiWidget
```
Label plus value text widget (LabelText)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the label and value text

Return: 

- Always false (this widget has no interaction state)

### func init\(String,String\)
```cj
public init(label!: String, text!: String)
```
Constructs a label plus value text widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text on the left|
|text|String|Value text on the right|

