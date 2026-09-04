# Interface
## interface IGeometryProvider
```cj
public interface IGeometryProvider
```
Geometry capability interface: for clipping/bounding box/precise traversal to access geometry data

### func computeBoundingBox\(\)
```cj
func computeBoundingBox(): Unit
```
Computes bounding box (implementor updates its own boundingBox)

### func computeBoundingSphere\(\)
```cj
func computeBoundingSphere(): Unit
```
Computes bounding sphere (implementor updates its own boundingSphere)

### func getAttributeReader\(String\)
```cj
func getAttributeReader(name: String): Option < AttributeReader >
```
Gets vertex attribute by name (AttributeReader read-only interface, position/normal/uv etc.)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func getBoundingBox\(\)
```cj
func getBoundingBox(): Option < Box3 >
```
Gets the bounding box (None if no geometry data)

### func getBoundingSphere\(\)
```cj
func getBoundingSphere(): Option < Sphere >
```
Gets the bounding sphere (None if no geometry data)

