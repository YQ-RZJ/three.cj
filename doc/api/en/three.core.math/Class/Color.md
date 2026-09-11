# Class
## class Color
```cj
public class Color <: IBackground
```
Color class, represented by RGB components, range [0, 1]

### func \*\(Float64\)
```cj
public operator func *(s: Float64): Color
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64||

### func \+\(Color\)
```cj
public operator func +(c: Color): Color
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color||

### func addColors\(Color,Color\)
```cj
public func addColors(a: Color, b: Color): Color
```
Add RGB values of two colors and store the result

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Color|First colorb Second color|
|b|Color||

Return: 

- This instance

### func addScalar\(Float64\)
```cj
public func addScalar(s: Float64): Color
```
Add a scalar value to RGB components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func add\(Color\)
```cj
public func add(c: Color): Color
```
Add RGB values of another color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color|Color to add|

Return: 

- This instance

### func applyMatrix3\(Matrix3\)
```cj
public func applyMatrix3(m: Matrix3): Color
```
Apply 3x3 matrix transformation to color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|3x3 matrix|

Return: 

- This instance

### func clone\(\)
```cj
public func clone(): Color
```
Clone the color

Return: 

- New color instance

### func convertLinearToSRGB\(\)
```cj
public func convertLinearToSRGB(): Color
```
Convert current color from linear space to sRGB

Return: 

- This instance

### func convertSRGBToLinear\(\)
```cj
public func convertSRGBToLinear(): Color
```
Convert current color from sRGB to linear space

Return: 

- This instance

### func copyColorSpace\(Color,String,String\)
```cj
public func copyColorSpace(srcColor: Color, srcColorSpace: String, dstColorSpace: String): Color
```
Copy and convert color between color spaces

Parameter: 

|Name|Type|Describe|
|---|---|---|
|srcColor|Color|Source colorsrcColorSpace Source color spacedstColorSpace Destination color space|
|srcColorSpace|String||
|dstColorSpace|String||

Return: 

- This instance

### func copyHex\(UInt32\)
```cj
public func copyHex(hex: UInt32): Color
```
Copy color from hexadecimal value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|hex|UInt32|Hexadecimal color value|

Return: 

- This instance

### func copyLinearToSRGB\(Color\)
```cj
public func copyLinearToSRGB(color: Color): Color
```
Copy color and convert from linear space to sRGB

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Source color|

Return: 

- This instance

### func copySRGBToLinear\(Color\)
```cj
public func copySRGBToLinear(color: Color): Color
```
Copy color and convert from sRGB to linear space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Source color|

Return: 

- This instance

### func copy\(Color\)
```cj
public func copy(c: Color): Color
```
Copy values from another color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color|Source color|

Return: 

- This instance

### func equals\(Color\)
```cj
public func equals(c: Color): Bool
```
Check if equal to another color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color|Color to compare|

Return: 

- Whether equal

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Color
```
Read RGB components from array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Source arrayoffset Starting index, defaults to 0|
|offset|Int64||

Return: 

- This instance

### func fromBufferAttribute\(AttributeReader,Int64\)
```cj
public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Color
```
Read RGB components from vertex attribute (aligned with JS: Color.fromBufferAttribute)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attribute|AttributeReader|Vertex attribute (AttributeReader interface, implemented by BufferAttribute)index Vertex index|
|index|Int64||

Return: 

- This instance

### func getHSL\(HSL,String\)
```cj
public func getHSL(target: HSL, colorSpace!: String = ColorManagement.workingColorSpace): HSL
```
Get HSL values and store into target object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|HSL|Target HSL objectcolorSpace Color space|
|colorSpace|String||

Return: 

- Target HSL object

### func getHSL\(\)
```cj
public func getHSL():(Float64, Float64, Float64)
```
Get HSL values (convenience method, returns tuple)

Return: 

- HSL tuple (h, s, l)

### func getHexString\(String\)
```cj
public func getHexString(colorSpace!: String = SRGBColorSpace): String
```
Get hexadecimal string

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorSpace|String|Color space|

Return: 

- Hexadecimal color string

### func getHex\(String\)
```cj
public func getHex(colorSpace!: String = SRGBColorSpace): UInt32
```
Get hexadecimal value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorSpace|String|Color space|

Return: 

- Hexadecimal color value

### func getRGB\(Color,String\)
```cj
public func getRGB(target: Color, colorSpace!: String = ColorManagement.workingColorSpace): Color
```
Get RGB values and store into target color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Color|Target color objectcolorSpace Color space|
|colorSpace|String||

Return: 

- Target color object

### func getStyle\(String\)
```cj
public func getStyle(colorSpace!: String = SRGBColorSpace): String
```
Get CSS style string

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorSpace|String|Color space|

Return: 

- CSS style string

### func init\(UInt32\)
```cj
public init(hex: UInt32)
```


Parameter: 

|Name|Type|Describe|
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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float64||
|g|Float64||
|b|Float64||

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(r: Float64, g: Float64, b: Float64, a: Float64)
```
与 three.js 惯例对齐的 RGBA 写法使用；alpha 分量被忽略。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float64||
|g|Float64||
|b|Float64||
|a|Float64||

### func init\(Int64,Int64,Int64\)
```cj
public init(r: Int64, g: Int64, b: Int64)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Int64||
|g|Int64||
|b|Int64||

### func init\(UInt8,UInt8,UInt8\)
```cj
public init(r: UInt8, g: UInt8, b: UInt8)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|UInt8||
|g|UInt8||
|b|UInt8||

### func lerpColors\(Color,Color,Float64\)
```cj
public func lerpColors(c1: Color, c2: Color, alpha: Float64): Color
```
Linearly interpolate between two colors and store result

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c1|Color|First colorc2 Second coloralpha Interpolation factor|
|c2|Color||
|alpha|Float64||

Return: 

- This instance

### func lerpHSL\(Color,Float64\)
```cj
public func lerpHSL(c: Color, alpha: Float64): Color
```
Linearly interpolate in HSL space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color|Target coloralpha Interpolation factor|
|alpha|Float64||

Return: 

- This instance

### func lerp\(Color,Float64\)
```cj
public func lerp(c: Color, alpha: Float64): Color
```
Linearly interpolate RGB values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color|Target coloralpha Interpolation factor|
|alpha|Float64||

Return: 

- This instance

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Color
```
Multiply by a scalar value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func multiply\(Color\)
```cj
public func multiply(c: Color): Color
```
Multiply by RGB values of another color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color|Color to multiply by|

Return: 

- This instance

### func offsetHSL\(Float64,Float64,Float64\)
```cj
public func offsetHSL(h: Float64, s: Float64, l: Float64): Color
```
Offset HSL values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|h|Float64|Hue offsets Saturation offsetl Lightness offset|
|s|Float64||
|l|Float64||

Return: 

- This instance

### func setColorName\(String,String\)
```cj
public func setColorName(style: String, colorSpace!: String = SRGBColorSpace): Color
```
Set color from color name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|style|String|Color namecolorSpace Color space|
|colorSpace|String||

Return: 

- This instance

### func setFromVector3\(Vector3\)
```cj
public func setFromVector3(v: Vector3): Color
```
Set RGB components from a 3D vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|3D vector|

Return: 

- This instance

### func setHSL\(Float64,Float64,Float64,String\)
```cj
public func setHSL(h: Float64, s: Float64, l: Float64, colorSpace!: String = ColorManagement.workingColorSpace): Color
```
Set color from HSL values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|h|Float64|Hues Saturationl LightnesscolorSpace Color space|
|s|Float64||
|l|Float64||
|colorSpace|String||

Return: 

- This instance

### func setHex\(UInt32,String\)
```cj
public func setHex(hex: UInt32, colorSpace!: String = SRGBColorSpace): Color
```
Set color from hexadecimal value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|hex|UInt32|Hexadecimal color valuecolorSpace Color space|
|colorSpace|String||

Return: 

- This instance

### func setRGB\(Float64,Float64,Float64,String\)
```cj
public func setRGB(r: Float64, g: Float64, b: Float64, colorSpace!: String = ColorManagement.workingColorSpace): Color
```
Set RGB components (with specified color space)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float64|Red componentg Green componentb Blue componentcolorSpace Color space|
|g|Float64||
|b|Float64||
|colorSpace|String||

Return: 

- This instance

### func setScalar\(Float64\)
```cj
public func setScalar(s: Float64): Color
```
Set all components to the same value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func setStyle\(String,String\)
```cj
public func setStyle(style: String, colorSpace!: String = SRGBColorSpace): Color
```
Set color from CSS style string

Parameter: 

|Name|Type|Describe|
|---|---|---|
|style|String|CSS style stringcolorSpace Color space|
|colorSpace|String||

Return: 

- This instance

### func set\(Float64,Float64,Float64\)
```cj
public func set(r: Float64, g: Float64, b: Float64): Color
```
Set RGB components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Float64|Red componentg Green componentb Blue component|
|g|Float64||
|b|Float64||

Return: 

- This instance

### func sub\(Color\)
```cj
public func sub(c: Color): Color
```
Subtract RGB values of another color (result not less than 0)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color|Color to subtract|

Return: 

- This instance

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
Write RGB components to array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Target arrayoffset Starting index, defaults to 0|
|offset|Int64||

Return: 

- Array containing RGB components

### prop NAMES: HashMap < String, UInt32 >
```cj
public static prop NAMES: HashMap < String, UInt32 >
```
CSS color name to hexadecimal value mapping table (lazy initialization)

### var b
```cj
public var b: Float64
```
Blue component

### var g
```cj
public var g: Float64
```
Green component

### var r
```cj
public var r: Float64
```
Red component

