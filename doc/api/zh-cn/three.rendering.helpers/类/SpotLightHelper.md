# 类
## class SpotLightHelper
```cj
public class SpotLightHelper <: Object3D
```
聚光灯辅助对象，用锥体线框可视化聚光灯的照射范围

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Light,Option<Color>\)
```cj
public init(light: Light, color!: Option < Color >= None < Color >)
```


参数: 

|名称|类型|描述|
|---|---|---|
|light|Light||
|color|Option<Color>||

### func init\(\)
```cj
public init()
```
构造聚光灯辅助对象

### func update\(\)
```cj
public func update(): Unit
```
更新辅助对象以匹配光源位置和角度

### var color
```cj
public var color: Option < Color >
```
颜色（可选，未设置时使用光源颜色）

### var cone
```cj
public var cone: LineSegments
```
锥体线框

### var light
```cj
public var light: Light
```
被可视化的光源

