# Class
## class UiFontAtlas
```cj
public class UiFontAtlas
```
Font atlas manager (static utility)

### func addFontDefault\(UiFontConfig\)
```cj
public static func addFontDefault(fontConfig!: UiFontConfig = UiFontConfig()): UiFont
```
Adds the default (built-in) font

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fontConfig|UiFontConfig|Font config (optional; a new one is created by default)|

Return: 

- The UiFont object

### func addFontFromFileTTF\(String,Float32,UiFontConfig,UiGlyphRanges\)
```cj
public static func addFontFromFileTTF(filename: String, sizePixels: Float32, fontConfig!: UiFontConfig = UiFontConfig(), glyphRanges!: UiGlyphRanges = UiGlyphRanges()): UiFont
```
Adds a font from a TTF/OTF file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|filename|String|File path|
|sizePixels|Float32|Pixel size|
|fontConfig|UiFontConfig|Font config (optional)|
|glyphRanges|UiGlyphRanges|Glyph ranges (optional; defaults to Latin + basic symbols)|

Return: 

- The UiFont object

### func addFontFromMemoryTTF\(UiFontData,Float32,UiFontConfig,UiGlyphRanges\)
```cj
public static func addFontFromMemoryTTF(fontData: UiFontData, sizePixels: Float32, fontConfig!: UiFontConfig = UiFontConfig(), glyphRanges!: UiGlyphRanges = UiGlyphRanges()): UiFont
```
Adds a font from in-memory TTF/OTF data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fontData|UiFontData|In-memory font data (safe type)|
|sizePixels|Float32|Pixel size|
|fontConfig|UiFontConfig|Font config (optional; setting fontDataOwnedByAtlas=truetransfers data ownership to the atlas)|
|glyphRanges|UiGlyphRanges|Glyph ranges (optional)|

Return: 

- The UiFont object

### func build\(\)
```cj
public static func build(): Bool
```
Builds the font atlas (generates texture data)

Return: 

- Whether the build succeeded

### func clearFonts\(\)
```cj
public static func clearFonts(): Unit
```
Clears font data

### func clearInputData\(\)
```cj
public static func clearInputData(): Unit
```
Clears input data (keeps the texture)

### func clear\(\)
```cj
public static func clear(): Unit
```
Clears all atlas data

### func getGlyphRangesChineseFull\(\)
```cj
public static func getGlyphRangesChineseFull(): UiGlyphRanges
```
Full Chinese glyph ranges

Return: 

- UiGlyphRanges object (borrows ImGui static data, not freed)

### func getGlyphRangesChineseSimplifiedCommon\(\)
```cj
public static func getGlyphRangesChineseSimplifiedCommon(): UiGlyphRanges
```
Chinese Simplified common glyph ranges (~2500 common chars, includes default + kana + katakana)

Return: 

- UiGlyphRanges object (borrows ImGui static data, not freed)

### func getGlyphRangesCyrillic\(\)
```cj
public static func getGlyphRangesCyrillic(): UiGlyphRanges
```
Cyrillic glyph ranges

Return: 

- UiGlyphRanges object (borrows ImGui static data, not freed)

### func getGlyphRangesDefault\(\)
```cj
public static func getGlyphRangesDefault(): UiGlyphRanges
```
Default glyph ranges (Latin + basic symbols)

Return: 

- UiGlyphRanges object (borrows ImGui static data, not freed)

### func getGlyphRangesGreek\(\)
```cj
public static func getGlyphRangesGreek(): UiGlyphRanges
```
Greek glyph ranges

Return: 

- UiGlyphRanges object (borrows ImGui static data, not freed)

### func getGlyphRangesJapanese\(\)
```cj
public static func getGlyphRangesJapanese(): UiGlyphRanges
```
Japanese glyph ranges

Return: 

- UiGlyphRanges object (borrows ImGui static data, not freed)

### func getGlyphRangesKorean\(\)
```cj
public static func getGlyphRangesKorean(): UiGlyphRanges
```
Korean glyph ranges

Return: 

- UiGlyphRanges object (borrows ImGui static data, not freed)

### func getGlyphRangesThai\(\)
```cj
public static func getGlyphRangesThai(): UiGlyphRanges
```
Thai glyph ranges

Return: 

- UiGlyphRanges object (borrows ImGui static data, not freed)

### func getGlyphRangesVietnamese\(\)
```cj
public static func getGlyphRangesVietnamese(): UiGlyphRanges
```
Vietnamese glyph ranges

Return: 

- UiGlyphRanges object (borrows ImGui static data, not freed)

### func isBuilt\(\)
```cj
public static func isBuilt(): Bool
```
Whether the atlas has been built

Return: 

- true if built

