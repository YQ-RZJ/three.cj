# Class
## class UiSetNextItemWidth
```cj
public class UiSetNextItemWidth <: UiWidget
```
Set next widget width

### func draw\(\)
```cj
public override func draw(): Bool
```
Sets the width of the next widget

Return: 

- Always false (no interaction)

### func init\(Float32\)
```cj
public init(width!: Float32)
```
Constructs a next-item-width widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Float32|Width of the next widget (negative values such as -1 mean auto width)|

