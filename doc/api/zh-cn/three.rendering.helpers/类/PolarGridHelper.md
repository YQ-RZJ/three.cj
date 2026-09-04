# 类
## class PolarGridHelper
```cj
public class PolarGridHelper <: LineSegments
```
极坐标网格辅助对象，在 XZ 平面显示极坐标网格

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Float64,Int64,Int64,Int64,Color,Color\)
```cj
public init(radius!: Float64 = 10.0, sectors!: Int64 = 16, rings!: Int64 = 8, divisions!: Int64 = 64, color1!: Color = Color(0x444444), color2!: Color = Color(0x888888))
```
构造极坐标网格辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|半径，默认 10sectors 扇形数，默认 16rings 圆环数，默认 8divisions 圆环分段数，默认 64color1 径向线颜色，默认深灰 0x444444color2 圆环颜色，默认浅灰 0x888888|
|sectors|Int64||
|rings|Int64||
|divisions|Int64||
|color1|Color||
|color2|Color||

