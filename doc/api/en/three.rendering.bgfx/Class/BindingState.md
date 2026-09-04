# Class
## class BindingState
```cj
public class BindingState
```
Binding state

### func init\(Int64,Int64,Bool\)
```cj
public init(geometryId: Int64, programId: Int64, wireframe: Bool)
```


Parameter: 

|Name|Type|Describe|
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
Number of attributes

### var attributes
```cj
public var attributes: HashMap < String, AttributeCache >
```
Attribute cache

### var geometryId
```cj
public var geometryId: Int64
```
Associated geometry ID

### var indexHandle
```cj
public var indexHandle: UInt16 = 0u16
```
Index buffer handle (0 means invalid)

### var programId
```cj
public var programId: Int64
```
Associated program ID

### var vertexLayout
```cj
public var vertexLayout: VertexLayout
```
Vertex layout

### var wireframe
```cj
public var wireframe: Bool
```
Whether wireframe mode

