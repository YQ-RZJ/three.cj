# Interface
## interface IRenderObject
```cj
public interface IRenderObject
```
Render object placeholder interface, providing matrix/geometry/material/object ID query methods

### func getGeometryId\(\)
```cj
func getGeometryId(): Int64
```
Returns geometry ID

### func getGroupOrder\(\)
```cj
func getGroupOrder(): Float64
```
Returns render group order

### func getMaterialId\(\)
```cj
func getMaterialId(): Int64
```
Returns material ID

### func getMatrix\(\)
```cj
func getMatrix(): Array < Float64 >
```
Returns world matrix (16 Float64 column-major)

### func getNodeChain\(\)
```cj
func getNodeChain(): ArrayList < Object3D >
```
Returns node chain (for transform matrix)

### func getObjectId\(\)
```cj
func getObjectId(): Int64
```
Returns object ID

### func getRenderOrder\(\)
```cj
func getRenderOrder(): Float64
```
Returns render order

