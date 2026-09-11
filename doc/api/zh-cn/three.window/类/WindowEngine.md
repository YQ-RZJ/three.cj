# 类
## class WindowEngine
```cj
public open class WindowEngine
```
窗口引擎 v2（对齐 RGF 窗口模式）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>窗口泵线程主循环（每个窗口实例一条用户态线程，读自己的事件队列）：
onInit()                          // 窗口创建后（初始化渲染器/场景）
while (!closeRequested):
drainQueue → 构建固定快照      // 本循环全部事件 → InputSnapshot
bindOnFrame?(dt) / onFrame(dt) // 用户逻辑/渲染——读快照（值固定）
snapshot.resetForNextFrame()   // 循环末重置（下一循环重新收集）
onClose(); onDestroy()</p>

### func addInputProvider\(InputProvider\)
```cj
public func addInputProvider(provider: InputProvider): Unit
```
添加输入提供者

参数: 

|名称|类型|描述|
|---|---|---|
|provider|InputProvider|输入提供者实例|

### func bindRenderer\(\(\(\)\->Unit\)\->Unit\)
```cj
public func bindRenderer(execBgfx:(() -> Unit) -> Unit): Unit
```
绑定渲染器的 execBgfx 提交方法（供 Gui 路由 bgfx 后端调用）

参数: 

|名称|类型|描述|
|---|---|---|
|execBgfx|(()->Unit)->Unit|渲染器的 execBgfx 方法引用|

### func getAspectRatio\(\)
```cj
public func getAspectRatio():(Float32, Float32)
```
获取窗口宽高比约束

返回: 

- (最小宽高比, 最大宽高比)

### func getDisplayBounds\(UInt32\)
```cj
public func getDisplayBounds(displayID: UInt32): Option < SDL_Rect >
```
获取显示器边界矩形

参数: 

|名称|类型|描述|
|---|---|---|
|displayID|UInt32|显示器 ID|

返回: 

- 边界矩形；查询失败返回 None

### func getDisplayName\(UInt32\)
```cj
public func getDisplayName(displayID: UInt32): String
```
获取显示器名称

参数: 

|名称|类型|描述|
|---|---|---|
|displayID|UInt32|显示器 ID|

返回: 

- 显示器名称；查询失败返回空字符串

### func getDisplayScale\(\)
```cj
public func getDisplayScale(): Float32
```
获取窗口显示缩放比例（HiDPI）

返回: 

- 显示缩放比例

### func getDisplays\(\)
```cj
public func getDisplays(): ArrayList < UInt32 >
```
获取所有显示器 ID 列表

返回: 

- 显示器 ID 列表

### func getDpiScale\(\)
```cj
public func getDpiScale(): Float64
```
获取当前 DPI 缩放值

返回: 

- 当前像素比

### func getDrawableSize\(\)
```cj
public func getDrawableSize():(Int32, Int32)
```
获取窗口像素尺寸（物理后备缓冲尺寸）

返回: 

- (物理宽度, 物理高度)

### func getHeight\(\)
```cj
public func getHeight(): Int32
```
窗口高度（像素）

### func getKeyboardGrab\(\)
```cj
public func getKeyboardGrab(): Bool
```
获取窗口键盘捕获状态

返回: 

- 是否处于键盘捕获状态

### func getMaximumSize\(\)
```cj
public func getMaximumSize():(Int32, Int32)
```
获取窗口最大尺寸

返回: 

- (最大宽度, 最大高度)

### func getMinimumSize\(\)
```cj
public func getMinimumSize():(Int32, Int32)
```
获取窗口最小尺寸

返回: 

- (最小宽度, 最小高度)

### func getMouseGrab\(\)
```cj
public func getMouseGrab(): Bool
```
获取窗口鼠标捕获状态

返回: 

- 是否处于鼠标捕获状态

### func getNativeWindowHandle\(\)
```cj
public func getNativeWindowHandle(): UIntNative
```
获取跨平台原生窗口句柄（nwh），供渲染引擎绑定窗口

返回: 

- 原生窗口句柄

### func getOpacity\(\)
```cj
public func getOpacity(): Float32
```
获取窗口透明度

返回: 

- 透明度（0.0-1.0）

### func getPixelDensity\(\)
```cj
public func getPixelDensity(): Float32
```
获取窗口像素密度（HiDPI 缩放因子）

返回: 

- 像素密度

### func getPixelFormat\(\)
```cj
public func getPixelFormat(): UInt32
```
获取窗口像素格式

返回: 

- 像素格式（SDL_PixelFormat 枚举值）

### func getPixelRatio\(\)
```cj
public func getPixelRatio(): Float32
```
获取窗口像素比（物理像素 / 逻辑像素）

返回: 

- 像素比；查询失败或无窗口时返回 1.0

### func getPosition\(\)
```cj
public func getPosition():(Int32, Int32)
```
获取窗口位置（屏幕坐标）

返回: 

- (x, y) 屏幕坐标

### func getPrimaryDisplay\(\)
```cj
public func getPrimaryDisplay(): UInt32
```
获取主显示器 ID

返回: 

- 主显示器 ID

### func getProvider\(\)where T <: InputProvider
```cj
public func getProvider < T >(): Option < T > where T <: InputProvider
```
获取指定类型的输入提供者

返回: 

- 第一个匹配的提供者；未找到返回 None

### func getProviders\(\)
```cj
public func getProviders(): ArrayList < InputProvider >
```
获取所有输入提供者

返回: 

- 输入提供者列表

### func getRelativeMouseMode\(\)
```cj
public func getRelativeMouseMode(): Bool
```
查询当前是否处于相对鼠标模式

返回: 

- 是否处于相对鼠标模式

### func getSDLWindow\(\)
```cj
public func getSDLWindow(): SDL_Window
```
获取 SDL 窗口指针（供 ImGui SDL3 后端初始化使用）

返回: 

- SDL 窗口指针

### func getSafeArea\(\)
```cj
public func getSafeArea(): Option < SDL_Rect >
```
获取窗口安全区域

返回: 

- 安全区域矩形；查询失败返回 None

### func getSurface\(\)
```cj
public func getSurface(): SDL_Surface
```
获取窗口表面（用于软件渲染）

返回: 

- 窗口表面

### func getTitle\(\)
```cj
public func getTitle(): String
```
窗口标题

### func getWidth\(\)
```cj
public func getWidth(): Int32
```
窗口宽度（像素）

### func hideCursor\(\)
```cj
public func hideCursor(): Bool
```
隐藏光标

返回: 

- 是否隐藏成功

### func hide\(\)
```cj
public func hide(): Bool
```
隐藏窗口

返回: 

- 是否成功

### func init\(\)
```cj
public init()
```
构造窗口引擎（尚未创建窗口，需调用 start）

### func isCloseRequested\(\)
```cj
public func isCloseRequested(): Bool
```
用户是否请求关闭窗口（方法形式，等价于 closeRequested）

返回: 

- 是否已请求关闭

### func isCursorVisible\(\)
```cj
public func isCursorVisible(): Bool
```
查询光标当前是否可见

返回: 

- 光标是否可见

### func maximize\(\)
```cj
public func maximize(): Bool
```
最大化窗口

返回: 

- 是否成功

### func minimize\(\)
```cj
public func minimize(): Bool
```
最小化窗口

返回: 

- 是否成功

### func onClose\(\)
```cj
public open func onClose(): Unit
```
关闭前调用（清理逻辑/渲染器）

### func onDestroy\(\)
```cj
public open func onDestroy(): Unit
```
销毁后调用

### func onFrame\(Float64\)
```cj
public open func onFrame(dt: Float64): Unit
```
每循环调用（读固定快照——逻辑+渲染）

参数: 

|名称|类型|描述|
|---|---|---|
|dt|Float64|距上循环的秒数|

### func onInit\(\)
```cj
public open func onInit(): Unit
```
窗口创建后调用（初始化渲染器/场景；可读 getNativeWindowHandle/getWidth/getHeight）

### func onResize\(Int32,Int32\)
```cj
public open func onResize(width: Int32, height: Int32): Unit
```
窗口尺寸变化后调用（泵线程；getWidth/getHeight 已更新为新值）

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int32||
|height|Int32||

### func raise\(\)
```cj
public func raise(): Bool
```
将窗口置顶

返回: 

- 是否成功

### func removeInputProvider\(InputProvider\)
```cj
public func removeInputProvider(provider: InputProvider): Bool
```
移除输入提供者

参数: 

|名称|类型|描述|
|---|---|---|
|provider|InputProvider|输入提供者实例|

返回: 

- 是否成功移除

### func requestClose\(\)
```cj
public func requestClose(): Unit
```
请求关闭窗口

### func restore\(\)
```cj
public func restore(): Bool
```
恢复窗口（从最大化/最小化恢复）

返回: 

- 是否成功

### func setAlwaysOnTop\(Bool\)
```cj
public func setAlwaysOnTop(onTop: Bool): Bool
```
设置窗口是否置顶

参数: 

|名称|类型|描述|
|---|---|---|
|onTop|Bool|true=置顶，false=取消置顶|

返回: 

- 是否成功

### func setAspectRatio\(Float32,Float32\)
```cj
public func setAspectRatio(minAspect: Float32, maxAspect: Float32): Bool
```
设置窗口宽高比约束

参数: 

|名称|类型|描述|
|---|---|---|
|minAspect|Float32|最小宽高比maxAspect 最大宽高比|
|maxAspect|Float32||

返回: 

- 是否成功

### func setBordered\(Bool\)
```cj
public func setBordered(bordered: Bool): Bool
```
设置窗口是否有边框

参数: 

|名称|类型|描述|
|---|---|---|
|bordered|Bool|true=有边框，false=无边框|

返回: 

- 是否成功

### func setDpiAutoDetect\(Bool\)
```cj
public func setDpiAutoDetect(autoDetect: Bool): Unit
```
设置是否自动检测 DPI

参数: 

|名称|类型|描述|
|---|---|---|
|autoDetect|Bool|true 时通过 SDL 自动检测；false 时强制使用 setDpiScale 指定的值|

### func setDpiScale\(Float64\)
```cj
public func setDpiScale(scale: Float64): Unit
```
设置手动 DPI 缩放值

参数: 

|名称|类型|描述|
|---|---|---|
|scale|Float64|像素比（必须 > 0）；设置后会自动关闭自动检测|

### func setFocusable\(Bool\)
```cj
public func setFocusable(focusable: Bool): Bool
```
设置窗口是否可聚焦

参数: 

|名称|类型|描述|
|---|---|---|
|focusable|Bool|true=可聚焦，false=不可聚焦|

返回: 

- 是否成功

### func setFullscreen\(Bool\)
```cj
public func setFullscreen(fullscreen: Bool): Bool
```
设置窗口是否全屏（运行时切换）

参数: 

|名称|类型|描述|
|---|---|---|
|fullscreen|Bool|true=进入全屏，false=退出全屏|

返回: 

- 是否成功

### func setKeyboardGrab\(Bool\)
```cj
public func setKeyboardGrab(grabbed: Bool): Bool
```
设置键盘是否捕获到窗口

参数: 

|名称|类型|描述|
|---|---|---|
|grabbed|Bool|true=捕获，false=释放|

返回: 

- 是否成功

### func setMaximumSize\(Int32,Int32\)
```cj
public func setMaximumSize(maxW: Int32, maxH: Int32): Bool
```
设置窗口最大尺寸（resize 上限）

参数: 

|名称|类型|描述|
|---|---|---|
|maxW|Int32|最大宽度（像素）maxH 最大高度（像素）|
|maxH|Int32||

返回: 

- 是否成功

### func setMinimumSize\(Int32,Int32\)
```cj
public func setMinimumSize(minW: Int32, minH: Int32): Bool
```
设置窗口最小尺寸（resize 下限）

参数: 

|名称|类型|描述|
|---|---|---|
|minW|Int32|最小宽度（像素）minH 最小高度（像素）|
|minH|Int32||

返回: 

- 是否成功

### func setModal\(Bool\)
```cj
public func setModal(modal: Bool): Bool
```
设置窗口是否模态

参数: 

|名称|类型|描述|
|---|---|---|
|modal|Bool|true=模态，false=非模态|

返回: 

- 是否成功

### func setMouseGrab\(Bool\)
```cj
public func setMouseGrab(grabbed: Bool): Bool
```
设置鼠标是否捕获到窗口（隐藏并锁定鼠标）

参数: 

|名称|类型|描述|
|---|---|---|
|grabbed|Bool|true=捕获，false=释放|

返回: 

- 是否成功

### func setOpacity\(Float32\)
```cj
public func setOpacity(opacity: Float32): Bool
```
设置窗口透明度

参数: 

|名称|类型|描述|
|---|---|---|
|opacity|Float32|透明度（0.0=完全透明，1.0=不透明）|

返回: 

- 是否成功

### func setPosition\(Int32,Int32\)
```cj
public func setPosition(x: Int32, y: Int32): Bool
```
设置窗口位置（屏幕坐标）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Int32|屏幕 X 坐标y 屏幕 Y 坐标|
|y|Int32||

返回: 

- 是否成功

### func setRelativeMouseMode\(Bool\)
```cj
public func setRelativeMouseMode(enabled: Bool): Bool
```
设置相对鼠标模式（捕获鼠标，用于 FPS 视角）

参数: 

|名称|类型|描述|
|---|---|---|
|enabled|Bool|是否启用|

返回: 

- 是否设置成功

### func setResizable\(Bool\)
```cj
public func setResizable(resizable: Bool): Unit
```
设置窗口是否可由用户调整大小

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>创建后也可用。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|resizable|Bool|true=可调节尺寸，false=锁定尺寸（不可调节）|

### func setSize\(Int32,Int32\)
```cj
public func setSize(width: Int32, height: Int32): Unit
```
调整窗口尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int32|新宽度height 新高度|
|height|Int32||

### func setSystemCursor\(SystemCursor\)
```cj
public func setSystemCursor(cursor: SystemCursor): Bool
```
设置系统光标

参数: 

|名称|类型|描述|
|---|---|---|
|cursor|SystemCursor|光标类型（SystemCursor）|

返回: 

- 是否成功

### func setTitle\(String\)
```cj
public func setTitle(title: String): Unit
```
设置窗口标题

参数: 

|名称|类型|描述|
|---|---|---|
|title|String|新标题|

### func showCursor\(\)
```cj
public func showCursor(): Bool
```
显示光标

返回: 

- 是否显示成功

### func show\(\)
```cj
public func show(): Bool
```
显示窗口

返回: 

- 是否成功

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
关闭窗口引擎

### func start\(String,Int32,Int32,WindowConfig\)
```cj
public func start(title!: String, width!: Int32, height!: Int32, config!: WindowConfig = WindowConfig()): Bool
```
启动窗口引擎：SDL 初始化 + 创建窗口 + 启动窗口泵线程（异步返回）

参数: 

|名称|类型|描述|
|---|---|---|
|title|String|窗口标题width 窗口宽度（像素）height 窗口高度（像素）config 窗口创建配置（是否可 resize、是否全屏等），默认 WindowConfig()（resizable 开启）|
|width|Int32||
|height|Int32||
|config|WindowConfig||

返回: 

- 是否成功

### func updateSize\(Int32,Int32\)
```cj
public func updateSize(width: Int32, height: Int32): Unit
```
更新窗口逻辑尺寸（跨平台接口）

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int32|新宽度（像素）height 新高度（像素）|
|height|Int32||

### func useGui\(\)
```cj
public func useGui(): Unit
```
启用 Gui（ImGui）。须在 start() 之前调用。

### func wait\(\)
```cj
public func wait(): Unit
```
阻塞等待窗口关闭（窗口泵线程结束后返回）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>窗口关闭途径：用户点标题栏 X / Alt+F4、onFrame 内调 requestClose()、
外部调 shutdown()。</p>

### func warpMouseInWindow\(Float32,Float32\)
```cj
public func warpMouseInWindow(x: Float32, y: Float32): Unit
```
将鼠标移动到窗口内指定位置（窗口坐标）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32|窗口内 X 坐标y 窗口内 Y 坐标|
|y|Float32||

### prop bindOnClose: Option <\(\) \-> Unit >
```cj
public mut prop bindOnClose: Option <() -> Unit >
```
绑定式事件 - 关闭前

### prop bindOnDestroy: Option <\(\) \-> Unit >
```cj
public mut prop bindOnDestroy: Option <() -> Unit >
```
绑定式事件 - 销毁后

### prop bindOnFrame: Option <\(Float64\) \-> Unit >
```cj
public mut prop bindOnFrame: Option <(Float64) -> Unit >
```
绑定式事件 - 每循环（优先于覆写 onFrame）

### prop bindOnInit: Option <\(\) \-> Unit >
```cj
public mut prop bindOnInit: Option <() -> Unit >
```
绑定式事件 - 窗口创建后

### prop bindOnResize: Option <\(Int32, Int32\) \-> Unit >
```cj
public mut prop bindOnResize: Option <(Int32, Int32) -> Unit >
```
绑定式事件 - 窗口尺寸变化后（优先于覆写 onResize）

### prop closeRequested: Bool
```cj
public prop closeRequested: Bool
```
用户是否请求关闭窗口（读快照——固定）

### prop gui: Option < UiContext >
```cj
public prop gui: Option < UiContext >
```
获取 Gui 上下文（启用后由 _windowLoop 创建）

### prop initialized: Bool
```cj
public prop initialized: Bool
```
窗口是否已初始化

