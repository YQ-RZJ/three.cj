# 类
## class UiFontConfig
```cj
public class UiFontConfig
```
ImFontConfig 安全包装

### func finalize\(\)
```cj
public func finalize(): Unit
```
释放底层 ImFontConfig 实例

### func getEllipsisChar\(\)
```cj
public func getEllipsisChar(): UInt32
```
获取省略号字符（0=自动）

返回: 

- 省略号字符码点

### func getExtraSizeScale\(\)
```cj
public func getExtraSizeScale(): Float32
```
获取额外尺寸缩放

返回: 

- 额外尺寸缩放系数

### func getFontDataOwnedByAtlas\(\)
```cj
public func getFontDataOwnedByAtlas(): Bool
```
字体数据所有权是否归图集所有

返回: 

- 所有权归属开关

### func getFontDataSize\(\)
```cj
public func getFontDataSize(): Int32
```
获取内存字体数据大小

返回: 

- 字体数据大小（字节）

### func getFontData\(\)
```cj
public func getFontData(): VoidPtr
```
获取内存字体数据指针

返回: 

- 字体数据指针（VoidPtr 包装）

### func getFontNo\(\)
```cj
public func getFontNo(): UInt32
```
获取字体序号（图集内第几个字体）

返回: 

- 字体序号

### func getGlyphExtraAdvanceX\(\)
```cj
public func getGlyphExtraAdvanceX(): Float32
```
获取字形额外前进宽度

返回: 

- 额外前进宽度

### func getGlyphMaxAdvanceX\(\)
```cj
public func getGlyphMaxAdvanceX(): Float32
```
获取字形最大前进宽度

返回: 

- 最大前进宽度

### func getGlyphMinAdvanceX\(\)
```cj
public func getGlyphMinAdvanceX(): Float32
```
获取字形最小前进宽度

返回: 

- 最小前进宽度

### func getGlyphOffset\(\)
```cj
public func getGlyphOffset():(Float32, Float32)
```
获取字形像素偏移

返回: 

- (x, y) 偏移量

### func getGlyphRanges\(\)
```cj
public func getGlyphRanges(): UiGlyphRanges
```
获取字形范围

返回: 

- UiGlyphRanges 对象（借用，不释放）

### func getMergeMode\(\)
```cj
public func getMergeMode(): Bool
```
是否合并到上一个字体（用于中文字体回退叠加）

返回: 

- 合并模式开关

### func getOversampleH\(\)
```cj
public func getOversampleH(): Int32
```
获取水平超采样倍数（越大越清晰，消耗越大）

返回: 

- 水平超采样倍数

### func getOversampleV\(\)
```cj
public func getOversampleV(): Int32
```
获取垂直超采样倍数（越大越清晰，消耗越大）

返回: 

- 垂直超采样倍数

### func getPixelSnapH\(\)
```cj
public func getPixelSnapH(): Bool
```
是否启用像素对齐（PixelSnapH）

返回: 

- 像素对齐开关

### func getRasterizerDensity\(\)
```cj
public func getRasterizerDensity(): Float32
```
获取光栅化密度（缩放采样分辨率）

返回: 

- 光栅化密度

### func getRasterizerMultiply\(\)
```cj
public func getRasterizerMultiply(): Float32
```
获取光栅化倍增系数（调整字形亮度/加粗）

返回: 

- 光栅化倍增系数

### func getSizePixels\(\)
```cj
public func getSizePixels(): Float32
```
获取字体像素大小

返回: 

- 字体像素大小

### func init\(\)
```cj
public init()
```
创建默认字体配置（独立堆上的 ImFontConfig 实例）

### func setEllipsisChar\(UInt32\)
```cj
public func setEllipsisChar(v: UInt32): Unit
```
设置省略号字符（0=自动）

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt32|省略号字符码点|

### func setExtraSizeScale\(Float32\)
```cj
public func setExtraSizeScale(v: Float32): Unit
```
设置额外尺寸缩放

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|额外尺寸缩放系数|

### func setFontDataOwnedByAtlas\(Bool\)
```cj
public func setFontDataOwnedByAtlas(v: Bool): Unit
```
设置字体数据所有权是否归图集所有

参数: 

|名称|类型|描述|
|---|---|---|
|v|Bool|是否将所有权转移给图集|

### func setFontDataSize\(Int32\)
```cj
public func setFontDataSize(v: Int32): Unit
```
设置内存字体数据大小

参数: 

|名称|类型|描述|
|---|---|---|
|v|Int32|字体数据大小（字节）|

### func setFontData\(VoidPtr\)
```cj
public func setFontData(ptr: VoidPtr): Unit
```
设置内存字体数据指针

参数: 

|名称|类型|描述|
|---|---|---|
|ptr|VoidPtr|字体数据指针|

### func setFontNo\(UInt32\)
```cj
public func setFontNo(v: UInt32): Unit
```
设置字体序号（图集内第几个字体）

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt32|字体序号|

### func setGlyphExtraAdvanceX\(Float32\)
```cj
public func setGlyphExtraAdvanceX(v: Float32): Unit
```
设置字形额外前进宽度

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|额外前进宽度|

### func setGlyphMaxAdvanceX\(Float32\)
```cj
public func setGlyphMaxAdvanceX(v: Float32): Unit
```
设置字形最大前进宽度

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|最大前进宽度|

### func setGlyphMinAdvanceX\(Float32\)
```cj
public func setGlyphMinAdvanceX(v: Float32): Unit
```
设置字形最小前进宽度

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|最小前进宽度|

### func setGlyphOffset\(Float32,Float32\)
```cj
public func setGlyphOffset(x: Float32, y: Float32): Unit
```
设置字形像素偏移

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32|水平偏移|
|y|Float32|垂直偏移|

### func setGlyphRanges\(UiGlyphRanges\)
```cj
public func setGlyphRanges(ranges: UiGlyphRanges): Unit
```
设置字形范围

参数: 

|名称|类型|描述|
|---|---|---|
|ranges|UiGlyphRanges|字形范围|

### func setMergeMode\(Bool\)
```cj
public func setMergeMode(v: Bool): Unit
```
设置合并模式（合并到上一个字体）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Bool|是否启用合并|

### func setOversampleH\(Int32\)
```cj
public func setOversampleH(v: Int32): Unit
```
设置水平超采样倍数

参数: 

|名称|类型|描述|
|---|---|---|
|v|Int32|水平超采样倍数|

### func setOversampleV\(Int32\)
```cj
public func setOversampleV(v: Int32): Unit
```
设置垂直超采样倍数

参数: 

|名称|类型|描述|
|---|---|---|
|v|Int32|垂直超采样倍数|

### func setPixelSnapH\(Bool\)
```cj
public func setPixelSnapH(v: Bool): Unit
```
设置像素对齐（PixelSnapH）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Bool|是否启用像素对齐|

### func setRasterizerDensity\(Float32\)
```cj
public func setRasterizerDensity(v: Float32): Unit
```
设置光栅化密度

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|光栅化密度|

### func setRasterizerMultiply\(Float32\)
```cj
public func setRasterizerMultiply(v: Float32): Unit
```
设置光栅化倍增系数

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|光栅化倍增系数|

### func setSizePixels\(Float32\)
```cj
public func setSizePixels(v: Float32): Unit
```
设置字体像素大小

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|字体像素大小|

