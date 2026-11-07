# Class
## class BgfxObjects
```cj
public class BgfxObjects <: IReleasable
```
bgfx scene object management

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

### func release\(\)
```cj
public func release(): Bool
```
dispose all update mappings

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

