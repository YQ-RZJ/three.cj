# Interface
## interface IBox3Expandable
```cj
public interface IBox3Expandable
```
Read-only interface for bounding box expansion: used by Box3.setFromObject / expandByObject for traversal

### func getChildAt\(Int64\)
```cj
func getChildAt(i: Int64): IBox3Expandable
```
Get the i-th child object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64|Child object index|

Return: 

- Child object (also implements IBox3Expandable)

### func getChildCount\(\)
```cj
func getChildCount(): Int64
```
Get the number of child objects

Return: 

- Number of child objects

### func getPreciseVertexCount\(\)
```cj
func getPreciseVertexCount(): Int64
```
Get the vertex count for precise per-vertex traversal

Return: 

- Vertex count (0 means precise traversal not supported, caller should fall back to conservative path)

### func getPreciseVertexPosition\(Int64\)
```cj
func getPreciseVertexPosition(i: Int64): Array < Float64 >
```
Get the world-space position of the i-th vertex

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64|Vertex index|

Return: 

- World-space coordinates [x, y, z]

### func getWorldBoundingBox\(\)
```cj
func getWorldBoundingBox(): Option <(Array < Float64 >, Array < Float64 >) >
```
Compute the object's own (excluding children) world-space bounding box

Return: 

- Some(([minX,minY,minZ], [maxX,maxY,maxZ])) or None (no geometry)

### func updateWorldMatrix\(Bool,Bool,Bool\)
```cj
func updateWorldMatrix(updateParents: Bool, updateChildren: Bool, force: Bool): Unit
```
Update the object's world matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|updateParents|Bool|Whether to update parentsupdateChildren Whether to update childrenforce Whether to force update|
|updateChildren|Bool||
|force|Bool||

