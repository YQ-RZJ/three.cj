# Class
## class RendererUtils
```cj
public class RendererUtils
```
Renderer utility class

### func autoClear\(Renderer,Scene,Camera\)
```cj
public static func autoClear(renderer: Renderer, scene: Scene, camera: Camera): Unit
```
Auto-clear frame buffers based on renderer settings

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer instancescene Scene instancecamera Camera instance|
|scene|Scene||
|camera|Camera||

### func clear\(Renderer,Bool,Bool,Bool\)
```cj
public static func clear(renderer: Renderer, color: Bool, depth: Bool, stencil: Bool): Unit
```
Manually clear specified channels of the frame buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer instancecolor Whether to clear the color bufferdepth Whether to clear the depth bufferstencil Whether to clear the stencil buffer|
|color|Bool||
|depth|Bool||
|stencil|Bool||

