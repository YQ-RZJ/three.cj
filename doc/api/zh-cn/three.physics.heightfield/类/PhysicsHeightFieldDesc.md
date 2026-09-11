# 类
## class PhysicsHeightFieldDesc
```cj
public class PhysicsHeightFieldDesc
```
高度场地形描述

### func init\(\)
```cj
public init()
```
构造高度场描述

### var center
```cj
public var center: Vector3 = Vector3(0.0, 0.0, 0.0)
```
地形中心世界坐标（高度场平面中心）

### var friction
```cj
public var friction: Float64 = 0.5
```
摩擦系数

### var restitution
```cj
public var restitution: Float64 = 0.0
```
弹性系数

### var sampleCount
```cj
public var sampleCount: Int64 = 0
```
每边采样数（N，网格为 N×N）

### var samples
```cj
public var samples: ArrayList < Float64 >= ArrayList < Float64 >()
```
高度采样（行主序：index = y * count + x）

### var sizeX
```cj
public var sizeX: Float64 = 100.0
```
世界空间 X 向总尺寸（米）

### var sizeZ
```cj
public var sizeZ: Float64 = 100.0
```
世界空间 Z 向总尺寸（米）

