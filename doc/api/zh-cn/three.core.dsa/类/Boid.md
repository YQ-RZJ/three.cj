# 类
## class Boid
```cj
public class Boid
```
单个 Boid（鸟个体）

### func applyForce\(Vector2\)
```cj
public func applyForce(force: Vector2): Unit
```
施加力到加速度

参数: 

|名称|类型|描述|
|---|---|---|
|force|Vector2|力向量|

### func flock\(Array<Boid>,FlockConfig\)
```cj
public func flock(boids: Array < Boid >, cfg: FlockConfig): Unit
```
根据邻居计算三大行为的力

参数: 

|名称|类型|描述|
|---|---|---|
|boids|Array<Boid>|所有鸟群个体cfg 鸟群配置|
|cfg|FlockConfig||

### func init\(Vector2,Vector2,Float64,Float64\)
```cj
public init(pos: Vector2, vel: Vector2, maxSpeed: Float64, maxForce: Float64)
```
构造一个 Boid 个体

参数: 

|名称|类型|描述|
|---|---|---|
|pos|Vector2|初始位置vel 初始速度maxSpeed 最大速度maxForce 最大转向力|
|vel|Vector2||
|maxSpeed|Float64||
|maxForce|Float64||

### func steerTowards\(Vector2\)
```cj
public func steerTowards(targetVel: Vector2): Vector2
```
将引导力转换为转向力并限制

参数: 

|名称|类型|描述|
|---|---|---|
|targetVel|Vector2|目标速度|

返回: 

- 转向力（新向量）

### func update\(Float64,FlockConfig\)
```cj
public func update(dt: Float64, cfg: FlockConfig): Unit
```
更新位置

参数: 

|名称|类型|描述|
|---|---|---|
|dt|Float64|时间步长cfg 鸟群配置|
|cfg|FlockConfig||

### var acc
```cj
public var acc: Vector2
```
加速度

### var maxForce
```cj
public var maxForce: Float64
```
最大转向力

### var maxSpeed
```cj
public var maxSpeed: Float64
```
最大速度

### var pos
```cj
public var pos: Vector2
```
位置

### var vel
```cj
public var vel: Vector2
```
速度

