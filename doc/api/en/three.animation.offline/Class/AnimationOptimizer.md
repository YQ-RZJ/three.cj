# Class
## class AnimationOptimizer
```cj
public class AnimationOptimizer
```
Animation optimizer

### func init\(Float32,Float32,Float32\)
```cj
public init(translationTolerance!: Float32 = 0.001f32, rotationTolerance!: Float32 = 0.001f32, scaleTolerance!: Float32 = 0.001f32)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|translationTolerance|Float32||
|rotationTolerance|Float32||
|scaleTolerance|Float32||

### func optimizeCopy\(RawAnimation\)
```cj
public func optimizeCopy(input: RawAnimation): RawAnimation
```
Creates an optimized copy (the original data is not modified)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawAnimation|The original offline animation data|

Return: 

- The optimized copy

### func optimize\(RawAnimation\)
```cj
public func optimize(input: RawAnimation): Unit
```
Optimizes offline animation data (in place)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawAnimation|The offline animation data to optimize (in/out)|

### var rotationTolerance
```cj
public var rotationTolerance: Float32
```
Rotation optimization error tolerance (angle in radians)

### var scaleTolerance
```cj
public var scaleTolerance: Float32
```
Scale optimization error tolerance (vector length)

### var translationTolerance
```cj
public var translationTolerance: Float32
```
Translation optimization error tolerance (vector length)

