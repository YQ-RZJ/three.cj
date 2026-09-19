# Class
## class UiViewport
```cj
public class UiViewport
```
ImGui viewport query

### func getCenter\(\)
```cj
public func getCenter(): ImVec2
```
Viewport center point

### func getDpiScale\(\)
```cj
public func getDpiScale(): Float32
```
DPI scale factor

### func getHandle\(\)
```cj
public func getHandle(): VoidPtr
```
Gets the underlying ImGuiViewport pointer

### func getMain\(\)
```cj
public static func getMain(): UiViewport
```
Gets the main viewport (usually the entire window)

### func getPos\(\)
```cj
public func getPos():(Float32, Float32)
```
Viewport position (screen coordinates)

### func getSize\(\)
```cj
public func getSize():(Float32, Float32)
```
Viewport size

### func getWindowViewport\(\)
```cj
public static func getWindowViewport(): UiViewport
```
Gets the viewport containing the current window

### func getWorkCenter\(\)
```cj
public func getWorkCenter(): ImVec2
```
Work area center point

### func getWorkPos\(\)
```cj
public func getWorkPos():(Float32, Float32)
```
Work area position (excludes system bars etc.)

### func getWorkSize\(\)
```cj
public func getWorkSize():(Float32, Float32)
```
Work area size

