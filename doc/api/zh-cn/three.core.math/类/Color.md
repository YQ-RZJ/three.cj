# 类
## class Color
```cj
public class Color <: IBackground
```
颜色类，使用 RGB 分量表示，范围 [0, 1]

### func \*\(Float64\)
```cj
public operator func *(s: Float64): Color
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64||

### func \+\(Color\)
```cj
public operator func +(c: Color): Color
```


参数: 

|名称|类型|描述|
|---|---|---|
|c|Color||

### func addColors\(Color,Color\)
```cj
public func addColors(a: Color, b: Color): Color
```
添加两个颜色的 RGB 值并存储结果

参数: 

|名称|类型|描述|
|---|---|---|
|a|Color|第一个颜色b 第二个颜色|
|b|Color||

返回: 

- 当前实例

### func addScalar\(Float64\)
```cj
public func addScalar(s: Float64): Color
```
给 RGB 分量添加标量值

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func add\(Color\)
```cj
public func add(c: Color): Color
```
添加另一个颜色的 RGB 值

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color|要添加的颜色|

返回: 

- 当前实例

### func applyMatrix3\(Matrix3\)
```cj
public func applyMatrix3(m: Matrix3): Color
```
应用 3x3 矩阵变换颜色

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|3x3 矩阵|

返回: 

- 当前实例

### func clone\(\)
```cj
public func clone(): Color
```
克隆颜色

返回: 

- 新的颜色实例

### func convertLinearToSRGB\(\)
```cj
public func convertLinearToSRGB(): Color
```
将当前颜色从线性空间转换到 sRGB

返回: 

- 当前实例

### func convertSRGBToLinear\(\)
```cj
public func convertSRGBToLinear(): Color
```
将当前颜色从 sRGB 转换到线性空间

返回: 

- 当前实例

### func copyColorSpace\(Color,String,String\)
```cj
public func copyColorSpace(srcColor: Color, srcColorSpace: String, dstColorSpace: String): Color
```
在颜色空间之间复制转换颜色

参数: 

|名称|类型|描述|
|---|---|---|
|srcColor|Color|源颜色srcColorSpace 源颜色空间dstColorSpace 目标颜色空间|
|srcColorSpace|String||
|dstColorSpace|String||

返回: 

- 当前实例

### func copyHex\(UInt32\)
```cj
public func copyHex(hex: UInt32): Color
```
从十六进制值复制颜色

参数: 

|名称|类型|描述|
|---|---|---|
|hex|UInt32|十六进制颜色值|

返回: 

- 当前实例

### func copyLinearToSRGB\(Color\)
```cj
public func copyLinearToSRGB(color: Color): Color
```
复制颜色并从线性空间转换到 sRGB

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|源颜色|

返回: 

- 当前实例

### func copySRGBToLinear\(Color\)
```cj
public func copySRGBToLinear(color: Color): Color
```
复制颜色并从 sRGB 转换到线性空间

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|源颜色|

返回: 

- 当前实例

### func copy\(Color\)
```cj
public func copy(c: Color): Color
```
复制另一个颜色的值

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color|源颜色|

返回: 

- 当前实例

### func equals\(Color\)
```cj
public func equals(c: Color): Bool
```
判断是否与另一个颜色相等

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color|比较的颜色|

返回: 

- 是否相等

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Color
```
从数组读取 RGB 分量

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|源数组offset 起始索引，默认为 0|
|offset|Int64||

返回: 

- 当前实例

### func fromBufferAttribute\(AttributeReader,Int64\)
```cj
public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Color
```
从顶点属性读取 RGB 分量

参数: 

|名称|类型|描述|
|---|---|---|
|attribute|AttributeReader|顶点属性（AttributeReader 接口，由 BufferAttribute 实现）index 顶点索引|
|index|Int64||

返回: 

- 当前实例

### func getHSL\(HSL,String\)
```cj
public func getHSL(target: HSL, colorSpace!: String = ColorManagement.workingColorSpace): HSL
```
获取 HSL 值并存储到目标对象

参数: 

|名称|类型|描述|
|---|---|---|
|target|HSL|目标 HSL 对象colorSpace 颜色空间|
|colorSpace|String||

返回: 

- 目标 HSL 对象

### func getHSL\(\)
```cj
public func getHSL():(Float64, Float64, Float64)
```
获取 HSL 值（便捷方法，返回元组）

返回: 

- HSL 元组 (h, s, l)

### func getHexString\(String\)
```cj
public func getHexString(colorSpace!: String = SRGBColorSpace): String
```
获取十六进制字符串

参数: 

|名称|类型|描述|
|---|---|---|
|colorSpace|String|颜色空间|

返回: 

- 十六进制颜色字符串

### func getHex\(String\)
```cj
public func getHex(colorSpace!: String = SRGBColorSpace): UInt32
```
获取十六进制值

参数: 

|名称|类型|描述|
|---|---|---|
|colorSpace|String|颜色空间|

返回: 

- 十六进制颜色值

### func getRGB\(Color,String\)
```cj
public func getRGB(target: Color, colorSpace!: String = ColorManagement.workingColorSpace): Color
```
获取 RGB 值并存储到目标颜色

参数: 

|名称|类型|描述|
|---|---|---|
|target|Color|目标颜色对象colorSpace 颜色空间|
|colorSpace|String||

返回: 

- 目标颜色对象

### func getStyle\(String\)
```cj
public func getStyle(colorSpace!: String = SRGBColorSpace): String
```
获取 CSS 样式字符串

参数: 

|名称|类型|描述|
|---|---|---|
|colorSpace|String|颜色空间|

返回: 

- CSS 样式字符串

### func init\(UInt32\)
```cj
public init(hex: UInt32)
```


参数: 

|名称|类型|描述|
|---|---|---|
|hex|UInt32||

### func init\(\)
```cj
public init()
```


### func init\(Float64,Float64,Float64\)
```cj
public init(r: Float64, g: Float64, b: Float64)
```


参数: 

|名称|类型|描述|
|---|---|---|
|r|Float64||
|g|Float64||
|b|Float64||

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(r: Float64, g: Float64, b: Float64, a: Float64)
```
与 three.js 惯例对齐的 RGBA 写法使用；alpha 分量被忽略。

参数: 

|名称|类型|描述|
|---|---|---|
|r|Float64||
|g|Float64||
|b|Float64||
|a|Float64||

### func init\(Int64,Int64,Int64\)
```cj
public init(r: Int64, g: Int64, b: Int64)
```


参数: 

|名称|类型|描述|
|---|---|---|
|r|Int64||
|g|Int64||
|b|Int64||

### func init\(UInt8,UInt8,UInt8\)
```cj
public init(r: UInt8, g: UInt8, b: UInt8)
```


参数: 

|名称|类型|描述|
|---|---|---|
|r|UInt8||
|g|UInt8||
|b|UInt8||

### func lerpColors\(Color,Color,Float64\)
```cj
public func lerpColors(c1: Color, c2: Color, alpha: Float64): Color
```
在两个颜色之间线性插值并存储结果

参数: 

|名称|类型|描述|
|---|---|---|
|c1|Color|第一个颜色c2 第二个颜色alpha 插值因子|
|c2|Color||
|alpha|Float64||

返回: 

- 当前实例

### func lerpHSL\(Color,Float64\)
```cj
public func lerpHSL(c: Color, alpha: Float64): Color
```
在 HSL 空间线性插值

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color|目标颜色alpha 插值因子|
|alpha|Float64||

返回: 

- 当前实例

### func lerp\(Color,Float64\)
```cj
public func lerp(c: Color, alpha: Float64): Color
```
线性插值 RGB 值

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color|目标颜色alpha 插值因子|
|alpha|Float64||

返回: 

- 当前实例

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Color
```
乘以标量值

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func multiply\(Color\)
```cj
public func multiply(c: Color): Color
```
乘以另一个颜色的 RGB 值

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color|要乘以的颜色|

返回: 

- 当前实例

### func offsetHSL\(Float64,Float64,Float64\)
```cj
public func offsetHSL(h: Float64, s: Float64, l: Float64): Color
```
偏移 HSL 值

参数: 

|名称|类型|描述|
|---|---|---|
|h|Float64|色相偏移量s 饱和度偏移量l 亮度偏移量|
|s|Float64||
|l|Float64||

返回: 

- 当前实例

### func setColorName\(String,String\)
```cj
public func setColorName(style: String, colorSpace!: String = SRGBColorSpace): Color
```
从颜色名称设置颜色

参数: 

|名称|类型|描述|
|---|---|---|
|style|String|颜色名称colorSpace 颜色空间|
|colorSpace|String||

返回: 

- 当前实例

### func setFromVector3\(Vector3\)
```cj
public func setFromVector3(v: Vector3): Color
```
从三维向量设置 RGB 分量

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|三维向量|

返回: 

- 当前实例

### func setHSL\(Float64,Float64,Float64,String\)
```cj
public func setHSL(h: Float64, s: Float64, l: Float64, colorSpace!: String = ColorManagement.workingColorSpace): Color
```
从 HSL 值设置颜色

参数: 

|名称|类型|描述|
|---|---|---|
|h|Float64|色相s 饱和度l 亮度colorSpace 颜色空间|
|s|Float64||
|l|Float64||
|colorSpace|String||

返回: 

- 当前实例

### func setHex\(UInt32,String\)
```cj
public func setHex(hex: UInt32, colorSpace!: String = SRGBColorSpace): Color
```
从十六进制值设置颜色

参数: 

|名称|类型|描述|
|---|---|---|
|hex|UInt32|十六进制颜色值colorSpace 颜色空间|
|colorSpace|String||

返回: 

- 当前实例

### func setRGB\(Float64,Float64,Float64,String\)
```cj
public func setRGB(r: Float64, g: Float64, b: Float64, colorSpace!: String = ColorManagement.workingColorSpace): Color
```
设置 RGB 分量（指定颜色空间）

参数: 

|名称|类型|描述|
|---|---|---|
|r|Float64|红色分量g 绿色分量b 蓝色分量colorSpace 颜色空间|
|g|Float64||
|b|Float64||
|colorSpace|String||

返回: 

- 当前实例

### func setScalar\(Float64\)
```cj
public func setScalar(s: Float64): Color
```
将所有分量设置为相同值

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func setStyle\(String,String\)
```cj
public func setStyle(style: String, colorSpace!: String = SRGBColorSpace): Color
```
从 CSS 样式字符串设置颜色

参数: 

|名称|类型|描述|
|---|---|---|
|style|String|CSS 样式字符串colorSpace 颜色空间|
|colorSpace|String||

返回: 

- 当前实例

### func set\(Float64,Float64,Float64\)
```cj
public func set(r: Float64, g: Float64, b: Float64): Color
```
设置 RGB 分量

参数: 

|名称|类型|描述|
|---|---|---|
|r|Float64|红色分量g 绿色分量b 蓝色分量|
|g|Float64||
|b|Float64||

返回: 

- 当前实例

### func sub\(Color\)
```cj
public func sub(c: Color): Color
```
减去另一个颜色的 RGB 值（结果不低于 0）

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color|要减去的颜色|

返回: 

- 当前实例

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
将 RGB 分量写入数组

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|目标数组offset 起始索引，默认为 0|
|offset|Int64||

返回: 

- 包含 RGB 分量的数组

### prop NAMES: HashMap < String, UInt32 >
```cj
public static prop NAMES: HashMap < String, UInt32 >
```
CSS 颜色名称到十六进制值的映射表（延迟初始化）

### var b
```cj
public var b: Float64
```
蓝色分量

### var g
```cj
public var g: Float64
```
绿色分量

### var r
```cj
public var r: Float64
```
红色分量

