# 类
## class UiFontGlyphRangesBuilder
```cj
public class UiFontGlyphRangesBuilder
```
自定义字形范围构建器

### func addChar\(UInt16\)
```cj
public func addChar(c: UInt16): Unit
```
添加单个字符（Unicode 码点，ImWchar 范围）

参数: 

|名称|类型|描述|
|---|---|---|
|c|UInt16|字符码点|

### func addRanges\(UiGlyphRanges\)
```cj
public func addRanges(ranges: UiGlyphRanges): Unit
```
追加一组已有范围（如默认范围 + 自定义字符）

参数: 

|名称|类型|描述|
|---|---|---|
|ranges|UiGlyphRanges|要追加的字形范围|

### func addText\(String\)
```cj
public func addText(text: String): Unit
```
添加一段 UTF-8 文本（自动按码点逐个收录）

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|UTF-8 文本|

### func buildRanges\(\)
```cj
public func buildRanges(): UiGlyphRanges
```
构建最终字形范围（生成堆内存，由返回对象持有）

返回: 

- UiGlyphRanges 对象（拥有堆内存，需调用 finalize 释放）

### func finalize\(\)
```cj
public func finalize(): Unit
```
释放底层构建器资源

### func init\(\)
```cj
public init()
```
创建字形范围构建器

