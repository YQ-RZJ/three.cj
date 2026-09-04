# 类
## class FlockConfig
```cj
public class FlockConfig
```
鸟群配置参数

### func init\(Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(alignRadius!: Float64 = 50.0, cohesionRadius!: Float64 = 50.0, separationRadius!: Float64 = 25.0, alignWeight!: Float64 = 1.0, cohesionWeight!: Float64 = 1.0, separationWeight!: Float64 = 1.5, maxSpeed!: Float64 = 2.0, maxForce!: Float64 = 0.05, worldWidth!: Float64 = 800.0, worldHeight!: Float64 = 600.0)
```
构造鸟群配置参数

参数: 

|名称|类型|描述|
|---|---|---|
|alignRadius|Float64|对齐感知半径，默认 50.0cohesionRadius 聚合感知半径，默认 50.0separationRadius 分离最短距离感知半径，默认 25.0alignWeight 对齐权重，默认 1.0cohesionWeight 聚合权重，默认 1.0separationWeight 分离权重，默认 1.5maxSpeed 最大速度，默认 2.0maxForce 最大转向力，默认 0.05worldWidth 世界宽度，默认 800.0worldHeight 世界高度，默认 600.0|
|cohesionRadius|Float64||
|separationRadius|Float64||
|alignWeight|Float64||
|cohesionWeight|Float64||
|separationWeight|Float64||
|maxSpeed|Float64||
|maxForce|Float64||
|worldWidth|Float64||
|worldHeight|Float64||

### var alignRadius
```cj
public var alignRadius: Float64
```
对齐感知半径

### var alignWeight
```cj
public var alignWeight: Float64
```
对齐权重

### var cohesionRadius
```cj
public var cohesionRadius: Float64
```
聚合感知半径

### var cohesionWeight
```cj
public var cohesionWeight: Float64
```
聚合权重

### var maxForce
```cj
public var maxForce: Float64
```
最大转向力（加速度限制）

### var maxSpeed
```cj
public var maxSpeed: Float64
```
最大速度

### var separationRadius
```cj
public var separationRadius: Float64
```
分离最短距离感知半径

### var separationWeight
```cj
public var separationWeight: Float64
```
分离权重

### var worldHeight
```cj
public var worldHeight: Float64
```
世界高度（用于环绕）

### var worldWidth
```cj
public var worldWidth: Float64
```
世界宽度（用于环绕）

