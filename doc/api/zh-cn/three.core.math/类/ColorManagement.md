# 类
## class ColorManagement
```cj
public class ColorManagement
```
颜色空间管理类，提供颜色空间之间的转换功能

### func colorSpaceToWorking\(Color,String\)
```cj
public static func colorSpaceToWorking(color: Color, sourceColorSpace: String): Color
```
将颜色从源颜色空间转换到工作颜色空间

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|要转换的颜色sourceColorSpace 源颜色空间|
|sourceColorSpace|String||

返回: 

- 转换后的颜色

### func convert\(Color,String,String\)
```cj
public static func convert(color: Color, sourceColorSpace: String, targetColorSpace: String): Color
```
在颜色空间之间转换颜色

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|要转换的颜色sourceColorSpace 源颜色空间targetColorSpace 目标颜色空间|
|sourceColorSpace|String||
|targetColorSpace|String||

返回: 

- 转换后的颜色

### func define\(HashMap<String,ColorSpaceDefinition>\)
```cj
public static func define(colorSpaces: HashMap < String, ColorSpaceDefinition >): Unit
```
注册颜色空间定义

参数: 

|名称|类型|描述|
|---|---|---|
|colorSpaces|HashMap<String,ColorSpaceDefinition>|颜色空间名称到定义的映射|

### func fromWorkingColorSpace\(Color,String\)
```cj
public static func fromWorkingColorSpace(color: Color, targetColorSpace: String): Color
```
已弃用，已重命名为 workingToColorSpace

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color||
|targetColorSpace|String||

### func getDrawingBufferColorSpace\(String\)
```cj
public static func getDrawingBufferColorSpace(colorSpace: String): String
```
获取指定颜色空间的绘图缓冲区颜色空间

参数: 

|名称|类型|描述|
|---|---|---|
|colorSpace|String|颜色空间标识|

返回: 

- 绘图缓冲区颜色空间

### func getLuminanceCoefficients\(Vector3,String\)
```cj
public static func getLuminanceCoefficients(target: Vector3, colorSpace!: String = workingColorSpace): Vector3
```
获取指定颜色空间的亮度系数

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3|目标向量，用于存储结果colorSpace 颜色空间标识，默认为工作颜色空间|
|colorSpace|String||

返回: 

- 目标向量

### func getMatrix\(Matrix3,String,String\)
```cj
public static func getMatrix(targetMatrix: Matrix3, sourceColorSpace: String, targetColorSpace: String): Matrix3
```
获取从源颜色空间到目标颜色空间的变换矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|targetMatrix|Matrix3|目标矩阵，用于存储结果sourceColorSpace 源颜色空间targetColorSpace 目标颜色空间|
|sourceColorSpace|String||
|targetColorSpace|String||

返回: 

- 目标矩阵

### func getPrimaries\(String\)
```cj
public static func getPrimaries(colorSpace: String): Array < Float64 >
```
获取指定颜色空间的原色色度坐标

参数: 

|名称|类型|描述|
|---|---|---|
|colorSpace|String|颜色空间标识|

返回: 

- 原色色度坐标数组

### func getToneMappingMode\(String\)
```cj
public static func getToneMappingMode(colorSpace: String): String
```
获取指定颜色空间的色调映射模式

参数: 

|名称|类型|描述|
|---|---|---|
|colorSpace|String|颜色空间标识|

返回: 

- 色调映射模式（"standard" 或 "extended"）

### func getTransfer\(String\)
```cj
public static func getTransfer(colorSpace: String): String
```
获取指定颜色空间的传输函数

参数: 

|名称|类型|描述|
|---|---|---|
|colorSpace|String|颜色空间标识|

返回: 

- 传输函数标识

### func getUnpackColorSpace\(String\)
```cj
public static func getUnpackColorSpace(colorSpace!: String = workingColorSpace): String
```
获取指定颜色空间的解包颜色空间

参数: 

|名称|类型|描述|
|---|---|---|
|colorSpace|String|颜色空间标识，默认为工作颜色空间|

返回: 

- 解包颜色空间

### func initDefaults\(\)
```cj
public static func initDefaults(): Unit
```
初始化默认颜色空间定义

### func linearToSRGB\(Float64\)
```cj
public static func linearToSRGB(c: Float64): Float64
```
线性 sRGB 分量转 sRGB

参数: 

|名称|类型|描述|
|---|---|---|
|c|Float64|线性 sRGB 颜色分量（0.0 ~ 1.0）|

返回: 

- sRGB 颜色分量

### func sRGBToLinear\(Float64\)
```cj
public static func sRGBToLinear(c: Float64): Float64
```
sRGB 分量转线性 sRGB

参数: 

|名称|类型|描述|
|---|---|---|
|c|Float64|sRGB 颜色分量（0.0 ~ 1.0）|

返回: 

- 线性 sRGB 颜色分量

### func toWorkingColorSpace\(Color,String\)
```cj
public static func toWorkingColorSpace(color: Color, sourceColorSpace: String): Color
```
已弃用，已重命名为 colorSpaceToWorking

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color||
|sourceColorSpace|String||

### func workingToColorSpace\(Color,String\)
```cj
public static func workingToColorSpace(color: Color, targetColorSpace: String): Color
```
将颜色从工作颜色空间转换到目标颜色空间

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|要转换的颜色targetColorSpace 目标颜色空间|
|targetColorSpace|String||

返回: 

- 转换后的颜色

### let D65
```cj
public static let D65: Array < Float64 >=[0.3127, 0.3290]
```
D65 白点

### let LINEAR\_REC709\_TO\_XYZ
```cj
public static let LINEAR_REC709_TO_XYZ: Matrix3 = Matrix3().set(0.4123908, 0.3575843, 0.1804808, 0.2126390, 0.7151687, 0.0721923, 0.0193308, 0.1191948, 0.9505322)
```
线性 Rec.709 到 XYZ 变换矩阵

### let REC709\_LUMINANCE\_COEFFICIENTS
```cj
public static let REC709_LUMINANCE_COEFFICIENTS: Array < Float64 >=[0.2126, 0.7152, 0.0722]
```
Rec.709 亮度系数

### let REC709\_PRIMARIES
```cj
public static let REC709_PRIMARIES: Array < Float64 >=[0.640, 0.330, 0.300, 0.600, 0.150, 0.060]
```
Rec.709 原色色度坐标

### let XYZ\_TO\_LINEAR\_REC709
```cj
public static let XYZ_TO_LINEAR_REC709: Matrix3 = Matrix3().set(3.2409699, - 1.5373832, - 0.4986108, - 0.9692436, 1.8759675, 0.0415551, 0.0556301, - 0.2039770, 1.0569715)
```
XYZ 到线性 Rec.709 变换矩阵

### var enabled
```cj
public static var enabled: Bool = true
```
是否启用颜色空间管理

### var spaces
```cj
public static var spaces: HashMap < String, ColorSpaceDefinition >= HashMap < String, ColorSpaceDefinition >()
```
已注册的颜色空间定义

### var workingColorSpace
```cj
public static var workingColorSpace: String = LinearSRGBColorSpace
```
当前工作颜色空间（默认为线性 sRGB）

