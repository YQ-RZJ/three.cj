# Class
## class UiSliderAngle
```cj
public class UiSliderAngle <: UiWidget
```
Angle slider widget (stores radians, range specified in degrees)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the angle slider

Return: 

- Whether the value changed this frame

### func init\(String,PtrArray<Float32>,Float32,Float32,String,Int32\)
```cj
public init(label: String, vRad: PtrArray < Float32 >, minDeg!: Float32 = - 360.0f32, maxDeg!: Float32 = 360.0f32, format!: String = "%.0f deg", flags!: Int32 = 0)
```
Constructs an angle slider widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Slider label text|
|vRad|PtrArray<Float32>|Angle value buffer in radians (single-element PtrArray<Float32>)|
|minDeg|Float32|Minimum angle in degrees (default -360.0)|
|maxDeg|Float32|Maximum angle in degrees (default 360.0)|
|format|String|Angle display format (default "%.0f deg")|
|flags|Int32|ImGui slider flags (default 0)|

