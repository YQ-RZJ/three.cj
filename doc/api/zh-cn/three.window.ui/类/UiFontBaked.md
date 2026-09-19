# 类
## class UiFontBaked
```cj
public class UiFontBaked
```
烘焙字体数据（安全类型）

### func clearOutputData\(\)
```cj
public func clearOutputData(): Unit
```
清除输出数据

### func findGlyphNoFallback\(UInt16\)
```cj
public func findGlyphNoFallback(codepoint: UInt16): UiFontGlyph
```
查找字形（无回退）

参数: 

|名称|类型|描述|
|---|---|---|
|codepoint|UInt16|Unicode 码点|

返回: 

- UiFontGlyph 对象，未找到时可能无效

### func findGlyph\(UInt16\)
```cj
public func findGlyph(codepoint: UInt16): UiFontGlyph
```
查找字形（带缺省回退）

参数: 

|名称|类型|描述|
|---|---|---|
|codepoint|UInt16|Unicode 码点|

返回: 

- UiFontGlyph 对象，未找到时回退到缺省字形

### func getCharAdvance\(UInt16\)
```cj
public func getCharAdvance(codepoint: UInt16): Float32
```
获取字符推进宽度（像素）

参数: 

|名称|类型|描述|
|---|---|---|
|codepoint|UInt16|Unicode 码点|

返回: 

- 推进宽度，无效时返回 0

### func init\(VoidPtr\)
```cj
public init(ptr: VoidPtr)
```
以底层 ImFontBaked 指针构造

参数: 

|名称|类型|描述|
|---|---|---|
|ptr|VoidPtr|底层 ImFontBaked 指针|

