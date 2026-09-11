# Class
## class UiContext
```cj
public class UiContext
```
UI context — manages ImGui lifecycle and rendering

### func init\(\)
```cj
public init()
```
===== 构造 =====

### func setPixelRatio\(Float64\)
```cj
public func setPixelRatio(value: Float64): Unit
```
Sets the current window pixel ratio

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Pixel ratio (physical pixels / logical pixels)|

### prop currentPixelRatio: Float64
```cj
public static prop currentPixelRatio: Float64
```
Gets the pixel ratio used by the current UI context

### prop initialized: Bool
```cj
public prop initialized: Bool
```
Whether the context has been initialized

