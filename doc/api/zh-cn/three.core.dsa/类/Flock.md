# 类
## class Flock
```cj
public class Flock
```
鸟群（管理所有 Boid）

### func averageNeighborDistance\(\)
```cj
public func averageNeighborDistance(): Float64
```
计算平均最近邻居距离

返回: 

- 平均最近邻居距离

### func averageSpeed\(\)
```cj
public func averageSpeed(): Float64
```
计算平均速度

返回: 

- 平均速度

### func centerOfMass\(\)
```cj
public func centerOfMass(): Vector2
```
计算群体质心

返回: 

- 质心位置

### func init\(Array<Boid>,FlockConfig\)
```cj
public init(boids: Array < Boid >, cfg: FlockConfig)
```
构造鸟群

参数: 

|名称|类型|描述|
|---|---|---|
|boids|Array<Boid>|鸟群个体数组cfg 鸟群配置|
|cfg|FlockConfig||

### func step\(Float64\)
```cj
public func step(dt: Float64): Unit
```
单步推进

参数: 

|名称|类型|描述|
|---|---|---|
|dt|Float64|时间步长|

### var boids
```cj
public var boids: Array < Boid >
```
所有鸟群个体

### var cfg
```cj
public var cfg: FlockConfig
```
鸟群配置

