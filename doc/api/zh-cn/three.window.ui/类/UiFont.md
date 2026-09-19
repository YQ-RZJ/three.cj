# 类
## class UiFont
```cj
public class UiFont
```
字体对象（安全类型）

### func addRemapChar\(UInt16,UInt16\)
```cj
public func addRemapChar(from: UInt16, to: UInt16): Unit
```
添加字符重映射

参数: 

|名称|类型|描述|
|---|---|---|
|from|UInt16|源码点|
|to|UInt16|目标码点|

### func calcTextSize\(String,Float32,Float32\)
```cj
public func calcTextSize(text: String, fontSize!: Float32 = 0.0f32, wrapWidth!: Float32 = - 1.0f32):(Float32, Float32)
```
计算文本渲染尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|文本|
|fontSize|Float32|字体大小（0=使用默认）|
|wrapWidth|Float32|换行宽度（-1.0=不换行）|

返回: 

- (width, height)

### func getDebugName\(\)
```cj
public func getDebugName(): String
```
获取字体调试名称

返回: 

- 调试名称字符串，未加载时为空字符串

### func getFontBaked\(Float32,Float32\)
```cj
public func getFontBaked(fontSize!: Float32 = 0.0f32, density!: Float32 = 1.0f32): UiFontBaked
```
获取烘焙字体数据

参数: 

|名称|类型|描述|
|---|---|---|
|fontSize|Float32|字体大小（0=使用默认）|
|density|Float32|光栅化密度|

返回: 

- UiFontBaked 对象

### func getHandle\(\)
```cj
public func getHandle(): VoidPtr
```
获取底层 ImFont 指针（低级接口，一般场景不需要）

返回: 

- 底层 ImFont 指针

### func init\(VoidPtr\)
```cj
public init(fontPtr: VoidPtr)
```
以底层 ImFont 指针构造

参数: 

|名称|类型|描述|
|---|---|---|
|fontPtr|VoidPtr|底层 ImFont 指针|

### func isGlyphInFont\(UInt16\)
```cj
public func isGlyphInFont(codepoint: UInt16): Bool
```
指定字形是否在字体中

参数: 

|名称|类型|描述|
|---|---|---|
|codepoint|UInt16|Unicode 码点（ImWchar 范围，<= 0xFFFF）|

返回: 

- 存在返回 true

### func isLoaded\(\)
```cj
public func isLoaded(): Bool
```
字体是否已加载

返回: 

- 已加载返回 true

