# Class
## class TrackOptimizer
```cj
public class TrackOptimizer
```
Track optimizer

### func init\(Float32,Float32,Float32\)
```cj
public init(floatTolerance!: Float32 = 0.001f32, float3Tolerance!: Float32 = 0.001f32, rotationTolerance!: Float32 = 0.001f32)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|floatTolerance|Float32||
|float3Tolerance|Float32||
|rotationTolerance|Float32||

### func optimizeFloat3Copy\(RawFloat3Track\)
```cj
public func optimizeFloat3Copy(input: RawFloat3Track): RawFloat3Track
```
Creates an optimized copy of a 3-component vector track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawFloat3Track||

### func optimizeFloat3\(RawFloat3Track\)
```cj
public func optimizeFloat3(input: RawFloat3Track): Unit
```
Optimizes a 3-component vector track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawFloat3Track|The offline 3-component vector track data (modified in place)|

### func optimizeFloatCopy\(RawFloatTrack\)
```cj
public func optimizeFloatCopy(input: RawFloatTrack): RawFloatTrack
```
Creates an optimized copy of a float track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawFloatTrack||

### func optimizeFloat\(RawFloatTrack\)
```cj
public func optimizeFloat(input: RawFloatTrack): Unit
```
Optimizes a float track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawFloatTrack|The offline float track data (modified in place)|

### func optimizeQuaternionCopy\(RawQuaternionTrack\)
```cj
public func optimizeQuaternionCopy(input: RawQuaternionTrack): RawQuaternionTrack
```
Creates an optimized copy of a quaternion track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawQuaternionTrack||

### func optimizeQuaternion\(RawQuaternionTrack\)
```cj
public func optimizeQuaternion(input: RawQuaternionTrack): Unit
```
Optimizes a quaternion track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawQuaternionTrack|The offline quaternion track data (modified in place)|

### var float3Tolerance
```cj
public var float3Tolerance: Float32
```
3-component vector optimization error tolerance

### var floatTolerance
```cj
public var floatTolerance: Float32
```
Float value optimization error tolerance

### var rotationTolerance
```cj
public var rotationTolerance: Float32
```
Rotation optimization error tolerance (radians)

