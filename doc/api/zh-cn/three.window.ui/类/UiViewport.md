# 类
## class UiViewport
```cj
public class UiViewport
```
ImGui 视口查询

### func getCenter\(\)
```cj
public func getCenter(): ImVec2
```
视口中心点

### func getDpiScale\(\)
```cj
public func getDpiScale(): Float32
```
DPI 缩放因子

### func getHandle\(\)
```cj
public func getHandle(): CPointer < Unit >
```
获取底层 ImGuiViewport 指针

### func getMain\(\)
```cj
public static func getMain(): UiViewport
```
获取主视口（通常是整个窗口）

### func getPos\(\)
```cj
public func getPos():(Float32, Float32)
```
视口位置（屏幕坐标）

### func getSize\(\)
```cj
public func getSize():(Float32, Float32)
```
视口尺寸

### func getWindowViewport\(\)
```cj
public static func getWindowViewport(): UiViewport
```
获取当前窗口所在的视口

### func getWorkCenter\(\)
```cj
public func getWorkCenter(): ImVec2
```
工作区中心点

### func getWorkPos\(\)
```cj
public func getWorkPos():(Float32, Float32)
```
工作区位置（排除系统栏等）

### func getWorkSize\(\)
```cj
public func getWorkSize():(Float32, Float32)
```
工作区尺寸

### func init\(CPointer<Unit>\)
```cj
public init(vpPtr: CPointer < Unit >)
```


参数: 

|名称|类型|描述|
|---|---|---|
|vpPtr|CPointer<Unit>||

