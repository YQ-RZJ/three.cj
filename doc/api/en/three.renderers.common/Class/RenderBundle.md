# Class
## class RenderBundle
```cj
public open class RenderBundle
```
Render bundle, containing a collection of render objects

### func add\(RenderObject\)
```cj
public func add(obj: RenderObject): Unit
```
Adds a render object to the render bundle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|RenderObject|Render object|

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the render object list

### func init\(\)
```cj
public init()
```
Constructs a default render bundle

### var id
```cj
public var id: Int64
```
Render bundle identifier

### var objects
```cj
public var objects: ArrayList < RenderObject >
```
List of render objects

