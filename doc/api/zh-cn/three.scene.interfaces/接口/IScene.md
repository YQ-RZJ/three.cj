# 接口
## interface IScene
```cj
public interface IScene
```
场景标记接口：CubeCamera.update / PMREMGenerator.fromScene 的 scene 参数类型

### func getBackground\(\)
```cj
func getBackground(): Option < IBackground >
```
获取场景背景（Color / Texture / CubeTexture 之一）

返回: 

- 背景对象；未设置时为 None

