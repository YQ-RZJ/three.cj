# 类
## class HemisphereLightHelper
```cj
public class HemisphereLightHelper <: Object3D
```
半球光辅助对象，用八面体网格可视化半球光

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Light,Float64,Option<Color>\)
```cj
public init(light: Light, size!: Float64 = 1.0, color!: Option < Color >= None < Color >)
```
构造半球光辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|light|Light|要可视化的半球光size 尺寸，默认 1color 颜色，未设置时使用光源颜色|
|size|Float64||
|color|Option<Color>||

### func update\(\)
```cj
public func update(): Unit
```
更新辅助对象以匹配光源位置和颜色

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

### var material
```cj
public var material: Material
```
材质引用

