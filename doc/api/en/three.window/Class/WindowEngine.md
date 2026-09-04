# Class
## class WindowEngine
```cj
public open class WindowEngine
```
Window engine v2 (aligned with the RGF window model)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Window pump thread main loop (one user-space thread per window instance,
reading its own event queue):
onInit()                          // after window creation (init renderer/scene)
while (!closeRequested):
drainQueue -> build fixed snapshot  // all events this loop -> InputSnapshot
bindOnFrame?(dt) / onFrame(dt)     // user logic/rendering - reads snapshot
snapshot.resetForNextFrame()       // reset at loop end (re-collect next loop)
onClose(); onDestroy()</p>

### func addInputProvider\(InputProvider\)
```cj
public func addInputProvider(provider: InputProvider): Unit
```
Adds an input provider

Parameter: 

|Name|Type|Describe|
|---|---|---|
|provider|InputProvider|The input provider instance|

### func getAspectRatio\(\)
```cj
public func getAspectRatio():(Float32, Float32)
```
Gets the window aspect-ratio constraint

Return: 

- (minimum aspect ratio, maximum aspect ratio)

### func getDisplayBounds\(UInt32\)
```cj
public func getDisplayBounds(displayID: UInt32): Option < SDL_Rect >
```
Gets the display bounds rectangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|displayID|UInt32|Display ID|

Return: 

- The bounds rectangle, or None if the query failed

### func getDisplayName\(UInt32\)
```cj
public func getDisplayName(displayID: UInt32): String
```
Gets the display name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|displayID|UInt32|Display ID|

Return: 

- The display name, or an empty string if the query failed

### func getDisplayScale\(\)
```cj
public func getDisplayScale(): Float32
```
Gets the window display scale (HiDPI)

Return: 

- The display scale

### func getDisplays\(\)
```cj
public func getDisplays(): ArrayList < UInt32 >
```
Gets the list of all display IDs

Return: 

- The list of display IDs

### func getHeight\(\)
```cj
public func getHeight(): Int32
```
Window height in pixels

### func getKeyboardGrab\(\)
```cj
public func getKeyboardGrab(): Bool
```
Gets the window keyboard-grab state

Return: 

- Whether the keyboard is currently grabbed

### func getMaximumSize\(\)
```cj
public func getMaximumSize():(Int32, Int32)
```
Gets the window maximum size

Return: 

- (maximum width, maximum height)

### func getMinimumSize\(\)
```cj
public func getMinimumSize():(Int32, Int32)
```
Gets the window minimum size

Return: 

- (minimum width, minimum height)

### func getMouseGrab\(\)
```cj
public func getMouseGrab(): Bool
```
Gets the window mouse-grab state

Return: 

- Whether the mouse is currently grabbed

### func getNativeWindowHandle\(\)
```cj
public func getNativeWindowHandle(): UIntNative
```
Gets the cross-platform native window handle (nwh) for binding the
window to a renderer

Return: 

- The native window handle

### func getOpacity\(\)
```cj
public func getOpacity(): Float32
```
Gets the window opacity

Return: 

- Opacity (0.0-1.0)

### func getPixelDensity\(\)
```cj
public func getPixelDensity(): Float32
```
Gets the window pixel density (HiDPI scale factor)

Return: 

- The pixel density

### func getPixelFormat\(\)
```cj
public func getPixelFormat(): UInt32
```
Gets the window pixel format

Return: 

- The pixel format (SDL_PixelFormat enum value)

### func getPosition\(\)
```cj
public func getPosition():(Int32, Int32)
```
Gets the window position (screen coordinates)

Return: 

- (x, y) screen coordinates

### func getPrimaryDisplay\(\)
```cj
public func getPrimaryDisplay(): UInt32
```
Gets the primary display ID

Return: 

- The primary display ID

### func getProvider\(\)where T <: InputProvider
```cj
public func getProvider < T >(): Option < T > where T <: InputProvider
```
Gets the first input provider of the specified type

Return: 

- The first matching provider, or None if not found

### func getProviders\(\)
```cj
public func getProviders(): ArrayList < InputProvider >
```
Gets all input providers

Return: 

- The list of input providers

### func getRelativeMouseMode\(\)
```cj
public func getRelativeMouseMode(): Bool
```
Checks whether the window is currently in relative mouse mode

Return: 

- Whether the window is in relative mouse mode

### func getSafeArea\(\)
```cj
public func getSafeArea(): Option < SDL_Rect >
```
Gets the window safe area

Return: 

- The safe-area rectangle, or None if the query failed

### func getSurface\(\)
```cj
public func getSurface(): SDL_Surface
```
Gets the window surface (for software rendering)

Return: 

- The window surface

### func getTitle\(\)
```cj
public func getTitle(): String
```
Window title

### func getWidth\(\)
```cj
public func getWidth(): Int32
```
Window width in pixels

### func hideCursor\(\)
```cj
public func hideCursor(): Bool
```
Hides the cursor

Return: 

- Whether the cursor was hidden successfully

### func hide\(\)
```cj
public func hide(): Bool
```
Hides the window

Return: 

- Whether the operation succeeded

### func init\(\)
```cj
public init()
```
Constructs a window engine (no window created yet; call start first)

### func isCloseRequested\(\)
```cj
public func isCloseRequested(): Bool
```
Whether the user requested to close the window (method form, equivalent
to closeRequested)

Return: 

- Whether a close has been requested

### func isCursorVisible\(\)
```cj
public func isCursorVisible(): Bool
```
Checks whether the cursor is currently visible

Return: 

- Whether the cursor is visible

### func maximize\(\)
```cj
public func maximize(): Bool
```
Maximizes the window

Return: 

- Whether the operation succeeded

### func minimize\(\)
```cj
public func minimize(): Bool
```
Minimizes the window

Return: 

- Whether the operation succeeded

### func onClose\(\)
```cj
public open func onClose(): Unit
```
Called before the window closes (clean up logic/renderer)

### func onDestroy\(\)
```cj
public open func onDestroy(): Unit
```
Called after the window is destroyed

### func onFrame\(Float64\)
```cj
public open func onFrame(dt: Float64): Unit
```
Called every loop (reads the fixed snapshot - logic + rendering)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dt|Float64|Seconds elapsed since the previous loop|

### func onInit\(\)
```cj
public open func onInit(): Unit
```
Called after the window is created (init renderer/scene; can read
getNativeWindowHandle/getWidth/getHeight)

### func raise\(\)
```cj
public func raise(): Bool
```
Raises the window to the top

Return: 

- Whether the operation succeeded

### func removeInputProvider\(InputProvider\)
```cj
public func removeInputProvider(provider: InputProvider): Bool
```
Removes an input provider

Parameter: 

|Name|Type|Describe|
|---|---|---|
|provider|InputProvider|The input provider instance|

Return: 

- Whether the provider was successfully removed

### func requestClose\(\)
```cj
public func requestClose(): Unit
```
Requests the window to close

### func restore\(\)
```cj
public func restore(): Bool
```
Restores the window (from maximized/minimized)

Return: 

- Whether the operation succeeded

### func setAlwaysOnTop\(Bool\)
```cj
public func setAlwaysOnTop(onTop: Bool): Bool
```
Sets whether the window stays on top

Parameter: 

|Name|Type|Describe|
|---|---|---|
|onTop|Bool|true = always on top, false = cancel|

Return: 

- Whether the operation succeeded

### func setAspectRatio\(Float32,Float32\)
```cj
public func setAspectRatio(minAspect: Float32, maxAspect: Float32): Bool
```
Sets the window aspect-ratio constraint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minAspect|Float32|Minimum aspect ratiomaxAspect Maximum aspect ratio|
|maxAspect|Float32||

Return: 

- Whether the operation succeeded

### func setBordered\(Bool\)
```cj
public func setBordered(bordered: Bool): Bool
```
Sets whether the window has a border

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bordered|Bool|true = bordered, false = borderless|

Return: 

- Whether the operation succeeded

### func setFocusable\(Bool\)
```cj
public func setFocusable(focusable: Bool): Bool
```
Sets whether the window is focusable

Parameter: 

|Name|Type|Describe|
|---|---|---|
|focusable|Bool|true = focusable, false = not focusable|

Return: 

- Whether the operation succeeded

### func setFullscreen\(Bool\)
```cj
public func setFullscreen(fullscreen: Bool): Bool
```
Sets whether the window is fullscreen (runtime toggle)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fullscreen|Bool|true = enter fullscreen, false = exit fullscreen|

Return: 

- Whether the operation succeeded

### func setKeyboardGrab\(Bool\)
```cj
public func setKeyboardGrab(grabbed: Bool): Bool
```
Sets whether the keyboard is grabbed by the window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|grabbed|Bool|true = grab, false = release|

Return: 

- Whether the operation succeeded

### func setMaximumSize\(Int32,Int32\)
```cj
public func setMaximumSize(maxW: Int32, maxH: Int32): Bool
```
Sets the window maximum size (resize upper bound)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|maxW|Int32|Maximum width in pixelsmaxH Maximum height in pixels|
|maxH|Int32||

Return: 

- Whether the operation succeeded

### func setMinimumSize\(Int32,Int32\)
```cj
public func setMinimumSize(minW: Int32, minH: Int32): Bool
```
Sets the window minimum size (resize lower bound)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minW|Int32|Minimum width in pixelsminH Minimum height in pixels|
|minH|Int32||

Return: 

- Whether the operation succeeded

### func setModal\(Bool\)
```cj
public func setModal(modal: Bool): Bool
```
Sets whether the window is modal

Parameter: 

|Name|Type|Describe|
|---|---|---|
|modal|Bool|true = modal, false = non-modal|

Return: 

- Whether the operation succeeded

### func setMouseGrab\(Bool\)
```cj
public func setMouseGrab(grabbed: Bool): Bool
```
Sets whether the mouse is grabbed by the window (hides and locks the mouse)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|grabbed|Bool|true = grab, false = release|

Return: 

- Whether the operation succeeded

### func setOpacity\(Float32\)
```cj
public func setOpacity(opacity: Float32): Bool
```
Sets the window opacity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|opacity|Float32|Opacity (0.0 = fully transparent, 1.0 = opaque)|

Return: 

- Whether the operation succeeded

### func setPosition\(Int32,Int32\)
```cj
public func setPosition(x: Int32, y: Int32): Bool
```
Sets the window position (screen coordinates)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Int32|Screen X coordinatey Screen Y coordinate|
|y|Int32||

Return: 

- Whether the operation succeeded

### func setRelativeMouseMode\(Bool\)
```cj
public func setRelativeMouseMode(enabled: Bool): Bool
```
Sets the relative mouse mode (captures the mouse, used for FPS-style views)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|enabled|Bool|Whether to enable it|

Return: 

- Whether the operation succeeded

### func setResizable\(Bool\)
```cj
public func setResizable(resizable: Bool): Unit
```
Sets whether the user can resize the window

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Also usable after creation.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|resizable|Bool|true = resizable, false = locked (not resizable)|

### func setSize\(Int32,Int32\)
```cj
public func setSize(width: Int32, height: Int32): Unit
```
Resizes the window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int32|New widthheight New height|
|height|Int32||

### func setSystemCursor\(SystemCursor\)
```cj
public func setSystemCursor(cursor: SystemCursor): Bool
```
Sets the system cursor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cursor|SystemCursor|Cursor type (SystemCursor)|

Return: 

- Whether the operation succeeded

### func setTitle\(String\)
```cj
public func setTitle(title: String): Unit
```
Sets the window title

Parameter: 

|Name|Type|Describe|
|---|---|---|
|title|String|New title|

### func showCursor\(\)
```cj
public func showCursor(): Bool
```
Shows the cursor

Return: 

- Whether the cursor was shown successfully

### func show\(\)
```cj
public func show(): Bool
```
Shows the window

Return: 

- Whether the operation succeeded

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
Shuts down the window engine

### func start\(String,Int32,Int32,WindowConfig\)
```cj
public func start(title!: String, width!: Int32, height!: Int32, config!: WindowConfig = WindowConfig()): Bool
```
Starts the window engine: SDL init + window creation + starts the window
pump thread (returns asynchronously)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|title|String|Window titlewidth Window width in pixelsheight Window height in pixelsconfig Window creation config (resizable, fullscreen, etc.); defaults toWindowConfig() (resizable enabled)|
|width|Int32||
|height|Int32||
|config|WindowConfig||

Return: 

- Whether the startup succeeded

### func updateSize\(Int32,Int32\)
```cj
public func updateSize(width: Int32, height: Int32): Unit
```
Updates the window logical size (cross-platform interface)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int32|New width in pixelsheight New height in pixels|
|height|Int32||

### func wait\(\)
```cj
public func wait(): Unit
```
Blocks until the window is closed (returns after the window pump
thread ends)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Ways to close: user clicks the title bar X / Alt+F4, calling
requestClose() inside onFrame, or an external shutdown() call.</p>

### func warpMouseInWindow\(Float32,Float32\)
```cj
public func warpMouseInWindow(x: Float32, y: Float32): Unit
```
Moves the mouse to the specified position within the window (window coordinates)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|The X coordinate inside the windowy The Y coordinate inside the window|
|y|Float32||

### prop bindOnClose: Option <\(\) \-> Unit >
```cj
public mut prop bindOnClose: Option <() -> Unit >
```
Bound event - before closing

### prop bindOnDestroy: Option <\(\) \-> Unit >
```cj
public mut prop bindOnDestroy: Option <() -> Unit >
```
Bound event - after destruction

### prop bindOnFrame: Option <\(Float64\) \-> Unit >
```cj
public mut prop bindOnFrame: Option <(Float64) -> Unit >
```
Bound event - every loop (takes precedence over the onFrame override)

### prop bindOnInit: Option <\(\) \-> Unit >
```cj
public mut prop bindOnInit: Option <() -> Unit >
```
Bound event - after window creation

### prop closeRequested: Bool
```cj
public prop closeRequested: Bool
```
Whether the user requested to close the window (reads the snapshot - fixed)

### prop initialized: Bool
```cj
public prop initialized: Bool
```
Whether the window has been initialized

