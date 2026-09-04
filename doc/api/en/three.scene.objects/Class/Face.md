# Class
## class Face
```cj
public class Face
```
Intersection face information

### func init\(Int64,Int64,Int64,Vector3,Int64\)
```cj
public init(a!: Int64 = - 1, b!: Int64 = - 1, c!: Int64 = - 1, normal!: Vector3 = Vector3(), materialIndex!: Int64 = 0)
```
Construct intersection face information

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Int64|First vertex index, default -1b Second vertex index, default -1c Third vertex index, default -1normal Face normal vector, default zero vectormaterialIndex Material index, default 0|
|b|Int64||
|c|Int64||
|normal|Vector3||
|materialIndex|Int64||

### var a
```cj
public var a: Int64
```
First vertex index of the intersected face

### var b
```cj
public var b: Int64
```
Second vertex index of the intersected face

### var c
```cj
public var c: Int64
```
Third vertex index of the intersected face

### var materialIndex
```cj
public var materialIndex: Int64
```
Material index (for multi-material geometry)

### var normal
```cj
public var normal: Vector3
```
Face normal vector

