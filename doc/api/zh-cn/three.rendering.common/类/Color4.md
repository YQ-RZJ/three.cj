# 类
## class Color4
```cj
public open class Color4
```
RGBA 四通道颜色表示

### func init\(\)
```cj
public init()
```
构造默认白色（1, 1, 1, 1）

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(r: Float64, g: Float64, b: Float64, a: Float64)
```
构造指定 RGBA 值的颜色

参数: 

|名称|类型|描述|
|---|---|---|
|r|Float64|红色通道g 绿色通道b 蓝色通道a 透明度通道|
|g|Float64||
|b|Float64||
|a|Float64||

### func toUint32\(\)
```cj
public func toUint32(): UInt32
```
将 RGBA 转换为 UInt32 格式（R<<24 | G<<16 | B<<8 | A）

返回: 

- UInt32 颜色值

### var a
```cj
public var a: Float64
```
透明度通道

### var b
```cj
public var b: Float64
```
蓝色通道

### var g
```cj
public var g: Float64
```
绿色通道

### var r
```cj
public var r: Float64
```
红色通道

