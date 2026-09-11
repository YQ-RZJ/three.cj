# 类
## class UiContext
```cj
public class UiContext
```
UI 上下文——管理 ImGui 生命周期与渲染

### func init\(\)
```cj
public init()
```
===== 构造 =====

### func setPixelRatio\(Float64\)
```cj
public func setPixelRatio(value: Float64): Unit
```
设置当前窗口像素比

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|像素比（物理像素 / 逻辑像素）|

### prop currentPixelRatio: Float64
```cj
public static prop currentPixelRatio: Float64
```
获取当前 UI 上下文使用的像素比

### prop initialized: Bool
```cj
public prop initialized: Bool
```
上下文是否已初始化

