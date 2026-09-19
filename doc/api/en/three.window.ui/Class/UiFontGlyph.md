# Class
## class UiFontGlyph
```cj
public class UiFontGlyph
```
Glyph data (read-only queries)

### func getAdvanceX\(\)
```cj
public func getAdvanceX(): Float32
```
Gets the advance width (pixels)

Return: 

- Advance width; 0 if invalid

### func getCodepoint\(\)
```cj
public func getCodepoint(): UInt32
```
Gets the Unicode code point

Return: 

- Code point; 0 if invalid

### func getPackId\(\)
```cj
public func getPackId(): Int32
```
Gets the packing page ID

Return: 

- Packing page ID; 0 if invalid

### func getRect\(\)
```cj
public func getRect():(Float32, Float32, Float32, Float32)
```
Gets the glyph rectangle

Return: 

- (x0, y0, x1, y1); all zeros if invalid

### func getUV\(\)
```cj
public func getUV():(Float32, Float32, Float32, Float32)
```
Gets the glyph UV coordinates

Return: 

- (u0, v0, u1, v1); all zeros if invalid

### func init\(VoidPtr\)
```cj
public init(ptr: VoidPtr)
```
Constructs from a raw ImFontGlyph pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ptr|VoidPtr|Raw ImFontGlyph pointer|

### func isColored\(\)
```cj
public func isColored(): Bool
```
Whether the glyph is colored

Return: 

- true if colored

### func isValid\(\)
```cj
public func isValid(): Bool
```
Whether the glyph is valid (i.e. ImFontGlyph is non-null)

Return: 

- true if valid

### func isVisible\(\)
```cj
public func isVisible(): Bool
```
Whether the glyph is visible (renderable)

Return: 

- true if visible

