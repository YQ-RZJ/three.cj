# 类
## class AmbientLight
```cj
public class AmbientLight <: Light
```
环境光，从各方向均匀照射场景的光源

### func init\(Color,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0)
```
构造一个新的环境光

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|光源颜色，默认 0xffffffintensity 光源强度，默认 1|
|intensity|Float64||

