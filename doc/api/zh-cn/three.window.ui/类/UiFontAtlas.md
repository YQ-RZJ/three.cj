# 类
## class UiFontAtlas
```cj
public class UiFontAtlas
```
字体图集管理器（静态工具类）

### func addFontDefault\(UiFontConfig\)
```cj
public static func addFontDefault(fontConfig!: UiFontConfig = UiFontConfig()): UiFont
```
添加默认字体（内置 ProggyClean）

参数: 

|名称|类型|描述|
|---|---|---|
|fontConfig|UiFontConfig|字体配置（可选，默认新建）|

返回: 

- UiFont 字体对象

### func addFontFromFileTTF\(String,Float32,UiFontConfig,UiGlyphRanges\)
```cj
public static func addFontFromFileTTF(filename: String, sizePixels: Float32, fontConfig!: UiFontConfig = UiFontConfig(), glyphRanges!: UiGlyphRanges = UiGlyphRanges()): UiFont
```
从 TTF/OTF 文件添加字体

参数: 

|名称|类型|描述|
|---|---|---|
|filename|String|文件路径|
|sizePixels|Float32|像素大小|
|fontConfig|UiFontConfig|字体配置（可选）|
|glyphRanges|UiGlyphRanges|字形范围（可选，默认 Latin+基本符号）|

返回: 

- UiFont 字体对象

### func addFontFromMemoryTTF\(UiFontData,Float32,UiFontConfig,UiGlyphRanges\)
```cj
public static func addFontFromMemoryTTF(fontData: UiFontData, sizePixels: Float32, fontConfig!: UiFontConfig = UiFontConfig(), glyphRanges!: UiGlyphRanges = UiGlyphRanges()): UiFont
```
从内存 TTF/OTF 数据添加字体

参数: 

|名称|类型|描述|
|---|---|---|
|fontData|UiFontData|内存字体数据（安全类型）|
|sizePixels|Float32|像素大小|
|fontConfig|UiFontConfig|字体配置（可选；若设 fontDataOwnedByAtlas=true，数据所有权将转移给图集）|
|glyphRanges|UiGlyphRanges|字形范围（可选）|

返回: 

- UiFont 字体对象

### func build\(\)
```cj
public static func build(): Bool
```
构建字体图集（生成纹理数据）

返回: 

- 是否成功

### func clearFonts\(\)
```cj
public static func clearFonts(): Unit
```
清除字体数据

### func clearInputData\(\)
```cj
public static func clearInputData(): Unit
```
清除输入数据（保留纹理）

### func clear\(\)
```cj
public static func clear(): Unit
```
清除所有数据

### func getGlyphRangesChineseFull\(\)
```cj
public static func getGlyphRangesChineseFull(): UiGlyphRanges
```
中文全量字形范围

返回: 

- UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）

### func getGlyphRangesChineseSimplifiedCommon\(\)
```cj
public static func getGlyphRangesChineseSimplifiedCommon(): UiGlyphRanges
```
中文简体常用字形范围（约 2500 常用字，含默认+假名+片假名）

返回: 

- UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）

### func getGlyphRangesCyrillic\(\)
```cj
public static func getGlyphRangesCyrillic(): UiGlyphRanges
```
西里尔文字形范围

返回: 

- UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）

### func getGlyphRangesDefault\(\)
```cj
public static func getGlyphRangesDefault(): UiGlyphRanges
```
默认字形范围（Latin + 基本符号）

返回: 

- UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）

### func getGlyphRangesGreek\(\)
```cj
public static func getGlyphRangesGreek(): UiGlyphRanges
```
希腊文字形范围

返回: 

- UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）

### func getGlyphRangesJapanese\(\)
```cj
public static func getGlyphRangesJapanese(): UiGlyphRanges
```
日文字形范围

返回: 

- UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）

### func getGlyphRangesKorean\(\)
```cj
public static func getGlyphRangesKorean(): UiGlyphRanges
```
韩文字形范围

返回: 

- UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）

### func getGlyphRangesThai\(\)
```cj
public static func getGlyphRangesThai(): UiGlyphRanges
```
泰文字形范围

返回: 

- UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）

### func getGlyphRangesVietnamese\(\)
```cj
public static func getGlyphRangesVietnamese(): UiGlyphRanges
```
越南文字形范围

返回: 

- UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）

### func isBuilt\(\)
```cj
public static func isBuilt(): Bool
```
图集是否已构建

返回: 

- 已构建返回 true

