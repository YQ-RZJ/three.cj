# Class
## class UiFont
```cj
public class UiFont
```
Font object (safe type)

### func addRemapChar\(UInt16,UInt16\)
```cj
public func addRemapChar(from: UInt16, to: UInt16): Unit
```
Adds a character remapping

Parameter: 

|Name|Type|Describe|
|---|---|---|
|from|UInt16|Source code point|
|to|UInt16|Target code point|

### func calcTextSize\(String,Float32,Float32\)
```cj
public func calcTextSize(text: String, fontSize!: Float32 = 0.0f32, wrapWidth!: Float32 = - 1.0f32):(Float32, Float32)
```
Calculates text rendering size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|Text|
|fontSize|Float32|Font size (0 = use default)|
|wrapWidth|Float32|Wrap width (-1.0 = no wrapping)|

Return: 

- (width, height)

### func getDebugName\(\)
```cj
public func getDebugName(): String
```
Gets the font debug name

Return: 

- Debug name string; empty string if not loaded

### func getFontBaked\(Float32,Float32\)
```cj
public func getFontBaked(fontSize!: Float32 = 0.0f32, density!: Float32 = 1.0f32): UiFontBaked
```
Gets the baked font data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fontSize|Float32|Font size (0 = use default)|
|density|Float32|Rasterizer density|

Return: 

- UiFontBaked object

### func getHandle\(\)
```cj
public func getHandle(): VoidPtr
```
Gets the raw ImFont pointer (low-level interface, usually not needed)

Return: 

- Raw ImFont pointer

### func init\(VoidPtr\)
```cj
public init(fontPtr: VoidPtr)
```
Constructs from a raw ImFont pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fontPtr|VoidPtr|Raw ImFont pointer|

### func isGlyphInFont\(UInt16\)
```cj
public func isGlyphInFont(codepoint: UInt16): Bool
```
Whether the specified glyph is in the font

Parameter: 

|Name|Type|Describe|
|---|---|---|
|codepoint|UInt16|Unicode code point (ImWchar range, <= 0xFFFF)|

Return: 

- true if present

### func isLoaded\(\)
```cj
public func isLoaded(): Bool
```
Whether the font is loaded

Return: 

- true if loaded

