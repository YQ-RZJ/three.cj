# Class
## class Boid
```cj
public class Boid
```
Single Boid (bird individual)

### func applyForce\(Vector2\)
```cj
public func applyForce(force: Vector2): Unit
```
Apply force to acceleration

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Vector2|Force vector|

### func flock\(Array<Boid>,FlockConfig\)
```cj
public func flock(boids: Array < Boid >, cfg: FlockConfig): Unit
```
Compute the three behavioral forces based on neighbors

Parameter: 

|Name|Type|Describe|
|---|---|---|
|boids|Array<Boid>|All boid individualscfg Flock configuration|
|cfg|FlockConfig||

### func init\(Vector2,Vector2,Float64,Float64\)
```cj
public init(pos: Vector2, vel: Vector2, maxSpeed: Float64, maxForce: Float64)
```
Construct a Boid individual

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pos|Vector2|Initial positionvel Initial velocitymaxSpeed Maximum speedmaxForce Maximum steering force|
|vel|Vector2||
|maxSpeed|Float64||
|maxForce|Float64||

### func steerTowards\(Vector2\)
```cj
public func steerTowards(targetVel: Vector2): Vector2
```
Convert steering force and clamp it

Parameter: 

|Name|Type|Describe|
|---|---|---|
|targetVel|Vector2|Target velocity|

Return: 

- Steering force (new vector)

### func update\(Float64,FlockConfig\)
```cj
public func update(dt: Float64, cfg: FlockConfig): Unit
```
Update position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dt|Float64|Time stepcfg Flock configuration|
|cfg|FlockConfig||

### var acc
```cj
public var acc: Vector2
```
Acceleration

### var maxForce
```cj
public var maxForce: Float64
```
Maximum steering force

### var maxSpeed
```cj
public var maxSpeed: Float64
```
Maximum speed

### var pos
```cj
public var pos: Vector2
```
Position

### var vel
```cj
public var vel: Vector2
```
Velocity

