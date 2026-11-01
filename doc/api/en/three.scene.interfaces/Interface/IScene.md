# Interface
## interface IScene
```cj
public interface IScene
```
Scene marker interface: scene parameter type for CubeCamera.update / PMREMGenerator.fromScene

### func getBackground\(\)
```cj
func getBackground(): Option < IBackground >
```
Get the scene background (one of Color / Texture / CubeTexture)

Return: 

- Background object; None when unset

