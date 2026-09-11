# Class
## class UiStyle
```cj
public class UiStyle
```
ImGui style management class

### func calcItemWidth\(\)
```cj
public static func calcItemWidth(): Float32
```
Calculates the current item width

### func calcTextSize\(String,Bool,Float32\)
```cj
public static func calcTextSize(text: String, hideTextAfterDoubleHash!: Bool = true, wrapWidth!: Float32 = - 1.0f32):(Float32, Float32)
```
Calculates text rendering size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|Text|
|hideTextAfterDoubleHash|Bool|Whether to truncate after ##|
|wrapWidth|Float32|Wrap width (-1.0=no wrap)|

Return: 

- (width, height)

### func classic\(\)
```cj
public static func classic(): Unit
```
Applies the classic theme

### func col32\(UInt32,UInt32,UInt32,UInt32\)
```cj
public static func col32(r: UInt32, g: UInt32, b: UInt32, a: UInt32): UInt32
```
Converts RGBA to ImU32 color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|UInt32||
|g|UInt32||
|b|UInt32||
|a|UInt32||

### func dark\(\)
```cj
public static func dark(): Unit
```
Applies the dark theme

### func getClipboardText\(\)
```cj
public static func getClipboardText(): String
```
Gets clipboard text

### func getColorName\(Int32\)
```cj
public func getColorName(idx: Int32): String
```
Returns the color name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32|Color index|

### func getColorVec4\(Int32\)
```cj
public static func getColorVec4(idx: Int32): ImVec4
```
Gets color value by ImGuiCol (Vec4)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32||

### func getColor\(Int32\)
```cj
public func getColor(idx: Int32): ImVec4
```
Returns the color value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32|Color index|

Return: 

- ImVec4 color value

### func getDisplaySize\(\)
```cj
public static func getDisplaySize():(Float32, Float32)
```
Gets the ImGui display area size (IO.DisplaySize)

Return: 

- (width, height) in pixels

### func getFontSize\(\)
```cj
public func getFontSize(): Float32
```
Returns the current font size

Return: 

- Current font size

### func getFont\(\)
```cj
public func getFont(): CPointer < Unit >
```
Returns the current font

Return: 

- Current font pointer

### func getFrameCount\(\)
```cj
public static func getFrameCount(): Int32
```
Gets the ImGui frame count

### func getScale\(\)
```cj
public static func getScale(): Float32
```
Gets the current global scale factor

### func getStyle\(\)
```cj
public func getStyle(): CPointer < Unit >
```
Returns the style object pointer

Return: 

- Style object pointer

### func getTime\(\)
```cj
public static func getTime(): Float64
```
Gets the ImGui running time (seconds)

### func hsvToRGB\(Float32,Float32,Float32\)
```cj
public static func hsvToRGB(h: Float32, s: Float32, v: Float32):(Float32, Float32, Float32)
```
HSV → RGB

Parameter: 

|Name|Type|Describe|
|---|---|---|
|h|Float32||
|s|Float32||
|v|Float32||

### func light\(\)
```cj
public static func light(): Unit
```
Applies the light theme

### func loadIniFromMemory\(String\)
```cj
public func loadIniFromMemory(data: String): Unit
```
Loads INI settings from memory

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|String|INI data|

### func loadIni\(String\)
```cj
public func loadIni(filename: String): Unit
```
Loads INI settings from file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|filename|String|File path|

### func popColor\(Int32\)
```cj
public func popColor(count!: Int32 = 1): Unit
```
Pops color styles

Parameter: 

|Name|Type|Describe|
|---|---|---|
|count|Int32|Number of styles to pop|

### func popFont\(\)
```cj
public func popFont(): Unit
```
Pops the font

### func popItemFlag\(\)
```cj
public static func popItemFlag(): Unit
```
Pops item flags

### func popItemWidth\(\)
```cj
public static func popItemWidth(): Unit
```
Pops item width

### func popTextWrapPos\(\)
```cj
public static func popTextWrapPos(): Unit
```
Pops text wrap position

### func popVar\(Int32\)
```cj
public func popVar(count!: Int32 = 1): Unit
```
Pops style variables

Parameter: 

|Name|Type|Describe|
|---|---|---|
|count|Int32|Number of variables to pop|

### func pushColorU32\(Int32,UInt32\)
```cj
public func pushColorU32(idx: Int32, col: UInt32): Unit
```
Pushes a color style (UInt32 format)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32|Color index|
|col|UInt32|Color value (IM_COL32 format)|

### func pushColor\(Int32,Color\)
```cj
public func pushColor(idx: Int32, color: Color): Unit
```
Pushes a color style

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32|Color index (ImGuiCol enum value)|
|color|Color|Color (RGB components in [0, 1], alpha defaults to 1.0)|

### func pushFont\(CPointer<Unit>,Float32\)
```cj
public func pushFont(font: CPointer < Unit >, fontSizeBaseUnscaled!: Float32 = 0.0): Unit
```
Pushes a font

Parameter: 

|Name|Type|Describe|
|---|---|---|
|font|CPointer<Unit>|Font pointer|
|fontSizeBaseUnscaled|Float32|Base font size|

### func pushItemFlag\(Int32,Bool\)
```cj
public static func pushItemFlag(flags: Int32, cond: Bool): Unit
```
Pushes item flags (ImGuiItemFlags)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|flags|Int32|ImGuiItemFlags|
|cond|Bool|Condition (true=active)|

### func pushItemWidth\(Float32\)
```cj
public static func pushItemWidth(itemWidth: Float32): Unit
```
Pushes item width (overrides auto-calculation)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|itemWidth|Float32||

### func pushTextWrapPos\(Float32\)
```cj
public static func pushTextWrapPos(wrapPosX!: Float32 = 0.0f32): Unit
```
Pushes text wrap position (0.0=window right edge)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|wrapPosX|Float32||

### func pushVarFloat\(Int32,Float32\)
```cj
public func pushVarFloat(idx: Int32, val: Float32): Unit
```
Pushes a float style variable

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32|Variable index (ImGuiStyleVar enum value)|
|val|Float32|Float value|

### func pushVarVec2\(Int32,Vector2\)
```cj
public func pushVarVec2(idx: Int32, value: Vector2): Unit
```
Pushes a Vec2 style variable

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32|Variable index|
|value|Vector2|Vector2 value|

### func rgbToHSV\(Float32,Float32,Float32\)
```cj
public static func rgbToHSV(r: Float32, g: Float32, b: Float32):(Float32, Float32, Float32)
```
RGB → HSV

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float32||
|g|Float32||
|b|Float32||

### func saveIniToMemory\(\)
```cj
public func saveIniToMemory(): String
```
Saves INI settings to memory

Return: 

- INI string

### func saveIni\(String\)
```cj
public func saveIni(filename: String): Unit
```
Saves INI settings to file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|filename|String|File path|

### func scaleAllSizes\(Float32\)
```cj
public func scaleAllSizes(scaleFactor: Float32): Unit
```
Scales all style sizes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scaleFactor|Float32|Scale factor|

### func setClipboardText\(String\)
```cj
public static func setClipboardText(text: String): Unit
```
Sets clipboard text

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String||

### func setFontGlobalScale\(Float32\)
```cj
public static func setFontGlobalScale(scale: Float32): Unit
```
Sets the global font scale (IO.FontGlobalScale)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scale|Float32|Scale factor (1.0 = original size)|

### func showFontSelector\(String\)
```cj
public func showFontSelector(label: String): Unit
```
Shows the font selector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|

### func showStyleEditor\(CPointer<Unit>\)
```cj
public func showStyleEditor(ref!: CPointer < Unit >= CPointer < Unit >()): Unit
```
Shows the style editor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ref|CPointer<Unit>|Style reference (null = edit global style)|

### func showStyleSelector\(String\)
```cj
public func showStyleSelector(label: String): Bool
```
Shows the style selector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|

Return: 

- Whether a new style was selected

### func showUserGuide\(\)
```cj
public func showUserGuide(): Unit
```
Shows the user guide

### func u32ToVec4\(UInt32\)
```cj
public static func u32ToVec4(col: UInt32): ImVec4
```
Converts ImU32 to ImVec4

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|UInt32||

### func vec4ToU32\(ImVec4\)
```cj
public static func vec4ToU32(col: ImVec4): UInt32
```
Converts ImVec4 to ImU32

Parameter: 

|Name|Type|Describe|
|---|---|---|
|col|ImVec4||

