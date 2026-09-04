# Class
## class BgfxRenderList
```cj
public class BgfxRenderList
```
Render list

### func \`init\`\(\)
```cj
public func `init`(): Unit
```
Initializes render list

### func finish\(\)
```cj
public func finish(): Unit
```
Sorts render lists

### func getOpaque\(\)
```cj
public func getOpaque(): ArrayList < RenderItem >
```
Gets opaque object list

Return: 

- Opaque object list

### func getTransmissive\(\)
```cj
public func getTransmissive(): ArrayList < RenderItem >
```
Gets transmissive object list

Return: 

- Transmissive object list

### func getTransparent\(\)
```cj
public func getTransparent(): ArrayList < RenderItem >
```
Gets transparent object list

Return: 

- Transparent object list

### func init\(\)
```cj
public init()
```


### func push\(Int64,Int64,Int64,Int64,Int64,Int64,Float64,Int64\)
```cj
public func push(id: Int64, objectId: Int64, renderOrder: Int64, groupOrder: Int64, materialId: Int64, materialVariant: Int64, z: Float64, programId: Int64): Unit
```
Adds render item

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64||
|objectId|Int64||
|renderOrder|Int64||
|groupOrder|Int64||
|materialId|Int64||
|materialVariant|Int64||
|z|Float64||
|programId|Int64||

