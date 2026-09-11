# 类
## class UiFontAtlas
```cj
public class UiFontAtlas
```
字体图集管理器

### func addFontDefault\(\)
```cj
public static func addFontDefault(): CPointer < Unit >
```
添加默认字体（内置）

返回: 

- ImFont 指针

### func addFontFromFileTTF\(String,Float32,CPointer<Unit>,CPointer<UInt16>\)
```cj
public static func addFontFromFileTTF(filename: String, sizePixels: Float32, fontConfig!: CPointer < Unit >= CPointer < Unit >(), glyphRanges!: CPointer < UInt16 >= CPointer < UInt16 >()): CPointer < Unit >
```
从 TTF 文件添加字体

参数: 

|名称|类型|描述|
|---|---|---|
|filename|String|文件路径|
|sizePixels|Float32|像素大小|
|fontConfig|CPointer<Unit>|字体配置指针（可选）|
|glyphRanges|CPointer<UInt16>|字形范围指针（可选）|

返回: 

- ImFont 指针

### func addFontFromMemoryTTF\(CPointer<Unit>,Int32,Float32\)
```cj
public static func addFontFromMemoryTTF(fontData: CPointer < Unit >, dataSize: Int32, sizePixels: Float32): CPointer < Unit >
```
从内存 TTF 数据添加字体

参数: 

|名称|类型|描述|
|---|---|---|
|fontData|CPointer<Unit>|TTF 数据指针|
|dataSize|Int32|数据大小（字节）|
|sizePixels|Float32|像素大小|

返回: 

- ImFont 指针

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

### func getGlyphRangesDefault\(\)
```cj
public static func getGlyphRangesDefault(): CPointer < UInt16 >
```
获取默认字形范围（Latin + 基本符号）

返回: 

- 字形范围指针（UInt16 数组，以 0 结尾）

