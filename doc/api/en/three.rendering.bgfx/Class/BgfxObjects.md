# Class
## class BgfxObjects
```cj
public class BgfxObjects
```
bgfx scene object management

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes all update mappings

### func init\(BgfxGeometries,BgfxAttributes,BgfxInfo\)
```cj
public init(geometries!: BgfxGeometries, attributes!: BgfxAttributes, info!: BgfxInfo)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometries|BgfxGeometries||
|attributes|BgfxAttributes||
|info|BgfxInfo||

### func update\(Int64,Int64,Bool,Bool\)
```cj
public func update(objectId: Int64, geometryId: Int64, isInstancedMesh: Bool, isSkinnedMesh: Bool): Int64
```
Updates object render data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|objectId|Int64|Object IDgeometryId Geometry IDisInstancedMesh Whether it is an instanced meshisSkinnedMesh Whether it is a skinned mesh|
|geometryId|Int64||
|isInstancedMesh|Bool||
|isSkinnedMesh|Bool||

Return: 

- Geometry buffer data ID

