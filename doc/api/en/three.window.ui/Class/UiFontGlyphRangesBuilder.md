# Class
## class UiFontGlyphRangesBuilder
```cj
public class UiFontGlyphRangesBuilder
```
Custom glyph ranges builder

### func addChar\(UInt16\)
```cj
public func addChar(c: UInt16): Unit
```
Adds a single character (Unicode code point, ImWchar range)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|UInt16|Character code point|

### func addRanges\(UiGlyphRanges\)
```cj
public func addRanges(ranges: UiGlyphRanges): Unit
```
Appends an existing range set (e.g. default ranges + custom characters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ranges|UiGlyphRanges|Glyph ranges to append|

### func addText\(String\)
```cj
public func addText(text: String): Unit
```
Adds a UTF-8 text (each code point is collected automatically)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|UTF-8 text|

### func buildRanges\(\)
```cj
public func buildRanges(): UiGlyphRanges
```
Builds the final glyph ranges (heap memory generated and owned by the returned object)

Return: 

- UiGlyphRanges object (owns heap memory; call finalize to free)

### func finalize\(\)
```cj
public func finalize(): Unit
```
Frees the underlying builder resources

### func init\(\)
```cj
public init()
```
Creates a glyph ranges builder

