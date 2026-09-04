# Class
## class Float32BufferAttribute
```cj
public class Float32BufferAttribute <: BufferAttribute
```
Float32 buffer attribute (Cangjie side uniformly uses Float64 array storage)

### func getArrayType\(\)
```cj
public override func getArrayType(): String
```
Return corresponding JS TypedArray name "Float32Array"

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

