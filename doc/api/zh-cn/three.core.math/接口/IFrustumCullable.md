# 接口
## interface IFrustumCullable
```cj
public interface IFrustumCullable
```
视锥体裁剪只读接口：提供对象的世界空间包围球

### func getWorldBoundingSphere\(\)
```cj
func getWorldBoundingSphere(): Option < Array < Float64 >>
```
计算对象的世界空间包围球

返回: 

- Some([cx, cy, cz, radius]) 或 None（无几何体）

