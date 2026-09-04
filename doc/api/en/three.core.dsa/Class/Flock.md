# Class
## class Flock
```cj
public class Flock
```
Flock (manages all Boids)

### func averageNeighborDistance\(\)
```cj
public func averageNeighborDistance(): Float64
```
Compute the average nearest neighbor distance

Return: 

- Average nearest neighbor distance

### func averageSpeed\(\)
```cj
public func averageSpeed(): Float64
```
Compute the average speed

Return: 

- Average speed

### func centerOfMass\(\)
```cj
public func centerOfMass(): Vector2
```
Compute the center of mass of the flock

Return: 

- Center of mass position

### func init\(Array<Boid>,FlockConfig\)
```cj
public init(boids: Array < Boid >, cfg: FlockConfig)
```
Construct a flock

Parameter: 

|Name|Type|Describe|
|---|---|---|
|boids|Array<Boid>|Array of boid individualscfg Flock configuration|
|cfg|FlockConfig||

### func step\(Float64\)
```cj
public func step(dt: Float64): Unit
```
Advance one simulation step

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dt|Float64|Time step|

### var boids
```cj
public var boids: Array < Boid >
```
All boid individuals

### var cfg
```cj
public var cfg: FlockConfig
```
Flock configuration

