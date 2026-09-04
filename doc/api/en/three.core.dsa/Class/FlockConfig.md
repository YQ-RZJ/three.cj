# Class
## class FlockConfig
```cj
public class FlockConfig
```
Flock configuration parameters

### func init\(Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(alignRadius!: Float64 = 50.0, cohesionRadius!: Float64 = 50.0, separationRadius!: Float64 = 25.0, alignWeight!: Float64 = 1.0, cohesionWeight!: Float64 = 1.0, separationWeight!: Float64 = 1.5, maxSpeed!: Float64 = 2.0, maxForce!: Float64 = 0.05, worldWidth!: Float64 = 800.0, worldHeight!: Float64 = 600.0)
```
Construct flock configuration parameters

Parameter: 

|Name|Type|Describe|
|---|---|---|
|alignRadius|Float64|Alignment perception radius, defaults to 50.0cohesionRadius Cohesion perception radius, defaults to 50.0separationRadius Separation minimum distance perception radius, defaults to 25.0alignWeight Alignment weight, defaults to 1.0cohesionWeight Cohesion weight, defaults to 1.0separationWeight Separation weight, defaults to 1.5maxSpeed Maximum speed, defaults to 2.0maxForce Maximum steering force, defaults to 0.05worldWidth World width, defaults to 800.0worldHeight World height, defaults to 600.0|
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
Alignment perception radius

### var alignWeight
```cj
public var alignWeight: Float64
```
Alignment weight

### var cohesionRadius
```cj
public var cohesionRadius: Float64
```
Cohesion perception radius

### var cohesionWeight
```cj
public var cohesionWeight: Float64
```
Cohesion weight

### var maxForce
```cj
public var maxForce: Float64
```
Maximum steering force (acceleration limit)

### var maxSpeed
```cj
public var maxSpeed: Float64
```
Maximum speed

### var separationRadius
```cj
public var separationRadius: Float64
```
Separation minimum distance perception radius

### var separationWeight
```cj
public var separationWeight: Float64
```
Separation weight

### var worldHeight
```cj
public var worldHeight: Float64
```
World height (for wrapping)

### var worldWidth
```cj
public var worldWidth: Float64
```
World width (for wrapping)

