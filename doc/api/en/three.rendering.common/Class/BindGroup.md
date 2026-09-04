# Class
## class BindGroup
```cj
public open class BindGroup
```
Pipeline bind group, containing a set of Bindings and their associated render pipeline

### func addBinding\(Binding\)
```cj
public func addBinding(binding: Binding): Unit
```
Adds a binding to the bind group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|binding|Binding|Binding object|

### func getBinding\(String\)
```cj
public func getBinding(name: String): Option < Binding >
```
Gets a binding by name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Binding name|

Return: 

- Matched binding, or None if not found

### func init\(\)
```cj
public init()
```
Constructs a default bind group

### var bindings
```cj
public var bindings: ArrayList < Binding >
```
List of bindings

### var id
```cj
public var id: Int64
```
Bind group identifier

### var pipeline
```cj
public var pipeline: RenderPipeline
```
Associated render pipeline

