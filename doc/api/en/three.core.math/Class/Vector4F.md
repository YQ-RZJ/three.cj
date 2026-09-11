# Class
## class Vector4F
```cj
public class Vector4F
```
Float32 4D vector class

### func addScalar\(Float32\)
```cj
public func addScalar(s: Float32): Vector4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func add\(Vector4F\)
```cj
public func add(v: Vector4F): Vector4F
```
===== Arithmetic =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4F||

### func clone\(\)
```cj
public func clone(): Vector4F
```


### func copy\(Vector4F\)
```cj
public func copy(v: Vector4F): Vector4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4F||

### func divideScalar\(Float32\)
```cj
public func divideScalar(s: Float32): Vector4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func dot\(Vector4F\)
```cj
public func dot(v: Vector4F): Float32
```
===== Products =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4F||

### func equals\(Vector4F\)
```cj
public func equals(v: Vector4F): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4F||

### func fromArray\(Array<Float32>\)
```cj
public static func fromArray(arr: Array < Float32 >): Vector4F
```
Construct from Array<Float32> (length 4)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|arr|Array<Float32>||

### func init\(\)
```cj
public init()
```


### func init\(Float32,Float32,Float32,Float32\)
```cj
public init(x: Float32, y: Float32, z: Float32, w: Float32)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32||
|y|Float32||
|z|Float32||
|w|Float32||

### func lengthSq\(\)
```cj
public func lengthSq(): Float32
```


### func length\(\)
```cj
public func length(): Float32
```


### func lerp\(Vector4F,Float32\)
```cj
public func lerp(v: Vector4F, alpha: Float32): Vector4F
```
===== Interpolation =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4F||
|alpha|Float32||

### func multiplyScalar\(Float32\)
```cj
public func multiplyScalar(s: Float32): Vector4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func multiply\(Vector4F\)
```cj
public func multiply(v: Vector4F): Vector4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4F||

### func negate\(\)
```cj
public func negate(): Vector4F
```
===== Misc =====

### func normalize\(\)
```cj
public func normalize(): Vector4F
```


### func setScalar\(Float32\)
```cj
public func setScalar(s: Float32): Vector4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func set\(Float32,Float32,Float32,Float32\)
```cj
public func set(x: Float32, y: Float32, z: Float32, w: Float32): Vector4F
```
===== Setters =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32||
|y|Float32||
|z|Float32||
|w|Float32||

### func subScalar\(Float32\)
```cj
public func subScalar(s: Float32): Vector4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func sub\(Vector4F\)
```cj
public func sub(v: Vector4F): Vector4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4F||

### func toArray\(\)
```cj
public func toArray(): Array < Float32 >
```
Convert to Array<Float32> (length 4)

### var w
```cj
public var w: Float32
```


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


