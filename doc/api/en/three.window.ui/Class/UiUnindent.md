# Class
## class UiUnindent
```cj
public class UiUnindent <: UiWidget
```
Unindent widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the unindent

Return: 

- Widget interaction result; always false for this widget

### func init\(Float32\)
```cj
public init(w!: Float32 = 0.0)
```
Constructs an unindent widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|Float32|Unindent width, defaults to 0.0 (ImGui default indent width)|

