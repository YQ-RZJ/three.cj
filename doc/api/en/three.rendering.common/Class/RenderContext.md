# Class
## class RenderContext
```cj
public open class RenderContext <: IRenderContext
```
Render context

### func clone\(\)
```cj
public func clone(): RenderContext
```
Deep copies the render context

Return: 

- New RenderContext instance (shallow-copied reference fields)

### func getCamera\(\)
```cj
public func getCamera(): Option < Camera >
```
Returns the camera

Return: 

- Camera, may be None

### func getClearColor\(\)
```cj
public func getClearColor(): UInt32
```
Returns the clear color (UInt32 RGBA)

Return: 

- Clear color value

### func getFrameBuffer\(\)
```cj
public func getFrameBuffer(): Option < RenderTarget >
```
Returns the framebuffer object

Return: 

- Framebuffer, may be None

### func getScene\(\)
```cj
public func getScene(): Option < Scene >
```
Returns the scene

Return: 

- Scene, may be None

### func getViewId\(\)
```cj
public func getViewId(): UInt16
```
Returns the view ID

Return: 

- View identifier

### func getViewport\(\)
```cj
public func getViewport():(Int32, Int32, UInt32, UInt32)
```
Returns the viewport (x, y, w, h)

Return: 

- Viewport tuple

### func init\(\)
```cj
public init()
```
Constructs a default render context

### var active
```cj
public var active: Bool = false
```
Whether active

### var camera
```cj
public var camera: Option < Camera >= None
```
Camera reference

### var clearColorBool
```cj
public var clearColorBool: Bool = true
```
Whether to clear the color buffer

### var clearColor
```cj
public var clearColor: UInt32 = 0x00000000u32
```
Clear color (UInt32 RGBA)

### var clearDepth
```cj
public var clearDepth: Bool = true
```
Whether to clear the depth buffer

### var clearStencil
```cj
public var clearStencil: Bool = false
```
Whether to clear the stencil buffer

### var clippingContext
```cj
public var clippingContext: Option < String >= None
```
Clipping context (optional)

### var depthClearValue
```cj
public var depthClearValue: Float64 = 1.0
```
Depth clear value

### var height
```cj
public var height: Int64 = 0
```
Draw height

### var id
```cj
public var id: Int64
```
Unique identifier

### var occlusion
```cj
public var occlusion: Bool = false
```
Occlusion query

### var projMatrix
```cj
public var projMatrix: Array < Float64 >= Array < Float64 >(16, { _ =>
    0.0
})
```
Projection matrix (16 Float64 values in column-major order)

### var renderTarget
```cj
public var renderTarget: Option < RenderTarget >= None
```
Render target (FBO handle, may be None)

### var scene
```cj
public var scene: Option < Scene >= None
```
Scene reference

### var scissor
```cj
public var scissor:(Int32, Int32, Int32, Int32) =(0, 0, 0, 0)
```
Scissor region (x, y, w, h)

### var stencilClearValue
```cj
public var stencilClearValue: UInt32 = 0u32
```
Stencil clear value

### var viewId
```cj
public var viewId: UInt16 = 0u16
```
View ID (used for bgfx view commands)

### var viewMatrix
```cj
public var viewMatrix: Array < Float64 >= Array < Float64 >(16, { _ =>
    0.0
})
```
View matrix (16 Float64 values in column-major order)

### var viewport
```cj
public var viewport:(Int32, Int32, Int32, Int32) =(0, 0, 0, 0)
```
Viewport (x, y, w, h)

### var width
```cj
public var width: Int64 = 0
```
Draw width

