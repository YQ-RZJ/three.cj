# Class
## class Vector3F
```cj
public class Vector3F
```
Float32 3D vector class

### func addScalar\(Float32\)
```cj
public func addScalar(s: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func addScaledVector\(Vector3F,Float32\)
```cj
public func addScaledVector(v: Vector3F, s: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||
|s|Float32||

### func addVectors\(Vector3F,Vector3F\)
```cj
public func addVectors(a: Vector3F, b: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3F||
|b|Vector3F||

### func add\(Vector3F\)
```cj
public func add(v: Vector3F): Vector3F
```
===== Arithmetic =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func clone\(\)
```cj
public func clone(): Vector3F
```


### func copy\(Vector3F\)
```cj
public func copy(v: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func crossVectors\(Vector3F,Vector3F\)
```cj
public func crossVectors(a: Vector3F, b: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3F||
|b|Vector3F||

### func cross\(Vector3F\)
```cj
public func cross(v: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func distanceToSquared\(Vector3F\)
```cj
public func distanceToSquared(v: Vector3F): Float32
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func distanceTo\(Vector3F\)
```cj
public func distanceTo(v: Vector3F): Float32
```
===== Distance =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func divideScalar\(Float32\)
```cj
public func divideScalar(s: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func divide\(Vector3F\)
```cj
public func divide(v: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func dot\(Vector3F\)
```cj
public func dot(v: Vector3F): Float32
```
===== Products =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func equals\(Vector3F\)
```cj
public func equals(v: Vector3F): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func fromArray\(Array<Float32>\)
```cj
public static func fromArray(arr: Array < Float32 >): Vector3F
```
Construct from Array<Float32> (length 3)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|arr|Array<Float32>||

### func fromVector3\(Vector3\)
```cj
public static func fromVector3(v: Vector3): Vector3F
```
Convert from Vector3 (Float64) to Vector3F

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Float64 vector|

Return: 

- Float32 vector

### func init\(\)
```cj
public init()
```


### func init\(Float32,Float32,Float32\)
```cj
public init(x: Float32, y: Float32, z: Float32)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32||
|y|Float32||
|z|Float32||

### func lengthSq\(\)
```cj
public func lengthSq(): Float32
```
===== Length =====

### func length\(\)
```cj
public func length(): Float32
```


### func lerpVectors\(Vector3F,Vector3F,Float32\)
```cj
public func lerpVectors(v1: Vector3F, v2: Vector3F, alpha: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v1|Vector3F||
|v2|Vector3F||
|alpha|Float32||

### func lerp\(Vector3F,Float32\)
```cj
public func lerp(v: Vector3F, alpha: Float32): Vector3F
```
===== Interpolation =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||
|alpha|Float32||

### func max\(Vector3F\)
```cj
public func max(v: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func min\(Vector3F\)
```cj
public func min(v: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func multiplyScalar\(Float32\)
```cj
public func multiplyScalar(s: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func multiply\(Vector3F\)
```cj
public func multiply(v: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func negate\(\)
```cj
public func negate(): Vector3F
```
===== Misc =====

### func normalize\(\)
```cj
public func normalize(): Vector3F
```


### func setLength\(Float32\)
```cj
public func setLength(length: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|length|Float32||

### func setScalar\(Float32\)
```cj
public func setScalar(s: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func setX\(Float32\)
```cj
public func setX(x: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32||

### func setY\(Float32\)
```cj
public func setY(y: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|y|Float32||

### func setZ\(Float32\)
```cj
public func setZ(z: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|z|Float32||

### func set\(Float32,Float32,Float32\)
```cj
public func set(x: Float32, y: Float32, z: Float32): Vector3F
```
===== Setters =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32||
|y|Float32||
|z|Float32||

### func subScalar\(Float32\)
```cj
public func subScalar(s: Float32): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func subVectors\(Vector3F,Vector3F\)
```cj
public func subVectors(a: Vector3F, b: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3F||
|b|Vector3F||

### func sub\(Vector3F\)
```cj
public func sub(v: Vector3F): Vector3F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3F||

### func toArray\(\)
```cj
public func toArray(): Array < Float32 >
```
Convert to Array<Float32> (length 3)

### var x
```cj
public var x: Float32
```


### var y
```cj
public var y: Float32
```


### var z
```cj
public var z: Float32
```


