# Class
## class UiIndent
```cj
public class UiIndent <: UiWidget
```
Indent widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the indent

Return: 

- Widget interaction result; always false for this widget

### func init\(Float32\)
```cj
public init(w!: Float32 = 0.0)
```
Constructs an indent widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|Float32|Indent width, defaults to 0.0 (ImGui default indent width)|

