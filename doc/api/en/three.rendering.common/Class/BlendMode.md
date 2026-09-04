# Class
## class BlendMode
```cj
public open class BlendMode
```
Blend mode description, defining color blending equation and factors

### func init\(\)
```cj
public init()
```
Constructs a default blend mode (all zeros)

### func init\(Int64,Int64,Int64,Int64\)
```cj
public init(mode: Int64, equation: Int64, srcFactor: Int64, dstFactor: Int64)
```
Constructs a blend mode with specified parameters

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mode|Int64|Blend modeequation Blend equationsrcFactor Source blend factordstFactor Destination blend factor|
|equation|Int64||
|srcFactor|Int64||
|dstFactor|Int64||

### var dstFactor
```cj
public var dstFactor: Int64
```
Destination blend factor

### var equation
```cj
public var equation: Int64
```
Blend equation

### var mode
```cj
public var mode: Int64
```
Blend mode

### var srcFactor
```cj
public var srcFactor: Int64
```
Source blend factor

