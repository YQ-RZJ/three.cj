# Class
## class UiFontBaked
```cj
public class UiFontBaked
```
Baked font data (safe type)

### func clearOutputData\(\)
```cj
public func clearOutputData(): Unit
```
Clears the output data

### func findGlyphNoFallback\(UInt16\)
```cj
public func findGlyphNoFallback(codepoint: UInt16): UiFontGlyph
```
Finds a glyph (no fallback)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|codepoint|UInt16|Unicode code point|

Return: 

- UiFontGlyph object; may be invalid when not found

### func findGlyph\(UInt16\)
```cj
public func findGlyph(codepoint: UInt16): UiFontGlyph
```
Finds a glyph (with default fallback)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|codepoint|UInt16|Unicode code point|

Return: 

- UiFontGlyph object; falls back to the default glyph when not found

### func getCharAdvance\(UInt16\)
```cj
public func getCharAdvance(codepoint: UInt16): Float32
```
Gets the character advance width (pixels)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|codepoint|UInt16|Unicode code point|

Return: 

- Advance width; 0 if invalid

### func init\(VoidPtr\)
```cj
public init(ptr: VoidPtr)
```
Constructs from a raw ImFontBaked pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ptr|VoidPtr|Raw ImFontBaked pointer|

