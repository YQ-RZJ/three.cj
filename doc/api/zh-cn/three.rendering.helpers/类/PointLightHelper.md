# 类
## class PointLightHelper
```cj
public class PointLightHelper <: Mesh
```
点光源辅助对象，用球形线框网格可视化点光源的位置

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Light,Float64,Option<Color>\)
```cj
public init(light: Light, sphereSize!: Float64 = 1.0, color!: Option < Color >= None < Color >)
```
构造点光源辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|light|Light|要可视化的点光源sphereSize 球体尺寸，默认 1color 颜色，未设置时使用光源颜色|
|sphereSize|Float64||
|color|Option<Color>||

### func update\(\)
```cj
public func update(): Unit
```
更新辅助对象以匹配光源位置

### var color
```cj
public var color: Option < Color >
```
颜色（可选，未设置时使用光源颜色）

### var light
```cj
public var light: Light
```
被可视化的光源

