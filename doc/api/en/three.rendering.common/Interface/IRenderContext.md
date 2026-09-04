# Interface
## interface IRenderContext
```cj
public interface IRenderContext
```
Render context placeholder interface, providing view/viewport/clear color/framebuffer query methods

### func getCamera\(\)
```cj
func getCamera(): Option < Camera >
```
Returns camera

### func getClearColor\(\)
```cj
func getClearColor(): UInt32
```
Returns clear color (UInt32 RGBA)

### func getFrameBuffer\(\)
```cj
func getFrameBuffer(): Option < RenderTarget >
```
Returns framebuffer object (optional)

### func getScene\(\)
```cj
func getScene(): Option < Scene >
```
Returns scene

### func getViewId\(\)
```cj
func getViewId(): UInt16
```
Returns view ID

### func getViewport\(\)
```cj
func getViewport():(Int32, Int32, UInt32, UInt32)
```
Returns viewport (x, y, w, h)

