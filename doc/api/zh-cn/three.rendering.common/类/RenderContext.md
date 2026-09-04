# 类
## class RenderContext
```cj
public open class RenderContext <: IRenderContext
```
渲染上下文

### func clone\(\)
```cj
public func clone(): RenderContext
```
深拷贝渲染上下文

返回: 

- 新 RenderContext 实例（浅拷贝引用字段）

### func getCamera\(\)
```cj
public func getCamera(): Option < Camera >
```
返回相机

返回: 

- 相机，可能为空

### func getClearColor\(\)
```cj
public func getClearColor(): UInt32
```
返回清除颜色（UInt32 RGBA）

返回: 

- 清除颜色值

### func getFrameBuffer\(\)
```cj
public func getFrameBuffer(): Option < RenderTarget >
```
返回帧缓冲对象

返回: 

- 帧缓冲，可能为空

### func getScene\(\)
```cj
public func getScene(): Option < Scene >
```
返回场景

返回: 

- 场景，可能为空

### func getViewId\(\)
```cj
public func getViewId(): UInt16
```
返回视图 ID

返回: 

- 视图标识符

### func getViewport\(\)
```cj
public func getViewport():(Int32, Int32, UInt32, UInt32)
```
返回视口 (x, y, w, h)

返回: 

- 视口四元组

### func init\(\)
```cj
public init()
```
构造默认渲染上下文

### var active
```cj
public var active: Bool = false
```
是否活跃

### var camera
```cj
public var camera: Option < Camera >= None
```
相机引用

### var clearColorBool
```cj
public var clearColorBool: Bool = true
```
是否清除颜色缓冲

### var clearColor
```cj
public var clearColor: UInt32 = 0x00000000u32
```
清除颜色（UInt32 RGBA）

### var clearDepth
```cj
public var clearDepth: Bool = true
```
是否清除深度缓冲

### var clearStencil
```cj
public var clearStencil: Bool = false
```
是否清除模板缓冲

### var clippingContext
```cj
public var clippingContext: Option < String >= None
```
裁剪上下文（可选）

### var depthClearValue
```cj
public var depthClearValue: Float64 = 1.0
```
深度清除值

### var height
```cj
public var height: Int64 = 0
```
绘制高度

### var id
```cj
public var id: Int64
```
唯一标识

### var occlusion
```cj
public var occlusion: Bool = false
```
遮挡查询

### var projMatrix
```cj
public var projMatrix: Array < Float64 >= Array < Float64 >(16, { _ =>
    0.0
})
```
投影矩阵（16 Float64 列主序）

### var renderTarget
```cj
public var renderTarget: Option < RenderTarget >= None
```
渲染目标（FBO 句柄，可为空）

### var scene
```cj
public var scene: Option < Scene >= None
```
场景引用

### var scissor
```cj
public var scissor:(Int32, Int32, Int32, Int32) =(0, 0, 0, 0)
```
裁剪区域 (x, y, w, h)

### var stencilClearValue
```cj
public var stencilClearValue: UInt32 = 0u32
```
模板清除值

### var viewId
```cj
public var viewId: UInt16 = 0u16
```
视图 ID（用于 bgfx view 命令）

### var viewMatrix
```cj
public var viewMatrix: Array < Float64 >= Array < Float64 >(16, { _ =>
    0.0
})
```
视图矩阵（16 Float64 列主序）

### var viewport
```cj
public var viewport:(Int32, Int32, Int32, Int32) =(0, 0, 0, 0)
```
视口 (x, y, w, h)

### var width
```cj
public var width: Int64 = 0
```
绘制宽度

