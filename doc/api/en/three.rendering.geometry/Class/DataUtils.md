# Class
## class DataUtils
```cj
public class DataUtils
```
数据工具类，提供半精度浮点数转换的静态方法

此类是 toHalfFloat 和 fromHalfFloat 函数的面向对象封装，
与 Three.js 的 DataUtils 类接口保持一致。

### func fromHalfFloat\(UInt16\)
```cj
public static func fromHalfFloat(`val`: UInt16): Float64
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|`val`|UInt16||

Return: 

- Converted double-precision floating-point numberConvert a half-precision float (FP16) to a double-precision floating-point number

### func toHalfFloat\(Float64\)
```cj
public static func toHalfFloat(`val`: Float64): UInt16
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|`val`|Float64||

Return: 

- 16-bit unsigned integer representation of the half-precision floatConvert a single/double-precision floating-point number to half-precision float (FP16)

