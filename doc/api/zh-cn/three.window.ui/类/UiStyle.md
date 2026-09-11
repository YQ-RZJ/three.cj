# 类
## class UiStyle
```cj
public class UiStyle
```
ImGui 样式管理类

### func calcItemWidth\(\)
```cj
public static func calcItemWidth(): Float32
```
计算当前控件宽度

### func calcTextSize\(String,Bool,Float32\)
```cj
public static func calcTextSize(text: String, hideTextAfterDoubleHash!: Bool = true, wrapWidth!: Float32 = - 1.0f32):(Float32, Float32)
```
计算文本渲染尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|文本|
|hideTextAfterDoubleHash|Bool|是否在 ## 后截断|
|wrapWidth|Float32|换行宽度（-1.0=不换行）|

返回: 

- (width, height)

### func classic\(\)
```cj
public static func classic(): Unit
```
应用经典主题

### func col32\(UInt32,UInt32,UInt32,UInt32\)
```cj
public static func col32(r: UInt32, g: UInt32, b: UInt32, a: UInt32): UInt32
```
将 RGBA 转换为 ImU32 颜色

参数: 

|名称|类型|描述|
|---|---|---|
|r|UInt32||
|g|UInt32||
|b|UInt32||
|a|UInt32||

### func dark\(\)
```cj
public static func dark(): Unit
```
应用暗色主题

### func getClipboardText\(\)
```cj
public static func getClipboardText(): String
```
获取剪贴板文本

### func getColorName\(Int32\)
```cj
public func getColorName(idx: Int32): String
```
获取颜色名称

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32|颜色索引|

### func getColorVec4\(Int32\)
```cj
public static func getColorVec4(idx: Int32): ImVec4
```
按 ImGuiCol 获取颜色值（Vec4）

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32||

### func getColor\(Int32\)
```cj
public func getColor(idx: Int32): ImVec4
```
获取颜色值

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32|颜色索引|

返回: 

- ImVec4 颜色值

### func getDisplaySize\(\)
```cj
public static func getDisplaySize():(Float32, Float32)
```
获取 ImGui 显示区域尺寸（IO.DisplaySize）

返回: 

- (width, height) 像素尺寸

### func getFontSize\(\)
```cj
public func getFontSize(): Float32
```
获取当前字号

返回: 

- 当前字号

### func getFont\(\)
```cj
public func getFont(): CPointer < Unit >
```
获取当前字体

返回: 

- 当前字体指针

### func getFrameCount\(\)
```cj
public static func getFrameCount(): Int32
```
获取 ImGui 帧计数

### func getScale\(\)
```cj
public static func getScale(): Float32
```
获取当前全局缩放因子

### func getStyle\(\)
```cj
public func getStyle(): CPointer < Unit >
```
获取样式对象指针

返回: 

- 样式对象指针

### func getTime\(\)
```cj
public static func getTime(): Float64
```
获取 ImGui 运行时间（秒）

### func hsvToRGB\(Float32,Float32,Float32\)
```cj
public static func hsvToRGB(h: Float32, s: Float32, v: Float32):(Float32, Float32, Float32)
```
HSV → RGB

参数: 

|名称|类型|描述|
|---|---|---|
|h|Float32||
|s|Float32||
|v|Float32||

### func light\(\)
```cj
public static func light(): Unit
```
应用亮色主题

### func loadIniFromMemory\(String\)
```cj
public func loadIniFromMemory(data: String): Unit
```
从内存加载 INI 设置

参数: 

|名称|类型|描述|
|---|---|---|
|data|String|INI 数据|

### func loadIni\(String\)
```cj
public func loadIni(filename: String): Unit
```
从文件加载 INI 设置

参数: 

|名称|类型|描述|
|---|---|---|
|filename|String|文件路径|

### func popColor\(Int32\)
```cj
public func popColor(count!: Int32 = 1): Unit
```
弹出颜色样式

参数: 

|名称|类型|描述|
|---|---|---|
|count|Int32|弹出数量|

### func popFont\(\)
```cj
public func popFont(): Unit
```
弹出字体

### func popItemFlag\(\)
```cj
public static func popItemFlag(): Unit
```
弹出控件标志

### func popItemWidth\(\)
```cj
public static func popItemWidth(): Unit
```
弹出控件宽度

### func popTextWrapPos\(\)
```cj
public static func popTextWrapPos(): Unit
```
弹出文本换行位置

### func popVar\(Int32\)
```cj
public func popVar(count!: Int32 = 1): Unit
```
弹出样式变量

参数: 

|名称|类型|描述|
|---|---|---|
|count|Int32|弹出数量|

### func pushColorU32\(Int32,UInt32\)
```cj
public func pushColorU32(idx: Int32, col: UInt32): Unit
```
压入颜色样式（UInt32 格式）

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32|颜色索引|
|col|UInt32|颜色值（IM_COL32 格式）|

### func pushColor\(Int32,Color\)
```cj
public func pushColor(idx: Int32, color: Color): Unit
```
压入颜色样式

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32|颜色索引（ImGuiCol 枚举值）|
|color|Color|颜色（RGB 分量范围 [0, 1]，alpha 默认 1.0）|

### func pushFont\(CPointer<Unit>,Float32\)
```cj
public func pushFont(font: CPointer < Unit >, fontSizeBaseUnscaled!: Float32 = 0.0): Unit
```
压入字体

参数: 

|名称|类型|描述|
|---|---|---|
|font|CPointer<Unit>|字体指针|
|fontSizeBaseUnscaled|Float32|基础字号|

### func pushItemFlag\(Int32,Bool\)
```cj
public static func pushItemFlag(flags: Int32, cond: Bool): Unit
```
压入控件标志（ImGuiItemFlags）

参数: 

|名称|类型|描述|
|---|---|---|
|flags|Int32|ImGuiItemFlags|
|cond|Bool|条件（true=生效）|

### func pushItemWidth\(Float32\)
```cj
public static func pushItemWidth(itemWidth: Float32): Unit
```
压入控件宽度（覆盖自动计算）

参数: 

|名称|类型|描述|
|---|---|---|
|itemWidth|Float32||

### func pushTextWrapPos\(Float32\)
```cj
public static func pushTextWrapPos(wrapPosX!: Float32 = 0.0f32): Unit
```
压入文本自动换行位置（0.0=窗口右边缘）

参数: 

|名称|类型|描述|
|---|---|---|
|wrapPosX|Float32||

### func pushVarFloat\(Int32,Float32\)
```cj
public func pushVarFloat(idx: Int32, val: Float32): Unit
```
压入浮点样式变量

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32|变量索引（ImGuiStyleVar 枚举值）|
|val|Float32|浮点值|

### func pushVarVec2\(Int32,Vector2\)
```cj
public func pushVarVec2(idx: Int32, value: Vector2): Unit
```
压入 Vec2 样式变量

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32|变量索引|
|value|Vector2|Vector2 值|

### func rgbToHSV\(Float32,Float32,Float32\)
```cj
public static func rgbToHSV(r: Float32, g: Float32, b: Float32):(Float32, Float32, Float32)
```
RGB → HSV

参数: 

|名称|类型|描述|
|---|---|---|
|r|Float32||
|g|Float32||
|b|Float32||

### func saveIniToMemory\(\)
```cj
public func saveIniToMemory(): String
```
保存 INI 设置到内存

返回: 

- INI 字符串

### func saveIni\(String\)
```cj
public func saveIni(filename: String): Unit
```
保存 INI 设置到文件

参数: 

|名称|类型|描述|
|---|---|---|
|filename|String|文件路径|

### func scaleAllSizes\(Float32\)
```cj
public func scaleAllSizes(scaleFactor: Float32): Unit
```
缩放所有样式尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|scaleFactor|Float32|缩放因子|

### func setClipboardText\(String\)
```cj
public static func setClipboardText(text: String): Unit
```
设置剪贴板文本

参数: 

|名称|类型|描述|
|---|---|---|
|text|String||

### func setFontGlobalScale\(Float32\)
```cj
public static func setFontGlobalScale(scale: Float32): Unit
```
设置全局字体缩放（IO.FontGlobalScale）

参数: 

|名称|类型|描述|
|---|---|---|
|scale|Float32|缩放因子（1.0 = 原始大小）|

### func showFontSelector\(String\)
```cj
public func showFontSelector(label: String): Unit
```
显示字体选择器

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签|

### func showStyleEditor\(CPointer<Unit>\)
```cj
public func showStyleEditor(ref!: CPointer < Unit >= CPointer < Unit >()): Unit
```
显示样式编辑器

参数: 

|名称|类型|描述|
|---|---|---|
|ref|CPointer<Unit>|样式引用（null=编辑全局样式）|

### func showStyleSelector\(String\)
```cj
public func showStyleSelector(label: String): Bool
```
显示样式选择器

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签|

返回: 

- 是否选择了新样式

### func showUserGuide\(\)
```cj
public func showUserGuide(): Unit
```
显示用户指南

### func u32ToVec4\(UInt32\)
```cj
public static func u32ToVec4(col: UInt32): ImVec4
```
将 ImU32 转换为 ImVec4

参数: 

|名称|类型|描述|
|---|---|---|
|col|UInt32||

### func vec4ToU32\(ImVec4\)
```cj
public static func vec4ToU32(col: ImVec4): UInt32
```
将 ImVec4 转换为 ImU32

参数: 

|名称|类型|描述|
|---|---|---|
|col|ImVec4||

