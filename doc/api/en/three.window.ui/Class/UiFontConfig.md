# Class
## class UiFontConfig
```cj
public class UiFontConfig
```
Safe wrapper for ImFontConfig

### func finalize\(\)
```cj
public func finalize(): Unit
```
Frees the underlying ImFontConfig instance

### func getEllipsisChar\(\)
```cj
public func getEllipsisChar(): UInt32
```
Gets the ellipsis character (0 = auto)

Return: 

- Ellipsis character code point

### func getExtraSizeScale\(\)
```cj
public func getExtraSizeScale(): Float32
```
Gets the extra size scale

Return: 

- Extra size scale factor

### func getFontDataOwnedByAtlas\(\)
```cj
public func getFontDataOwnedByAtlas(): Bool
```
Whether the font data is owned by the atlas

Return: 

- Ownership flag

### func getFontDataSize\(\)
```cj
public func getFontDataSize(): Int32
```
Gets the in-memory font data size

Return: 

- Font data size (bytes)

### func getFontData\(\)
```cj
public func getFontData(): VoidPtr
```
Gets the in-memory font data pointer

Return: 

- Font data pointer (wrapped in VoidPtr)

### func getFontNo\(\)
```cj
public func getFontNo(): UInt32
```
Gets the font number (index of the font within the atlas)

Return: 

- Font number

### func getGlyphExtraAdvanceX\(\)
```cj
public func getGlyphExtraAdvanceX(): Float32
```
Gets the extra glyph advance width

Return: 

- Extra advance width

### func getGlyphMaxAdvanceX\(\)
```cj
public func getGlyphMaxAdvanceX(): Float32
```
Gets the maximum glyph advance width

Return: 

- Maximum advance width

### func getGlyphMinAdvanceX\(\)
```cj
public func getGlyphMinAdvanceX(): Float32
```
Gets the minimum glyph advance width

Return: 

- Minimum advance width

### func getGlyphOffset\(\)
```cj
public func getGlyphOffset():(Float32, Float32)
```
Gets the glyph pixel offset

Return: 

- (x, y) offset

### func getGlyphRanges\(\)
```cj
public func getGlyphRanges(): UiGlyphRanges
```
Gets the glyph ranges

Return: 

- UiGlyphRanges object (borrowed, not freed)

### func getMergeMode\(\)
```cj
public func getMergeMode(): Bool
```
Whether to merge into the previous font (used for Chinese fallback stacking)

Return: 

- Merge mode flag

### func getOversampleH\(\)
```cj
public func getOversampleH(): Int32
```
Gets the horizontal oversampling factor (higher = crisper but more expensive)

Return: 

- Horizontal oversampling factor

### func getOversampleV\(\)
```cj
public func getOversampleV(): Int32
```
Gets the vertical oversampling factor (higher = crisper but more expensive)

Return: 

- Vertical oversampling factor

### func getPixelSnapH\(\)
```cj
public func getPixelSnapH(): Bool
```
Whether pixel snapping (PixelSnapH) is enabled

Return: 

- Pixel snap flag

### func getRasterizerDensity\(\)
```cj
public func getRasterizerDensity(): Float32
```
Gets the rasterizer density (scales the sampling resolution)

Return: 

- Rasterizer density

### func getRasterizerMultiply\(\)
```cj
public func getRasterizerMultiply(): Float32
```
Gets the rasterizer multiply (adjusts glyph brightness/boldness)

Return: 

- Rasterizer multiply value

### func getSizePixels\(\)
```cj
public func getSizePixels(): Float32
```
Gets the font pixel size

Return: 

- Font pixel size

### func init\(\)
```cj
public init()
```
Creates a default font config (an ImFontConfig instance on its own heap allocation)

### func setEllipsisChar\(UInt32\)
```cj
public func setEllipsisChar(v: UInt32): Unit
```
Sets the ellipsis character (0 = auto)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt32|Ellipsis character code point|

### func setExtraSizeScale\(Float32\)
```cj
public func setExtraSizeScale(v: Float32): Unit
```
Sets the extra size scale

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|Extra size scale factor|

### func setFontDataOwnedByAtlas\(Bool\)
```cj
public func setFontDataOwnedByAtlas(v: Bool): Unit
```
Sets whether the font data is owned by the atlas

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Bool|Whether to transfer ownership to the atlas|

### func setFontDataSize\(Int32\)
```cj
public func setFontDataSize(v: Int32): Unit
```
Sets the in-memory font data size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int32|Font data size (bytes)|

### func setFontData\(VoidPtr\)
```cj
public func setFontData(ptr: VoidPtr): Unit
```
Sets the in-memory font data pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ptr|VoidPtr|Font data pointer|

### func setFontNo\(UInt32\)
```cj
public func setFontNo(v: UInt32): Unit
```
Sets the font number (index of the font within the atlas)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt32|Font number|

### func setGlyphExtraAdvanceX\(Float32\)
```cj
public func setGlyphExtraAdvanceX(v: Float32): Unit
```
Sets the extra glyph advance width

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|Extra advance width|

### func setGlyphMaxAdvanceX\(Float32\)
```cj
public func setGlyphMaxAdvanceX(v: Float32): Unit
```
Sets the maximum glyph advance width

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|Maximum advance width|

### func setGlyphMinAdvanceX\(Float32\)
```cj
public func setGlyphMinAdvanceX(v: Float32): Unit
```
Sets the minimum glyph advance width

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|Minimum advance width|

### func setGlyphOffset\(Float32,Float32\)
```cj
public func setGlyphOffset(x: Float32, y: Float32): Unit
```
Sets the glyph pixel offset

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|Horizontal offset|
|y|Float32|Vertical offset|

### func setGlyphRanges\(UiGlyphRanges\)
```cj
public func setGlyphRanges(ranges: UiGlyphRanges): Unit
```
Sets the glyph ranges

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ranges|UiGlyphRanges|Glyph ranges|

### func setMergeMode\(Bool\)
```cj
public func setMergeMode(v: Bool): Unit
```
Sets the merge mode (merge into the previous font)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Bool|Whether to enable merging|

### func setOversampleH\(Int32\)
```cj
public func setOversampleH(v: Int32): Unit
```
Sets the horizontal oversampling factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int32|Horizontal oversampling factor|

### func setOversampleV\(Int32\)
```cj
public func setOversampleV(v: Int32): Unit
```
Sets the vertical oversampling factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int32|Vertical oversampling factor|

### func setPixelSnapH\(Bool\)
```cj
public func setPixelSnapH(v: Bool): Unit
```
Sets pixel snapping (PixelSnapH)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Bool|Whether to enable pixel snapping|

### func setRasterizerDensity\(Float32\)
```cj
public func setRasterizerDensity(v: Float32): Unit
```
Sets the rasterizer density

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|Rasterizer density|

### func setRasterizerMultiply\(Float32\)
```cj
public func setRasterizerMultiply(v: Float32): Unit
```
Sets the rasterizer multiply

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|Rasterizer multiply value|

### func setSizePixels\(Float32\)
```cj
public func setSizePixels(v: Float32): Unit
```
Sets the font pixel size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|Font pixel size|

