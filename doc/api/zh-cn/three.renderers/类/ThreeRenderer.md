# 类
## class ThreeRenderer
```cj
public class ThreeRenderer <: Renderer & IRenderer & IReleasable
```
渲染器 — Renderer 薄实现

### func \_fillRenderContext\(RenderContext\)
```cj
public override func _fillRenderContext(renderContext: RenderContext): Unit
```
填充渲染上下文中的默认清屏色

参数: 

|名称|类型|描述|
|---|---|---|
|renderContext|RenderContext||

### func \_syncRenderStats\(\)
```cj
public override func _syncRenderStats(): Unit
```
同步后端渲染统计到抽象层 info（帧末钩子）

### func dbgTextClear\(UInt8,Bool\)
```cj
public func dbgTextClear(attr: UInt8, small!: Bool = false): Unit
```
清空调试文本覆盖层

参数: 

|名称|类型|描述|
|---|---|---|
|attr|UInt8|文本属性（前景/背景色，同 bgfx 约定）|
|small|Bool|true 使用小号字体|

### func dbgTextImage\(UInt16,UInt16,UInt16,UInt16,PtrArray<UInt8>,UInt16\)
```cj
public func dbgTextImage(x: UInt16, y: UInt16, w: UInt16, h: UInt16, data: PtrArray < UInt8 >, pitch: UInt16): Unit
```
在调试文本覆盖层绘制图像（8bit 每像素）

参数: 

|名称|类型|描述|
|---|---|---|
|x|UInt16|列（字符格）|
|y|UInt16|行（字符格）|
|w|UInt16|宽（字符格）|
|h|UInt16|高（字符格）|
|data|PtrArray<UInt8>|图像数据（每像素 1 字节索引）|
|pitch|UInt16|每行字节数|

### func dbgTextPrintf\(UInt16,UInt16,UInt8,String\)
```cj
public func dbgTextPrintf(x: UInt16, y: UInt16, attr: UInt8, format: String): Unit
```
在调试文本覆盖层打印一行文本

参数: 

|名称|类型|描述|
|---|---|---|
|x|UInt16|列（字符格）|
|y|UInt16|行（字符格）|
|attr|UInt8|文本属性（前景/背景色，同 bgfx 约定，如 0x0f 白底黑字风格）|
|format|String|文本内容（无 C 格式化语义，按字面输出）|

### func getCapabilities\(\)
```cj
public func getCapabilities(): GfxCapsSummary
```
获取后端能力摘要

返回: 

- 能力摘要（值语义）

### func getRenderTarget\(\)
```cj
public func getRenderTarget(): Option < IRenderTarget >
```
获取当前渲染目标

返回: 

- 当前渲染目标（None 表示默认帧缓冲）

### func getRenderViewId\(\)
```cj
public override func getRenderViewId(): UInt16
```
获取当前渲染 view id（override 基类钩子）

返回: 

- 当前 view id

### func getRendererType\(\)
```cj
public func getRendererType(): GfxRendererType
```
获取当前渲染后端类型

返回: 

- 渲染器后端类型枚举

### func initBgfx\(UIntNative,Int32,Int32,Bool,UInt32,UInt32,UInt8,UInt8\)
```cj
public func initBgfx(hwnd: UIntNative, width: Int32, height: Int32, vsync!: Bool = false, msaa!: UInt32 = GfxResetFlag.NONE, maxAnisotropy!: UInt32 = GfxResetFlag.NONE, numBackBuffers!: UInt8 = 2u8, maxFrameLatency!: UInt8 = 2u8): Bool
```
初始化渲染后端

参数: 

|名称|类型|描述|
|---|---|---|
|hwnd|UIntNative|原生窗口句柄width 窗口逻辑宽度height 窗口逻辑高度vsync 是否开启垂直同步（默认 false，即不锁定刷新率）。开启后帧率被显示器刷新率锁死（60Hz 显示器即 60FPS 上限）；关闭则按 CPU/GPU 实际耗时出帧，简单场景可达数百 FPS，但可能出现画面撕裂、帧间隔不均。msaa 多重采样档位，取 GfxResetFlag.MSAA_* 常量组合（0 表示关闭）。maxAnisotropy 最大各向异性过滤（0 = 不启用）。numBackBuffers 后备缓冲数量（1~MAX_BACK_BUFFERS，越大越能掩盖 GPU 抖动，延迟也越高）。maxFrameLatency 允许的最大帧排队数。|
|width|Int32||
|height|Int32||
|vsync|Bool||
|msaa|UInt32||
|maxAnisotropy|UInt32||
|numBackBuffers|UInt8||
|maxFrameLatency|UInt8||

返回: 

- 初始化是否成功

### func init\(\)
```cj
public init()
```


### func makeShaderProgram\(String,String,String,String\)
```cj
public static func makeShaderProgram(name: String, vertexShader: String, fragmentShader: String, varyingDef!: String = ""): IShaderProgram
```
创建着色器程序（抽象层工厂）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|着色器程序名称|
|vertexShader|String|顶点着色器源码|
|fragmentShader|String|片段着色器源码|
|varyingDef|String|varying 定义（.sc 格式），默认为空|

### func makeUniformRegistry\(\)
```cj
public static func makeUniformRegistry(): IUniformRegistry
```
创建 uniform 注册表（抽象层工厂）

### func present\(Bool\)
```cj
public func present(capture!: Bool = false): Unit
```
触发一次双缓冲交换上屏

参数: 

|名称|类型|描述|
|---|---|---|
|capture|Bool|是否截屏（默认 false）|

### func release\(\)
```cj
public func release(): Bool
```
关闭渲染器，释放资源

### func renderAsync\(Scene,Camera\)
```cj
public func renderAsync(scene: Scene, camera: Camera): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene||
|camera|Camera||

### func renderToView\(Scene,Camera,Option<UInt16>,Option<\(Int32,Int32,Int32,Int32\)>,Option<UInt32>\)
```cj
public func renderToView(scene: Scene, camera: Camera, viewId!: Option < UInt16 >= None, viewport!: Option <(Int32, Int32, Int32, Int32) >= None, clearColor!: Option < UInt32 >= None): Unit
```
离屏渲染场景到指定 view（不触发 bgfx_frame 上屏）

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene||
|camera|Camera||
|viewId|Option<UInt16>||
|viewport|Option<(Int32,Int32,Int32,Int32)>||
|clearColor|Option<UInt32>||

### func render\(Scene,Camera\)
```cj
public func render(scene: Scene, camera: Camera): Unit
```
渲染场景（经命令执行器委托到命令线程）

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|待渲染场景camera 渲染相机|
|camera|Camera||

### func runOnRenderThread\(\(\)\->Unit\)
```cj
public func runOnRenderThread(cmd:() -> Unit): Unit
```
公开线程序列化入口：把任意闭包路由到命令线程执行

参数: 

|名称|类型|描述|
|---|---|---|
|cmd|()->Unit|待执行的闭包|

### func setClearColor\(Color,Float64\)
```cj
public func setClearColor(color: Color, alpha!: Float64 = 1.0): Unit
```
设置清除色

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|清除颜色alpha 透明度，默认 1.0|
|alpha|Float64||

### func setDebugText\(Bool\)
```cj
public func setDebugText(enabled: Bool): Unit
```
开启/关闭调试文本覆盖层（语义化封装，不暴露后端调试标志数值）

参数: 

|名称|类型|描述|
|---|---|---|
|enabled|Bool|true 开启调试文本覆盖层，false 关闭|

### func setDebug\(UInt32\)
```cj
public func setDebug(debug: UInt32): Unit
```
设置后端调试标志（如线框模式），经命令线程路由保证顺序

参数: 

|名称|类型|描述|
|---|---|---|
|debug|UInt32|调试标志位组合|

### func setRenderTarget\(IRenderTarget,Int64,Int64\)
```cj
public func setRenderTarget(renderTarget: IRenderTarget, cubeFace: Int64, mipLevel: Int64): Unit
```
设置渲染目标（IRenderer 接口实现，CubeCamera 6 面渲染的渲染目标切换）

参数: 

|名称|类型|描述|
|---|---|---|
|renderTarget|IRenderTarget|渲染目标cubeFace 立方体面索引（0~5）mipLevel mipmap 层级|
|cubeFace|Int64||
|mipLevel|Int64||

### func setShadowType\(Int64\)
```cj
public func setShadowType(value: Int64): Unit
```
设置阴影类型（转调后端实现）

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|阴影类型值|

### func setSize\(Int32,Int32\)
```cj
public func setSize(width: Int32, height: Int32): Unit
```
设置渲染器尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int32|逻辑宽度（像素）height 逻辑高度（像素）|
|height|Int32||

### func setWireframe\(Bool\)
```cj
public func setWireframe(enabled: Bool): Unit
```
开启/关闭线框调试模式（语义化封装，不暴露后端调试标志数值）

参数: 

|名称|类型|描述|
|---|---|---|
|enabled|Bool|true 开启线框，false 关闭|

### func syncFrame\(\)
```cj
public func syncFrame(): Unit
```


