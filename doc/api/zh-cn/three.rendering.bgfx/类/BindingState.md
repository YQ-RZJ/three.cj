# 类
## class BindingState
```cj
public class BindingState
```
绑定状态

### func init\(Int64,Int64,Bool\)
```cj
public init(geometryId: Int64, programId: Int64, wireframe: Bool)
```


参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64||
|programId|Int64||
|wireframe|Bool||

### func init\(\)
```cj
public init()
```


### var attributesNum
```cj
public var attributesNum: Int64 = 0
```
属性数量

### var attributes
```cj
public var attributes: HashMap < String, AttributeCache >
```
属性缓存

### var geometryId
```cj
public var geometryId: Int64
```
关联的几何体 ID

### var indexHandle
```cj
public var indexHandle: UInt16 = 0u16
```
索引缓冲句柄（0 表示无效）

### var programId
```cj
public var programId: Int64
```
关联的程序 ID

### var vertexLayout
```cj
public var vertexLayout: VertexLayout
```
顶点布局

### var wireframe
```cj
public var wireframe: Bool
```
是否线框模式

