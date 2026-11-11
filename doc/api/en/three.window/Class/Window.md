# Class
## class Window
```cj
public class Window <: IReleasable
```
Declarative window (facade composing WindowEngine)

### func close\(\)
```cj
public func close(): Unit
```
Requests the window to close (idempotent; async; equivalent to the user clicking close)

### func getEngine\(\)
```cj
public func getEngine(): WindowEngine
```
Gets the internal WindowEngine (advanced use: input providers, window
operation APIs, targetFrameRate, etc.; capabilities not covered by the declarative
API pass through here)

### func init\(String,Int32,Int32,WindowConfig,\(Window\)\->Unit\)
```cj
public init(title!: String, width!: Int32, height!: Int32, config!: WindowConfig = WindowConfig(), build!:(Window) -> Unit)
```
Declarative construction: parameters + trailing closure in one step

Parameter: 

|Name|Type|Describe|
|---|---|---|
|title|String|Window titlewidth Window width (logical pixels)height Window height (logical pixels)config Window creation config (default WindowConfig())build Declaration closure (executed immediately at construction, before the window exists)|
|width|Int32||
|height|Int32||
|config|WindowConfig||
|build|(Window)->Unit||

### func onClose\(\(\)\->Unit\)
```cj
public func onClose(handler:() -> Unit): Window
```
Declares the pre-close callback (may be declared multiple times, run in order; before the renderer release)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handler|()->Unit||

### func onCtxtInit\(\(\)\->Unit\)
```cj
public func onCtxtInit(handler:() -> Unit): Window
```
Declares the post-Gui-init callback (may be declared multiple times, run in order)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handler|()->Unit||

### func onDestroy\(\(\)\->Unit\)
```cj
public func onDestroy(handler:() -> Unit): Window
```
Declares the post-destroy callback (may be declared multiple times, run in order)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handler|()->Unit||

### func onFrame\(\(Float64\)\->Unit\)
```cj
public func onFrame(handler:(Float64) -> Unit): Window
```
Declares a frame callback (may be declared multiple times, run in order; called with real dt each frame)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handler|(Float64)->Unit||

### func onInit\(\(\)\->Unit\)
```cj
public func onInit(handler:() -> Unit): Window
```
Declares the post-creation callback (may be declared multiple times, run in order)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handler|()->Unit||

### func onResize\(\(Int32,Int32\)\->Unit\)
```cj
public func onResize(handler:(Int32, Int32) -> Unit): Window
```
Declares a resize callback (may be declared multiple times, run in order; at most once per frame during interactive resizing)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handler|(Int32,Int32)->Unit||

### func release\(\)
```cj
public func release(): Bool
```
IReleasable: request close and join the pump thread (idempotent)

### func renderWith\(ThreeRenderer\)
```cj
public func renderWith(renderer: ThreeRenderer): Window
```
Binds the renderer (optional)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer||

### func run\(\)
```cj
public func run(): Unit
```
One-step convenience: show() + wait() (idempotent)

### func show\(\)
```cj
public func show(): Bool
```
Starts the window (idempotent: returns true immediately if already started)

### func ui\(\(\)\->Unit\)
```cj
public func ui(body:() -> Unit): Window
```
Declares the UI body (executed every frame)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|body|()->Unit||

### func wait\(\)
```cj
public func wait(): Unit
```
Blocks until the window closes (idempotent: repeated calls return immediately)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Must be called on the main thread (otherwise main exiting kills the spawn pump thread).</p>

### prop height: Int32
```cj
public prop height: Int32
```
Window height (logical pixels)

### prop isCloseRequested: Bool
```cj
public prop isCloseRequested: Bool
```
Whether a close has been requested (reads the fixed snapshot)

### prop started: Bool
```cj
public prop started: Bool
```
Whether the window has been started (true after a successful show)

### prop width: Int32
```cj
public prop width: Int32
```
Window width (logical pixels)

