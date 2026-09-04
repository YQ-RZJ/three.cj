# 类
## class ColorSpaceDefinition
```cj
public class ColorSpaceDefinition
```
颜色空间定义，包含原色坐标、白点、传输函数、变换矩阵等信息

### func init\(Array<Float64>,Array<Float64>,String,Matrix3,Matrix3,Array<Float64>,?ColorSpaceWorkingConfig,?ColorSpaceOutputConfig\)
```cj
public init(primaries: Array < Float64 >, whitePoint: Array < Float64 >, transfer: String, toXYZ: Matrix3, fromXYZ: Matrix3, luminanceCoefficients: Array < Float64 >, workingColorSpaceConfig!:?ColorSpaceWorkingConfig = None, outputColorSpaceConfig!:?ColorSpaceOutputConfig = None)
```


参数: 

|名称|类型|描述|
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
XYZ 到 RGB 变换矩阵

### var luminanceCoefficients
```cj
public var luminanceCoefficients: Array < Float64 >
```
RGB 亮度系数

### var outputColorSpaceConfig
```cj
public var outputColorSpaceConfig:?ColorSpaceOutputConfig
```
输出颜色空间配置（可选）

### var primaries
```cj
public var primaries: Array < Float64 >
```
原色色度坐标 [rx ry gx gy bx by]

### var toXYZ
```cj
public var toXYZ: Matrix3
```
RGB 到 XYZ 变换矩阵

### var transfer
```cj
public var transfer: String
```
传输函数标识

### var whitePoint
```cj
public var whitePoint: Array < Float64 >
```
参考白点 [x y]

### var workingColorSpaceConfig
```cj
public var workingColorSpaceConfig:?ColorSpaceWorkingConfig
```
工作颜色空间配置（可选）

