# 类
## class GLBufferAttribute
```cj
public class GLBufferAttribute
```
GL 缓冲区属性类

### func getNeedsUpdate\(\)
```cj
public func getNeedsUpdate(): Bool
```
检查属性是否需要更新

返回: 

- 如果 version > 0 则返回 true

### func init\(VertexBufferHandle,Int64,Int64,Int64,Int64,Bool\)
```cj
public init(buffer: VertexBufferHandle, kind!: Int64 = 0, itemSize!: Int64 = 0, elementSize!: Int64 = 0, count!: Int64 = 0, normalized!: Bool = false)
```
构造一个新的 GL 缓冲区属性

参数: 

|名称|类型|描述|
|---|---|---|
|buffer|VertexBufferHandle|原生缓冲区句柄（Box 包装）kind 数据类型标识（对应 JS 中的 type）itemSize 每个顶点的数据项大小elementSize 对应 kind 的字节大小count 预期的顶点数量normalized 是否归一化，默认为 false|
|kind|Int64||
|itemSize|Int64||
|elementSize|Int64||
|count|Int64||
|normalized|Bool||

### func setBuffer\(VertexBufferHandle\)
```cj
public func setBuffer(buffer: VertexBufferHandle): GLBufferAttribute
```
设置原生缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|buffer|VertexBufferHandle|新的缓冲区句柄（Box 包装）|

返回: 

- 当前实例（支持链式调用）

### func setCount\(Int64\)
```cj
public func setCount(count: Int64): GLBufferAttribute
```
设置顶点数量

参数: 

|名称|类型|描述|
|---|---|---|
|count|Int64|预期的顶点数量|

返回: 

- 当前实例（支持链式调用）

### func setItemSize\(Int64\)
```cj
public func setItemSize(itemSize: Int64): GLBufferAttribute
```
设置数据项大小

参数: 

|名称|类型|描述|
|---|---|---|
|itemSize|Int64|每个顶点的数据项大小|

返回: 

- 当前实例（支持链式调用）

### func setNeedsUpdate\(Bool\)
```cj
public func setNeedsUpdate(value: Bool): Unit
```
标记属性是否需要更新

参数: 

|名称|类型|描述|
|---|---|---|
|value|Bool|是否需要更新|

### func setType\(Int64,Int64\)
```cj
public func setType(kind: Int64, elementSize: Int64): GLBufferAttribute
```
设置数据类型和元素大小

参数: 

|名称|类型|描述|
|---|---|---|
|kind|Int64|数据类型标识（对应 JS 中的 type）elementSize 对应 kind 的字节大小|
|elementSize|Int64||

返回: 

- 当前实例（支持链式调用）

### var buffer
```cj
public var buffer: VertexBufferHandle
```
原生缓冲区句柄（Box 包装的 bgfx 顶点缓冲句柄）

### var count
```cj
public var count: Int64
```
VBO 中预期的顶点数量

### var elementSize
```cj
public var elementSize: Int64
```
对应 kind 参数的字节大小

### var itemSize
```cj
public var itemSize: Int64
```
每个顶点的数据项大小

### var kind
```cj
public var kind: Int64
```
数据类型标识，对应 bgfx 顶点格式中的属性类型

### var name
```cj
public var name: String
```
缓冲区属性名称

### var normalized
```cj
public var normalized: Bool
```
是否对整数数据进行归一化

### var version
```cj
public var version: Int64
```
版本号，每次 needsUpdate 设为 true 时递增

