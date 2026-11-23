# 类
## class LineBasicMaterial
```cj
public class LineBasicMaterial <: Material
```
线段基础材质，支持线宽、线帽和线连接样式

### func init\(\)
```cj
public init()
```
构造一个新的线段基础材质

### var linecap
```cj
public var linecap: String
```
线帽样式，可选'round'/'butt'/'square'，默认'round'

### var linejoin
```cj
public var linejoin: String
```
线连接样式，可选'round'/'bevel'/'miter'，默认'round'

### var linewidth
```cj
public var linewidth: Float64
```
线宽，默认1

