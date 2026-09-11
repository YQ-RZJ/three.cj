# 类
## class Vector3F
```cj
public class Vector3F
```
Float32 3D 向量类

### func addScalar\(Float32\)
```cj
public func addScalar(s: Float32): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float32||

### func addScaledVector\(Vector3F,Float32\)
```cj
public func addScaledVector(v: Vector3F, s: Float32): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||
|s|Float32||

### func addVectors\(Vector3F,Vector3F\)
```cj
public func addVectors(a: Vector3F, b: Vector3F): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3F||
|b|Vector3F||

### func add\(Vector3F\)
```cj
public func add(v: Vector3F): Vector3F
```
===== Arithmetic =====

参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func crossVectors\(Vector3F,Vector3F\)
```cj
public func crossVectors(a: Vector3F, b: Vector3F): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3F||
|b|Vector3F||

### func cross\(Vector3F\)
```cj
public func cross(v: Vector3F): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func distanceToSquared\(Vector3F\)
```cj
public func distanceToSquared(v: Vector3F): Float32
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func distanceTo\(Vector3F\)
```cj
public func distanceTo(v: Vector3F): Float32
```
===== Distance =====

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func divideScalar\(Float32\)
```cj
public func divideScalar(s: Float32): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float32||

### func divide\(Vector3F\)
```cj
public func divide(v: Vector3F): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func dot\(Vector3F\)
```cj
public func dot(v: Vector3F): Float32
```
===== Products =====

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func equals\(Vector3F\)
```cj
public func equals(v: Vector3F): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func fromArray\(Array<Float32>\)
```cj
public static func fromArray(arr: Array < Float32 >): Vector3F
```
从 Array<Float32>（长度3）构造

参数: 

|名称|类型|描述|
|---|---|---|
|arr|Array<Float32>||

### func fromVector3\(Vector3\)
```cj
public static func fromVector3(v: Vector3): Vector3F
```
从 Vector3 (Float64) 转换为 Vector3F

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|Float64 向量|

返回: 

- Float32 向量

### func init\(\)
```cj
public init()
```


### func init\(Float32,Float32,Float32\)
```cj
public init(x: Float32, y: Float32, z: Float32)
```


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|v1|Vector3F||
|v2|Vector3F||
|alpha|Float32||

### func lerp\(Vector3F,Float32\)
```cj
public func lerp(v: Vector3F, alpha: Float32): Vector3F
```
===== Interpolation =====

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||
|alpha|Float32||

### func max\(Vector3F\)
```cj
public func max(v: Vector3F): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func min\(Vector3F\)
```cj
public func min(v: Vector3F): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func multiplyScalar\(Float32\)
```cj
public func multiplyScalar(s: Float32): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float32||

### func multiply\(Vector3F\)
```cj
public func multiply(v: Vector3F): Vector3F
```


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|length|Float32||

### func setScalar\(Float32\)
```cj
public func setScalar(s: Float32): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float32||

### func setX\(Float32\)
```cj
public func setX(x: Float32): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32||

### func setY\(Float32\)
```cj
public func setY(y: Float32): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|y|Float32||

### func setZ\(Float32\)
```cj
public func setZ(z: Float32): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|z|Float32||

### func set\(Float32,Float32,Float32\)
```cj
public func set(x: Float32, y: Float32, z: Float32): Vector3F
```
===== Setters =====

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32||
|y|Float32||
|z|Float32||

### func subScalar\(Float32\)
```cj
public func subScalar(s: Float32): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float32||

### func subVectors\(Vector3F,Vector3F\)
```cj
public func subVectors(a: Vector3F, b: Vector3F): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3F||
|b|Vector3F||

### func sub\(Vector3F\)
```cj
public func sub(v: Vector3F): Vector3F
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3F||

### func toArray\(\)
```cj
public func toArray(): Array < Float32 >
```
转换为 Array<Float32>（长度3）

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


