# Class
## class UiFont
```cj
public class UiFont
```
Font object wrapper

### func addRemapChar\(UInt16,UInt16\)
```cj
public func addRemapChar(from: UInt16, to: UInt16): Unit
```
Adds a character remapping

Parameter: 

|Name|Type|Describe|
|---|---|---|
|from|UInt16|Source codepoint (UInt16)|
|to|UInt16|Target codepoint (UInt16)|

### func calcTextSize\(String,Float32,Float32\)
```cj
public func calcTextSize(text: String, fontSize!: Float32 = 0.0f32, wrapWidth!: Float32 = - 1.0f32):(Float32, Float32)
```
Calculates text rendering size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|Text|
|fontSize|Float32|Font size (0=use default)|
|wrapWidth|Float32|Wrap width (-1.0=no wrap)|

Return: 

- (width, height)

### func getDebugName\(\)
```cj
public func getDebugName(): String
```
Gets the font debug name

### func getFontBaked\(Float32,Float32\)
```cj
public func getFontBaked(fontSize!: Float32 = 0.0f32, density!: Float32 = 1.0f32): UiFontBaked
```
Gets ImFontBaked (baked font data)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fontSize|Float32||
|density|Float32||

Return: 

- UiFontBaked object

### func getHandle\(\)
```cj
public func getHandle(): CPointer < Unit >
```
Gets the underlying ImFont pointer (for UiStyle.pushFont)

### func init\(CPointer<Unit>\)
```cj
public init(fontPtr: CPointer < Unit >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|fontPtr|CPointer<Unit>||

### func isGlyphInFont\(UInt16\)
```cj
public func isGlyphInFont(codepoint: UInt16): Bool
```
Whether the specified glyph is in the font

Parameter: 

|Name|Type|Describe|
|---|---|---|
|codepoint|UInt16|Unicode codepoint|

### func isLoaded\(\)
```cj
public func isLoaded(): Bool
```
Whether the font is loaded

