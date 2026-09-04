# Class
## class Uint32BufferAttribute
```cj
public class Uint32BufferAttribute <: BufferAttribute
```
Uint32 buffer attribute (Cangjie side uses Float64 array to store index values)

### func getArrayType\(\)
```cj
public override func getArrayType(): String
```
Return corresponding JS TypedArray name "Uint32Array"

### func init\(Array<Float64>,Int64,Bool\)
```cj
public init(array: Array < Float64 >, itemSize: Int64, normalized!: Bool = false)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>||
|itemSize|Int64||
|normalized|Bool||

