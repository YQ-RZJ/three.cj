# 类
## class Float32BufferAttribute
```cj
public class Float32BufferAttribute <: BufferAttribute
```
Float32 缓冲区属性（仓颉侧统一用 Float64 数组存储）

### func getArrayType\(\)
```cj
public override func getArrayType(): String
```
返回对应 JS TypedArray 名 "Float32Array"

### func init\(Array<Float64>,Int64,Bool\)
```cj
public init(array: Array < Float64 >, itemSize: Int64, normalized!: Bool = false)
```


参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>||
|itemSize|Int64||
|normalized|Bool||

