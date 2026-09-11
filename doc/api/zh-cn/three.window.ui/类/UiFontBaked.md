# 类
## class UiFontBaked
```cj
public class UiFontBaked
```
烘焙字体数据包装器

### func clearOutputData\(\)
```cj
public func clearOutputData(): Unit
```
清除输出数据

### func findGlyphNoFallback\(UInt16\)
```cj
public func findGlyphNoFallback(codepoint: UInt16): CPointer < Unit >
```
查找字形（无回退）

参数: 

|名称|类型|描述|
|---|---|---|
|codepoint|UInt16|Unicode 码点（UInt16）|

返回: 

- ImFontGlyph 指针（找不到返回 null）

### func findGlyph\(UInt16\)
```cj
public func findGlyph(codepoint: UInt16): CPointer < Unit >
```
查找字形

参数: 

|名称|类型|描述|
|---|---|---|
|codepoint|UInt16|Unicode 码点|

返回: 

- ImFontGlyph 指针

### func getCharAdvance\(UInt16\)
```cj
public func getCharAdvance(codepoint: UInt16): Float32
```
获取字符推进宽度

参数: 

|名称|类型|描述|
|---|---|---|
|codepoint|UInt16|Unicode 码点（UInt16）|

返回: 

- 推进宽度（像素）

### func init\(CPointer<Unit>\)
```cj
public init(ptr: CPointer < Unit >)
```


参数: 

|名称|类型|描述|
|---|---|---|
|ptr|CPointer<Unit>||

