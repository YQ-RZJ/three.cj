# Interface
## interface IFrustumCullable
```cj
public interface IFrustumCullable
```
Read-only interface for frustum culling: provides object's world-space bounding sphere

### func getWorldBoundingSphere\(\)
```cj
func getWorldBoundingSphere(): Option < Array < Float64 >>
```
Compute the object's world-space bounding sphere

Return: 

- Some([cx, cy, cz, radius]) or None (no geometry)

