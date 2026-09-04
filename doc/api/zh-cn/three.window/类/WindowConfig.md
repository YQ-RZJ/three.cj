# 类
## class WindowConfig
```cj
public class WindowConfig
```
窗口创建配置

### func init\(\)
```cj
public init()
```
构造默认窗口配置

### var alwaysOnTop
```cj
public var alwaysOnTop: Bool = false
```
是否置顶（对应 SDL_WINDOW_ALWAYS_ON_TOP，默认 false）

### var borderless
```cj
public var borderless: Bool = false
```
是否无边框窗口（对应 SDL_WINDOW_BORDERLESS，默认 false）

### var fullscreen
```cj
public var fullscreen: Bool = false
```
是否全屏窗口（对应 SDL_WINDOW_FULLSCREEN，默认 false）

### var highPixelDensity
```cj
public var highPixelDensity: Bool = true
```
是否启用高像素密度 HiDPI（对应 SDL_WINDOW_HIGH_PIXEL_DENSITY，默认 true）

### var maxHeight
```cj
public var maxHeight: Int32 = 0
```
最大高度（0=不限制；创建后通过 SDL_SetWindowMaximumSize 应用）

### var maxWidth
```cj
public var maxWidth: Int32 = 0
```
最大宽度（0=不限制；创建后通过 SDL_SetWindowMaximumSize 应用）

### var minHeight
```cj
public var minHeight: Int32 = 0
```
最小高度（0=不限制；创建后通过 SDL_SetWindowMinimumSize 应用）

### var minWidth
```cj
public var minWidth: Int32 = 0
```
最小宽度（0=不限制；创建后通过 SDL_SetWindowMinimumSize 应用）

### var opacity
```cj
public var opacity: Float32 = 1.0
```
窗口透明度（0.0=完全透明，1.0=不透明；默认 1.0——创建后通过 SDL_SetWindowOpacity 应用）

### var resizable
```cj
public var resizable: Bool = true
```
是否可由用户调整大小（对应 SDL_WINDOW_RESIZABLE，默认 true——保持现有行为）

