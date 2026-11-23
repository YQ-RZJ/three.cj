# 类
## class RendererUtils
```cj
public class RendererUtils
```
渲染器工具类

### func autoClear\(Renderer,Scene,Camera\)
```cj
public static func autoClear(renderer: Renderer, scene: Scene, camera: Camera): Unit
```
根据渲染器设置自动清除帧缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器实例scene 场景实例camera 相机实例|
|scene|Scene||
|camera|Camera||

### func clear\(Renderer,Bool,Bool,Bool\)
```cj
public static func clear(renderer: Renderer, color: Bool, depth: Bool, stencil: Bool): Unit
```
手动清除帧缓冲的指定通道

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器实例color 是否清除颜色缓冲depth 是否清除深度缓冲stencil 是否清除模板缓冲|
|color|Bool||
|depth|Bool||
|stencil|Bool||

