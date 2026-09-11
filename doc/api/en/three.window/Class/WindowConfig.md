# Class
## class WindowConfig
```cj
public class WindowConfig
```
Window creation configuration

### func init\(\)
```cj
public init()
```
Constructs the default window configuration

### var alwaysOnTop
```cj
public var alwaysOnTop: Bool = false
```
Whether the window stays on top (SDL_WINDOW_ALWAYS_ON_TOP; defaults to false)

### var borderless
```cj
public var borderless: Bool = false
```
Whether the window is borderless (SDL_WINDOW_BORDERLESS; defaults to false)

### var enableGui
```cj
public var enableGui: Bool = false
```
Whether to enable Gui (defaults to false; when enabled, the engine
automatically manages the Gui context lifecycle)

### var fullscreen
```cj
public var fullscreen: Bool = false
```
Whether the window is fullscreen (SDL_WINDOW_FULLSCREEN; defaults to false)

### var highPixelDensity
```cj
public var highPixelDensity: Bool = true
```
Whether high pixel density (HiDPI) is enabled (SDL_WINDOW_HIGH_PIXEL_DENSITY; defaults to true)

### var maxHeight
```cj
public var maxHeight: Int32 = 0
```
Maximum height (0=unlimited; applied after creation via SDL_SetWindowMaximumSize)

### var maxWidth
```cj
public var maxWidth: Int32 = 0
```
Maximum width (0=unlimited; applied after creation via SDL_SetWindowMaximumSize)

### var minHeight
```cj
public var minHeight: Int32 = 0
```
Minimum height (0=unlimited; applied after creation via SDL_SetWindowMinimumSize)

### var minWidth
```cj
public var minWidth: Int32 = 0
```
Minimum width (0=unlimited; applied after creation via SDL_SetWindowMinimumSize)

### var opacity
```cj
public var opacity: Float32 = 1.0
```
Window opacity (0.0=fully transparent, 1.0=opaque; defaults to 1.0, applied after creation via SDL_SetWindowOpacity)

### var resizable
```cj
public var resizable: Bool = true
```
Whether the user can resize the window (SDL_WINDOW_RESIZABLE; defaults to true to keep existing behavior)

