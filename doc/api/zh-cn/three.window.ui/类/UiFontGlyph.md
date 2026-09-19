# 类
## class UiFontGlyph
```cj
public class UiFontGlyph
```
字形数据（只读查询）

### func getAdvanceX\(\)
```cj
public func getAdvanceX(): Float32
```
获取推进宽度（像素）

返回: 

- 推进宽度，无效时返回 0

### func getCodepoint\(\)
```cj
public func getCodepoint(): UInt32
```
获取 Unicode 码点

返回: 

- 码点值，无效时返回 0

### func getPackId\(\)
```cj
public func getPackId(): Int32
```
获取打包页 ID

返回: 

- 打包页 ID，无效时返回 0

### func getRect\(\)
```cj
public func getRect():(Float32, Float32, Float32, Float32)
```
获取字形矩形

返回: 

- (x0, y0, x1, y1)，无效时全为 0

### func getUV\(\)
```cj
public func getUV():(Float32, Float32, Float32, Float32)
```
获取字形 UV 坐标

返回: 

- (u0, v0, u1, v1)，无效时全为 0

### func init\(VoidPtr\)
```cj
public init(ptr: VoidPtr)
```
以底层 ImFontGlyph 指针构造

参数: 

|名称|类型|描述|
|---|---|---|
|ptr|VoidPtr|底层 ImFontGlyph 指针|

### func isColored\(\)
```cj
public func isColored(): Bool
```
是否为彩色字形

返回: 

- 彩色字形返回 true

### func isValid\(\)
```cj
public func isValid(): Bool
```
是否有效（对应非空 ImFontGlyph）

返回: 

- 有效返回 true

### func isVisible\(\)
```cj
public func isVisible(): Bool
```
是否可见（可渲染）

返回: 

- 可见返回 true

