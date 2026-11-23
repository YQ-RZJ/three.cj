# Class
## class ThreeRenderer
```cj
public class ThreeRenderer <: Renderer & IRenderer & IReleasable
```
The renderer — a thin Renderer implementation

### func \_fillRenderContext\(RenderContext\)
```cj
public override func _fillRenderContext(renderContext: RenderContext): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|RenderContext||

### func \_syncRenderStats\(\)
```cj
public override func _syncRenderStats(): Unit
```
Sync backend render stats into abstract-layer info (frame-end hook)

### func dbgTextClear\(UInt8,Bool\)
```cj
public func dbgTextClear(attr: UInt8, small!: Bool = false): Unit
```
Clears the debug text overlay

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attr|UInt8|Text attribute (fg/bg colors, same as bgfx convention)|
|small|Bool|true to use the small font|

### func dbgTextImage\(UInt16,UInt16,UInt16,UInt16,PtrArray<UInt8>,UInt16\)
```cj
public func dbgTextImage(x: UInt16, y: UInt16, w: UInt16, h: UInt16, data: PtrArray < UInt8 >, pitch: UInt16): Unit
```
Draws an image on the debug text overlay (8bit per pixel)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|UInt16|Column|
|y|UInt16|Row|
|w|UInt16|Width (cells)|
|h|UInt16|Height (cells)|
|data|PtrArray<UInt8>|Image data (1 byte index per pixel)|
|pitch|UInt16|Bytes per row|

### func dbgTextPrintf\(UInt16,UInt16,UInt8,String\)
```cj
public func dbgTextPrintf(x: UInt16, y: UInt16, attr: UInt8, format: String): Unit
```
Prints a line of text on the debug text overlay

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|UInt16|Column (character cell)|
|y|UInt16|Row (character cell)|
|attr|UInt8|Text attribute (fg/bg colors, same as bgfx convention, e.g. 0x0f)|
|format|String|Text content (no C formatting semantics, printed literally)|

### func getCapabilities\(\)
```cj
public func getCapabilities(): GfxCapsSummary
```
Get the backend capability summary

Return: 

- The capability summary (value semantics)

### func getRenderTarget\(\)
```cj
public func getRenderTarget(): Option < IRenderTarget >
```
Get current render target

Return: 

- Current render target (None for default framebuffer)

### func getRenderViewId\(\)
```cj
public override func getRenderViewId(): UInt16
```
Get current render view id (override base class hook)

Return: 

- Current view id

### func getRendererType\(\)
```cj
public func getRendererType(): GfxRendererType
```
Get current renderer backend type

Return: 

- The renderer backend type enum

### func initBgfx\(UIntNative,Int32,Int32,Bool,UInt32,UInt32,UInt8,UInt8\)
```cj
public func initBgfx(hwnd: UIntNative, width: Int32, height: Int32, vsync!: Bool = false, msaa!: UInt32 = GfxResetFlag.NONE, maxAnisotropy!: UInt32 = GfxResetFlag.NONE, numBackBuffers!: UInt8 = 2u8, maxFrameLatency!: UInt8 = 2u8): Bool
```
Initialize the render backend

Parameter: 

|Name|Type|Describe|
|---|---|---|
|hwnd|UIntNative|Native window handlewidth Window logical widthheight Window logical heightvsync Enable vertical sync (default false, i.e. refresh rate not capped). When on, the framerate is capped by the display refresh rate (60Hz display → 60FPS ceiling); when off, framesare produced as fast as CPU/GPU allow (hundreds of FPS on simple scenes) buttearing/uneven pacing may occur.msaa Multisample level, combine GfxResetFlag.MSAA_* constants (0 = disabled).maxAnisotropy Maximum anisotropy filtering (0 = disabled).numBackBuffers Number of back buffers (1..MAX_BACK_BUFFERS; more hides GPU jitter, adds latency).maxFrameLatency Maximum queued frames allowed.|
|width|Int32||
|height|Int32||
|vsync|Bool||
|msaa|UInt32||
|maxAnisotropy|UInt32||
|numBackBuffers|UInt8||
|maxFrameLatency|UInt8||

Return: 

- Whether initialization succeeded

### func init\(\)
```cj
public init()
```


### func makeShaderProgram\(String,String,String,String\)
```cj
public static func makeShaderProgram(name: String, vertexShader: String, fragmentShader: String, varyingDef!: String = ""): IShaderProgram
```
Creates a shader program (abstraction-layer factory)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Shader program name|
|vertexShader|String|Vertex shader source|
|fragmentShader|String|Fragment shader source|
|varyingDef|String|Varying definition (.sc format), default empty|

### func makeUniformRegistry\(\)
```cj
public static func makeUniformRegistry(): IUniformRegistry
```
Creates a uniform registry (abstraction-layer factory)

### func present\(Bool\)
```cj
public func present(capture!: Bool = false): Unit
```
Trigger a double-buffer swap to screen

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capture|Bool|Whether to capture a screenshot (default false)|

### func release\(\)
```cj
public func release(): Bool
```
Shutdown the renderer and release resources

### func renderAsync\(Scene,Camera\)
```cj
public func renderAsync(scene: Scene, camera: Camera): Unit
```
Render one frame asynchronously: post the whole frame to the command thread and return immediately

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene||
|camera|Camera||

### func renderToView\(Scene,Camera,Option<UInt16>,Option<\(Int32,Int32,Int32,Int32\)>,Option<UInt32>\)
```cj
public func renderToView(scene: Scene, camera: Camera, viewId!: Option < UInt16 >= None, viewport!: Option <(Int32, Int32, Int32, Int32) >= None, clearColor!: Option < UInt32 >= None): Unit
```


Parameter: 

|Name|Type|Describe|
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
Render scene (delegated to the command thread via the command executor)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Scene to rendercamera Render camera|
|camera|Camera||

### func runOnRenderThread\(\(\)\->Unit\)
```cj
public func runOnRenderThread(cmd:() -> Unit): Unit
```
Public thread serialization entry: routes an arbitrary closure onto the command thread

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cmd|()->Unit|The closure to execute|

### func setClearColor\(Color,Float64\)
```cj
public func setClearColor(color: Color, alpha!: Float64 = 1.0): Unit
```
Set clear color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Clear coloralpha Alpha value, default 1.0|
|alpha|Float64||

### func setDebugText\(Bool\)
```cj
public func setDebugText(enabled: Bool): Unit
```
Enables/disables the debug text overlay (semantic wrapper, exposing no backend flag values)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|enabled|Bool|true to enable the debug text overlay, false to disable|

### func setDebug\(UInt32\)
```cj
public func setDebug(debug: UInt32): Unit
```
Set backend debug flags (e.g. wireframe), routed through the command thread

Parameter: 

|Name|Type|Describe|
|---|---|---|
|debug|UInt32|Debug flag bit combination|

### func setRenderTarget\(IRenderTarget,Int64,Int64\)
```cj
public func setRenderTarget(renderTarget: IRenderTarget, cubeFace: Int64, mipLevel: Int64): Unit
```
Set render target (IRenderer interface implementation, CubeCamera 6-face render target switching)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderTarget|IRenderTarget|Render targetcubeFace Cube face index (0~5)mipLevel Mipmap level|
|cubeFace|Int64||
|mipLevel|Int64||

### func setShadowType\(Int64\)
```cj
public func setShadowType(value: Int64): Unit
```
Set shadow type (delegates to the backend implementation)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|Shadow type value|

### func setSize\(Int32,Int32\)
```cj
public func setSize(width: Int32, height: Int32): Unit
```
Set renderer size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int32|Logical width in pixelsheight Logical height in pixels|
|height|Int32||

### func setWireframe\(Bool\)
```cj
public func setWireframe(enabled: Bool): Unit
```
Enables/disables wireframe debug mode (semantic wrapper, exposing no backend flag values)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|enabled|Bool|true to enable wireframe, false to disable|

### func syncFrame\(\)
```cj
public func syncFrame(): Unit
```
Wait until all posted commands (including a pending async frame) have executed

