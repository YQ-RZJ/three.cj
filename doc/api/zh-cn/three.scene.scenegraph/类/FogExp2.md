# 类
## class FogExp2
```cj
public class FogExp2
```
指数雾类，随距离指数增长不透明度

### func clone\(\)
```cj
public func clone(): FogExp2
```
返回一个与本实例值相同的新指数雾实例

返回: 

- 新指数雾实例

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### func init\(Color,Float64\)
```cj
public init(color: Color, density!: Float64 = 0.00025)
```
构造一个新的指数雾

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|雾的颜色density 雾密度，默认 0.00025|
|density|Float64||

### func init\(UInt32,Float64\)
```cj
public init(hex: UInt32, density!: Float64 = 0.00025)
```
用十六进制值构造指数雾

参数: 

|名称|类型|描述|
|---|---|---|
|hex|UInt32|十六进制颜色值density 雾密度，默认 0.00025|
|density|Float64||

### var color
```cj
public var color: Color
```
雾的颜色

### var density
```cj
public var density: Float64
```
雾密度（指数衰减系数），默认 0.00025

### var name
```cj
public var name: String
```
用户可命名标签

