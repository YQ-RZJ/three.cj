# Class
## class UiDragFloat
```cj
public class UiDragFloat <: UiWidget
```
Float drag widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the float drag widget

Return: 

- Whether the value changed this frame

### func getValue\(\)
```cj
public func getValue(): Float32
```
Gets the current value

Return: 

- The current drag value

### func init\(String,PtrArray<Float32>,Float32,Float32,Float32,String\)
```cj
public init(label!: String, value!: PtrArray < Float32 >, speed!: Float32 = 1.0, min!: Float32 = 0.0, max!: Float32 = 0.0, format!: String = "%.3f")
```
Constructs a float drag widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|
|value|PtrArray<Float32>|Value buffer (single-element PtrArray<Float32>, updated on drag)|
|speed|Float32|Drag speed (default 1.0)|
|min|Float32|Minimum value (default 0.0)|
|max|Float32|Maximum value (default 0.0 means unbounded)|
|format|String|Number display format (default "%.3f")|

