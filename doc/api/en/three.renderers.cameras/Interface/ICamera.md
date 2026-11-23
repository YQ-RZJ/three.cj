# Interface
## interface ICamera
```cj
public interface ICamera
```
Camera abstract interface: camera parameter type for IRenderer.render

### func getMatrixWorldInverse\(\)
```cj
func getMatrixWorldInverse(): Matrix4
```
Inverse of the world matrix (view matrix, 16 Float64 column-major)

### func getProjectionMatrix\(\)
```cj
func getProjectionMatrix(): Matrix4
```
Projection matrix (16 Float64 column-major)

