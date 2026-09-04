# 类
## class AxesHelper
```cj
public class AxesHelper <: LineSegments
```
坐标轴辅助对象，用于可视化 X/Y/Z 坐标轴

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Float64\)
```cj
public init(size!: Float64 = 1.0)
```
构造坐标轴辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|size|Float64|轴线长度，默认 1|

### func setColors\(Color,Color,Color\)
```cj
public func setColors(xAxisColor: Color, yAxisColor: Color, zAxisColor: Color): AxesHelper
```
设置各轴颜色

参数: 

|名称|类型|描述|
|---|---|---|
|xAxisColor|Color|X 轴颜色yAxisColor Y 轴颜色zAxisColor Z 轴颜色|
|yAxisColor|Color||
|zAxisColor|Color||

返回: 

- 自身引用

