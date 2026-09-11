# 类
## class PhysicsHeightField
```cj
public class PhysicsHeightField
```
高度场运行时对象

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁高度场地形（从世界移除并释放刚体）

### func projectOntoSurface\(Float64,Float64\)
```cj
public func projectOntoSurface(x: Float64, z: Float64): Vector3
```
把世界坐标点投影到地形表面（取地表高度）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|世界 X 坐标z 世界 Z 坐标|
|z|Float64||

返回: 

- 表面点（three 左手系）；地形外或无效时返回 y = -3.4e38 的点

### prop bodyID: UInt32
```cj
public prop bodyID: UInt32
```
地形刚体 ID（可配合碰撞查询使用）

### prop isValid: Bool
```cj
public prop isValid: Bool
```
高度场是否有效（创建成功且未销毁）

### prop sampleCount: Int64
```cj
public prop sampleCount: Int64
```
每边采样数

