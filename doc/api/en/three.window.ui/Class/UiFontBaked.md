# Class
## class UiFontBaked
```cj
public class UiFontBaked
```
Baked font data wrapper

### func clearOutputData\(\)
```cj
public func clearOutputData(): Unit
```
Clears output data

### func findGlyphNoFallback\(UInt16\)
```cj
public func findGlyphNoFallback(codepoint: UInt16): CPointer < Unit >
```
Finds a glyph (no fallback)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|codepoint|UInt16|Unicode codepoint (UInt16)|

Return: 

- ImFontGlyph pointer (null if not found)

### func findGlyph\(UInt16\)
```cj
public func findGlyph(codepoint: UInt16): CPointer < Unit >
```
Finds a glyph

Parameter: 

|Name|Type|Describe|
|---|---|---|
|codepoint|UInt16|Unicode codepoint|

Return: 

- ImFontGlyph pointer

### func getCharAdvance\(UInt16\)
```cj
public func getCharAdvance(codepoint: UInt16): Float32
```
Gets character advance width

Parameter: 

|Name|Type|Describe|
|---|---|---|
|codepoint|UInt16|Unicode codepoint (UInt16)|

Return: 

- Advance width in pixels

### func init\(CPointer<Unit>\)
```cj
public init(ptr: CPointer < Unit >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|ptr|CPointer<Unit>||

