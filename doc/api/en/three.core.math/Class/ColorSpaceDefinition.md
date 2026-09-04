# Class
## class ColorSpaceDefinition
```cj
public class ColorSpaceDefinition
```
Color space definition, containing primary coordinates, white point, transfer function, transformation matrix, etc.

### func init\(Array<Float64>,Array<Float64>,String,Matrix3,Matrix3,Array<Float64>,?ColorSpaceWorkingConfig,?ColorSpaceOutputConfig\)
```cj
public init(primaries: Array < Float64 >, whitePoint: Array < Float64 >, transfer: String, toXYZ: Matrix3, fromXYZ: Matrix3, luminanceCoefficients: Array < Float64 >, workingColorSpaceConfig!:?ColorSpaceWorkingConfig = None, outputColorSpaceConfig!:?ColorSpaceOutputConfig = None)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|primaries|Array<Float64>||
|whitePoint|Array<Float64>||
|transfer|String||
|toXYZ|Matrix3||
|fromXYZ|Matrix3||
|luminanceCoefficients|Array<Float64>||
|workingColorSpaceConfig|?ColorSpaceWorkingConfig||
|outputColorSpaceConfig|?ColorSpaceOutputConfig||

### var fromXYZ
```cj
public var fromXYZ: Matrix3
```
XYZ to RGB transformation matrix

### var luminanceCoefficients
```cj
public var luminanceCoefficients: Array < Float64 >
```
RGB luminance coefficients

### var outputColorSpaceConfig
```cj
public var outputColorSpaceConfig:?ColorSpaceOutputConfig
```
Output color space configuration (optional)

### var primaries
```cj
public var primaries: Array < Float64 >
```
Primary chromaticity coordinates [rx ry gx gy bx by]

### var toXYZ
```cj
public var toXYZ: Matrix3
```
RGB to XYZ transformation matrix

### var transfer
```cj
public var transfer: String
```
Transfer function identifier

### var whitePoint
```cj
public var whitePoint: Array < Float64 >
```
Reference white point [x y]

### var workingColorSpaceConfig
```cj
public var workingColorSpaceConfig:?ColorSpaceWorkingConfig
```
Working color space configuration (optional)

