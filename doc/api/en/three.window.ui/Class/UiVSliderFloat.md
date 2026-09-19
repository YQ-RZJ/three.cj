# Class
## class UiVSliderFloat
```cj
public class UiVSliderFloat <: UiWidget
```
Vertical float slider widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the vertical slider and syncs the value

Return: 

- Whether the value changed this frame

### func getValue\(\)
```cj
public func getValue(): Float32
```
Gets the current value

Return: 

- The current slider value

### func init\(String,PtrArray<Float32>,Vector2,Float32,Float32,String\)
```cj
public init(label!: String, value!: PtrArray < Float32 >, size!: Vector2 = Vector2(0.0, 0.0), min!: Float32 = 0.0, max!: Float32 = 1.0, format!: String = "%.3f")
```
Constructs a vertical float slider widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Slider label text|
|value|PtrArray<Float32>|Value buffer (single-element PtrArray<Float32>, updated on drag)|
|size|Vector2|Slider size (default (0,0) means auto-calculated)|
|min|Float32|Minimum value (default 0.0)|
|max|Float32|Maximum value (default 1.0)|
|format|String|Number display format (default "%.3f")|

