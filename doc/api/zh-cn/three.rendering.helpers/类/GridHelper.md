# 类
## class GridHelper
```cj
public class GridHelper <: LineSegments
```
网格辅助对象，在场景中显示二维网格线

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Float64,Int64,Color,Color\)
```cj
public init(size!: Float64 = 10.0, divisions!: Int64 = 10, color1!: Color = Color(0x444444), color2!: Color = Color(0x888888))
```
构造网格辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|size|Float64|网格尺寸，默认 10divisions 分割数，默认 10color1 中心线颜色，默认深灰 0x444444color2 网格线颜色，默认浅灰 0x888888|
|divisions|Int64||
|color1|Color||
|color2|Color||

