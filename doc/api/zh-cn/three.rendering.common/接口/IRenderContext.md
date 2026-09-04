# 接口
## interface IRenderContext
```cj
public interface IRenderContext
```
渲染上下文占位接口，提供视图/视口/清除色/帧缓冲等查询方法

### func getCamera\(\)
```cj
func getCamera(): Option < Camera >
```
返回相机

### func getClearColor\(\)
```cj
func getClearColor(): UInt32
```
返回清除颜色（UInt32 RGBA）

### func getFrameBuffer\(\)
```cj
func getFrameBuffer(): Option < RenderTarget >
```
返回帧缓冲对象（可为空）

### func getScene\(\)
```cj
func getScene(): Option < Scene >
```
返回场景

### func getViewId\(\)
```cj
func getViewId(): UInt16
```
返回 view ID

### func getViewport\(\)
```cj
func getViewport():(Int32, Int32, UInt32, UInt32)
```
返回视口 (x, y, w, h)

