# Class
## class AmbientLight
```cj
public class AmbientLight <: Light
```
Ambient light that illuminates the scene uniformly from all directions

### func init\(Color,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0)
```
Construct a new ambient light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Light color, default 0xffffffintensity Light intensity, default 1|
|intensity|Float64||

