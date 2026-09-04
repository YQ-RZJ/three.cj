# Class
## class ColorManagement
```cj
public class ColorManagement
```
Color space management class, providing color space conversion functionality

### func colorSpaceToWorking\(Color,String\)
```cj
public static func colorSpaceToWorking(color: Color, sourceColorSpace: String): Color
```
Convert color from source color space to working color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Color to convertsourceColorSpace Source color space|
|sourceColorSpace|String||

Return: 

- Converted color

### func convert\(Color,String,String\)
```cj
public static func convert(color: Color, sourceColorSpace: String, targetColorSpace: String): Color
```
Convert color between color spaces

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Color to convertsourceColorSpace Source color spacetargetColorSpace Target color space|
|sourceColorSpace|String||
|targetColorSpace|String||

Return: 

- Converted color

### func define\(HashMap<String,ColorSpaceDefinition>\)
```cj
public static func define(colorSpaces: HashMap < String, ColorSpaceDefinition >): Unit
```
Register color space definitions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorSpaces|HashMap<String,ColorSpaceDefinition>|Mapping from color space name to definition|

### func fromWorkingColorSpace\(Color,String\)
```cj
public static func fromWorkingColorSpace(color: Color, targetColorSpace: String): Color
```
Deprecated, renamed to workingToColorSpace

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color||
|targetColorSpace|String||

### func getDrawingBufferColorSpace\(String\)
```cj
public static func getDrawingBufferColorSpace(colorSpace: String): String
```
Get the drawing buffer color space of the specified color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorSpace|String|Color space identifier|

Return: 

- Drawing buffer color space

### func getLuminanceCoefficients\(Vector3,String\)
```cj
public static func getLuminanceCoefficients(target: Vector3, colorSpace!: String = workingColorSpace): Vector3
```
Get luminance coefficients of the specified color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3|Target vector for storing the resultcolorSpace Color space identifier, defaults to working color space|
|colorSpace|String||

Return: 

- Target vector

### func getMatrix\(Matrix3,String,String\)
```cj
public static func getMatrix(targetMatrix: Matrix3, sourceColorSpace: String, targetColorSpace: String): Matrix3
```
Get transformation matrix from source color space to target color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|targetMatrix|Matrix3|Target matrix for storing the resultsourceColorSpace Source color spacetargetColorSpace Target color space|
|sourceColorSpace|String||
|targetColorSpace|String||

Return: 

- Target matrix

### func getPrimaries\(String\)
```cj
public static func getPrimaries(colorSpace: String): Array < Float64 >
```
Get primary chromaticity coordinates of the specified color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorSpace|String|Color space identifier|

Return: 

- Primary chromaticity coordinates array

### func getToneMappingMode\(String\)
```cj
public static func getToneMappingMode(colorSpace: String): String
```
Get the tone mapping mode of the specified color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorSpace|String|Color space identifier|

Return: 

- Tone mapping mode ("standard" or "extended")

### func getTransfer\(String\)
```cj
public static func getTransfer(colorSpace: String): String
```
Get the transfer function of the specified color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorSpace|String|Color space identifier|

Return: 

- Transfer function identifier

### func getUnpackColorSpace\(String\)
```cj
public static func getUnpackColorSpace(colorSpace!: String = workingColorSpace): String
```
Get the unpack color space of the specified color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|colorSpace|String|Color space identifier, defaults to working color space|

Return: 

- Unpack color space

### func initDefaults\(\)
```cj
public static func initDefaults(): Unit
```
Initialize default color space definitions

### func linearToSRGB\(Float64\)
```cj
public static func linearToSRGB(c: Float64): Float64
```
Convert linear sRGB component to sRGB

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Float64|Linear sRGB color component (0.0 ~ 1.0)|

Return: 

- sRGB color component

### func sRGBToLinear\(Float64\)
```cj
public static func sRGBToLinear(c: Float64): Float64
```
Convert sRGB component to linear sRGB

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Float64|sRGB color component (0.0 ~ 1.0)|

Return: 

- Linear sRGB color component

### func toWorkingColorSpace\(Color,String\)
```cj
public static func toWorkingColorSpace(color: Color, sourceColorSpace: String): Color
```
Deprecated, renamed to colorSpaceToWorking

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color||
|sourceColorSpace|String||

### func workingToColorSpace\(Color,String\)
```cj
public static func workingToColorSpace(color: Color, targetColorSpace: String): Color
```
Convert color from working color space to target color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Color to converttargetColorSpace Target color space|
|targetColorSpace|String||

Return: 

- Converted color

### let D65
```cj
public static let D65: Array < Float64 >=[0.3127, 0.3290]
```
D65 white point

### let LINEAR\_REC709\_TO\_XYZ
```cj
public static let LINEAR_REC709_TO_XYZ: Matrix3 = Matrix3().set(0.4123908, 0.3575843, 0.1804808, 0.2126390, 0.7151687, 0.0721923, 0.0193308, 0.1191948, 0.9505322)
```
Linear Rec.709 to XYZ transformation matrix

### let REC709\_LUMINANCE\_COEFFICIENTS
```cj
public static let REC709_LUMINANCE_COEFFICIENTS: Array < Float64 >=[0.2126, 0.7152, 0.0722]
```
Rec.709 luminance coefficients

### let REC709\_PRIMARIES
```cj
public static let REC709_PRIMARIES: Array < Float64 >=[0.640, 0.330, 0.300, 0.600, 0.150, 0.060]
```
Rec.709 primary chromaticity coordinates

### let XYZ\_TO\_LINEAR\_REC709
```cj
public static let XYZ_TO_LINEAR_REC709: Matrix3 = Matrix3().set(3.2409699, - 1.5373832, - 0.4986108, - 0.9692436, 1.8759675, 0.0415551, 0.0556301, - 0.2039770, 1.0569715)
```
XYZ to linear Rec.709 transformation matrix

### var enabled
```cj
public static var enabled: Bool = true
```
Whether color space management is enabled

### var spaces
```cj
public static var spaces: HashMap < String, ColorSpaceDefinition >= HashMap < String, ColorSpaceDefinition >()
```
Registered color space definitions

### var workingColorSpace
```cj
public static var workingColorSpace: String = LinearSRGBColorSpace
```
Current working color space (default is linear sRGB)

