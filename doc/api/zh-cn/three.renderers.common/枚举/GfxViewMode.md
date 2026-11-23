# 枚举
## enum GfxViewMode
```cj
public enum GfxViewMode
```
视图渲染排序模式

### Default
```cj
Default
```
默认（顺序渲染，无特殊排序）

### DepthAscending
```cj
DepthAscending
```
按深度升序（从近到远）

### DepthDescending
```cj
DepthDescending
```
按深度降序（从远到近，透明物体）

### Sequential
```cj
Sequential
```
按提交顺序渲染

### func value\(\)
```cj
public func value(): UInt32
```


