# Class
## class Bindings
```cj
public open class Bindings <: DataMap
```
Pipeline bindings collection manager

### func createBindGroup\(\)
```cj
public func createBindGroup(): BindGroup
```
Creates a bind group

Return: 

- Newly created bind group

### func destroyBindGroup\(BindGroup\)
```cj
public func destroyBindGroup(group: BindGroup): Unit
```
Destroys a bind group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|group|BindGroup|Bind group|

### func init\(\)
```cj
public init()
```
Constructs a bindings collection manager

### func setupBindGroup\(BindGroup,RenderPipeline\)
```cj
public func setupBindGroup(group: BindGroup, pipeline: RenderPipeline): Unit
```
Sets up the association between a bind group and a pipeline

Parameter: 

|Name|Type|Describe|
|---|---|---|
|group|BindGroup|Bind grouppipeline Render pipeline|
|pipeline|RenderPipeline||

### func updateBindGroup\(BindGroup\)
```cj
public func updateBindGroup(group: BindGroup): Unit
```
Updates a bind group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|group|BindGroup|Bind group|

