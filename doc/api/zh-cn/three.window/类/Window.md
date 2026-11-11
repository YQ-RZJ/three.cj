# 类
## class Window
```cj
public class Window <: IReleasable
```
声明式窗口（组合 WindowEngine 的门面）

### func close\(\)
```cj
public func close(): Unit
```
请求关闭窗口（幂等；异步，等价于用户点关闭按钮）

### func getEngine\(\)
```cj
public func getEngine(): WindowEngine
```
获取内部 WindowEngine（高级用法：输入 Provider、窗口操作 API、
targetFrameRate 等完整能力；声明式未覆盖的能力经此透传）

### func init\(String,Int32,Int32,WindowConfig,\(Window\)\->Unit\)
```cj
public init(title!: String, width!: Int32, height!: Int32, config!: WindowConfig = WindowConfig(), build!:(Window) -> Unit)
```
声明式构造：参数 + 尾随闭包一步完成

参数: 

|名称|类型|描述|
|---|---|---|
|title|String|窗口标题width 窗口宽度（逻辑像素）height 窗口高度（逻辑像素）config 窗口创建配置（默认 WindowConfig()）build 声明闭包（在构造时立即执行，此时窗口尚未创建）|
|width|Int32||
|height|Int32||
|config|WindowConfig||
|build|(Window)->Unit||

### func onClose\(\(\)\->Unit\)
```cj
public func onClose(handler:() -> Unit): Window
```
声明关闭前回调（可多次声明，按序执行；在渲染器 release 之前）

参数: 

|名称|类型|描述|
|---|---|---|
|handler|()->Unit||

### func onCtxtInit\(\(\)\->Unit\)
```cj
public func onCtxtInit(handler:() -> Unit): Window
```
声明 Gui 上下文初始化完成后的回调（可多次声明，按序执行）

参数: 

|名称|类型|描述|
|---|---|---|
|handler|()->Unit||

### func onDestroy\(\(\)\->Unit\)
```cj
public func onDestroy(handler:() -> Unit): Window
```
声明销毁后回调（可多次声明，按序执行）

参数: 

|名称|类型|描述|
|---|---|---|
|handler|()->Unit||

### func onFrame\(\(Float64\)\->Unit\)
```cj
public func onFrame(handler:(Float64) -> Unit): Window
```
声明帧回调（可多次声明，按序执行；每帧以真实 dt 调用）

参数: 

|名称|类型|描述|
|---|---|---|
|handler|(Float64)->Unit||

### func onInit\(\(\)\->Unit\)
```cj
public func onInit(handler:() -> Unit): Window
```
声明窗口创建后回调（可多次声明，按序执行）

参数: 

|名称|类型|描述|
|---|---|---|
|handler|()->Unit||

### func onResize\(\(Int32,Int32\)\->Unit\)
```cj
public func onResize(handler:(Int32, Int32) -> Unit): Window
```
声明尺寸变化回调（可多次声明，按序执行；拖拽缩放每帧最多一次）

参数: 

|名称|类型|描述|
|---|---|---|
|handler|(Int32,Int32)->Unit||

### func release\(\)
```cj
public func release(): Bool
```
IReleasable：请求关闭并等待泵线程结束（幂等）

### func renderWith\(ThreeRenderer\)
```cj
public func renderWith(renderer: ThreeRenderer): Window
```
绑定渲染器（可选）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer||

### func run\(\)
```cj
public func run(): Unit
```
便捷一步启动：show() + wait()（幂等）

### func show\(\)
```cj
public func show(): Bool
```
启动窗口（幂等：已启动时直接返回 true）

### func ui\(\(\)\->Unit\)
```cj
public func ui(body:() -> Unit): Window
```
声明 UI 体（每帧自动执行）

参数: 

|名称|类型|描述|
|---|---|---|
|body|()->Unit||

### func wait\(\)
```cj
public func wait(): Unit
```
阻塞等待窗口关闭（幂等：重复调用直接返回）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>主线程必须调用（否则 main 退出会杀死 spawn 泵线程）。</p>

### prop height: Int32
```cj
public prop height: Int32
```
窗口高度（逻辑像素）

### prop isCloseRequested: Bool
```cj
public prop isCloseRequested: Bool
```
是否已请求关闭（读固定快照）

### prop started: Bool
```cj
public prop started: Bool
```
窗口是否已启动（show 成功后为 true）

### prop width: Int32
```cj
public prop width: Int32
```
窗口宽度（逻辑像素）

