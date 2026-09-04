# 类
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


参数: 

|名称|类型|描述|
|---|---|---|
|`val`|UInt16||

返回: 

- 转换后的双精度浮点数将半精度浮点数（FP16）转换为双精度浮点数

### func toHalfFloat\(Float64\)
```cj
public static func toHalfFloat(`val`: Float64): UInt16
```


参数: 

|名称|类型|描述|
|---|---|---|
|`val`|Float64||

返回: 

- 半精度浮点数的 16 位无符号整数表示将单精度/双精度浮点数转换为半精度浮点数（FP16）

