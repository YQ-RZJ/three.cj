# 类
## class DirectionalLightHelper
```cj
public class DirectionalLightHelper <: Object3D
```
方向光辅助对象，用于可视化方向光的效果

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(\)
```cj
public init()
```
构造方向光辅助对象

### func init\(Light,Float64,Option<Color>\)
```cj
public init(light: Light, size!: Float64 = 1.0, color!: Option < Color >= None < Color >)
```


参数: 

|名称|类型|描述|
|---|---|---|
|light|Light||
|size|Float64||
|color|Option<Color>||

### func update\(\)
```cj
public func update(): Unit
```
更新辅助对象以匹配光源的位置和方向

### var color
```cj
public var color: Option < Color >
```
颜色（可选，未设置时使用光源颜色）

### var lightPlane
```cj
public var lightPlane: Line
```
光源平面线

### var light
```cj
public var light: Light
```
被可视化的光源

### var size
```cj
public var size: Float64
```
平面尺寸

### var targetLine
```cj
public var targetLine: Line
```
目标方向线

