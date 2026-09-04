# 类
## class BlendMode
```cj
public open class BlendMode
```
混合模式描述，定义颜色混合方程和因子

### func init\(\)
```cj
public init()
```
构造默认混合模式（全部为零）

### func init\(Int64,Int64,Int64,Int64\)
```cj
public init(mode: Int64, equation: Int64, srcFactor: Int64, dstFactor: Int64)
```
构造指定参数的混合模式

参数: 

|名称|类型|描述|
|---|---|---|
|mode|Int64|混合模式equation 混合方程srcFactor 源混合因子dstFactor 目标混合因子|
|equation|Int64||
|srcFactor|Int64||
|dstFactor|Int64||

### var dstFactor
```cj
public var dstFactor: Int64
```
目标混合因子

### var equation
```cj
public var equation: Int64
```
混合方程

### var mode
```cj
public var mode: Int64
```
混合模式

### var srcFactor
```cj
public var srcFactor: Int64
```
源混合因子

