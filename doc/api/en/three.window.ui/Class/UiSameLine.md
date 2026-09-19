# Class
## class UiSameLine
```cj
public class UiSameLine <: UiWidget
```
Same-line layout widget (places the next widget on the same line)

### func draw\(\)
```cj
public override func draw(): Bool
```
Places the next widget on the same line

Return: 

- Always false (no interaction)

### func init\(Float32,Float32\)
```cj
public init(offset!: Float32 = 0.0, spacing!: Float32 = - 1.0)
```
Constructs a same-line layout widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|offset|Float32|Horizontal offset from the previous item (default 0.0)|
|spacing|Float32|Spacing from the previous item (default -1.0 means use default spacing)|

