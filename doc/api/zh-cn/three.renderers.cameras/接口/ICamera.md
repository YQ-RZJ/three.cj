# 接口
## interface ICamera
```cj
public interface ICamera
```
相机抽象接口：IRenderer.render 的 camera 参数类型

### func getMatrixWorldInverse\(\)
```cj
func getMatrixWorldInverse(): Matrix4
```
世界矩阵的逆（视图矩阵，16 个 Float64 列主序）

### func getProjectionMatrix\(\)
```cj
func getProjectionMatrix(): Matrix4
```
投影矩阵（16 个 Float64 列主序）

