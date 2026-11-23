# 类
## class Uint16BufferAttribute
```cj
public class Uint16BufferAttribute <: BufferAttribute
```
Uint16 缓冲区属性（仓颉侧用 Float64 数组存储索引值）

### func getArrayType\(\)
```cj
public override func getArrayType(): String
```
返回 JSON 序列化使用的数组类型名 "Uint16Array"

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

