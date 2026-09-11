# Class
## class UiFontAtlas
```cj
public class UiFontAtlas
```
Font atlas manager

### func addFontDefault\(\)
```cj
public static func addFontDefault(): CPointer < Unit >
```
Adds the default (built-in) font

Return: 

- ImFont pointer

### func addFontFromFileTTF\(String,Float32,CPointer<Unit>,CPointer<UInt16>\)
```cj
public static func addFontFromFileTTF(filename: String, sizePixels: Float32, fontConfig!: CPointer < Unit >= CPointer < Unit >(), glyphRanges!: CPointer < UInt16 >= CPointer < UInt16 >()): CPointer < Unit >
```
Adds a font from a TTF file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|filename|String|File path|
|sizePixels|Float32|Pixel size|
|fontConfig|CPointer<Unit>|Font config pointer (optional)|
|glyphRanges|CPointer<UInt16>|Glyph ranges pointer (optional)|

Return: 

- ImFont pointer

### func addFontFromMemoryTTF\(CPointer<Unit>,Int32,Float32\)
```cj
public static func addFontFromMemoryTTF(fontData: CPointer < Unit >, dataSize: Int32, sizePixels: Float32): CPointer < Unit >
```
Adds a font from in-memory TTF data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fontData|CPointer<Unit>|TTF data pointer|
|dataSize|Int32|Data size in bytes|
|sizePixels|Float32|Pixel size|

Return: 

- ImFont pointer

### func build\(\)
```cj
public static func build(): Bool
```
Builds the font atlas (generates texture data)

Return: 

- Whether successful

### func clearFonts\(\)
```cj
public static func clearFonts(): Unit
```
Clears font data

### func clearInputData\(\)
```cj
public static func clearInputData(): Unit
```
Clears input data (retains texture)

### func clear\(\)
```cj
public static func clear(): Unit
```
Clears all data

### func getGlyphRangesDefault\(\)
```cj
public static func getGlyphRangesDefault(): CPointer < UInt16 >
```
Gets default glyph ranges (Latin + basic symbols)

Return: 

- Glyph ranges pointer (UInt16 array, null-terminated)

