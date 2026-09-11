# 类
## class Fog
```cj
public class Fog
```
线性雾类，随距离线性增加不透明度

### func clone\(\)
```cj
public func clone(): Fog
```
返回一个与本实例值相同的新雾实例

返回: 

- 新雾实例

### func init\(Color,Float64,Float64\)
```cj
public init(color: Color, near!: Float64 = 1.0, far!: Float64 = 1000.0)
```
构造一个新的线性雾

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|雾的颜色near 雾起始距离，默认 1far 雾终止距离，默认 1000|
|near|Float64||
|far|Float64||

### func init\(UInt32,Float64,Float64\)
```cj
public init(hex: UInt32, near!: Float64 = 1.0, far!: Float64 = 1000.0)
```
用十六进制值构造线性雾

参数: 

|名称|类型|描述|
|---|---|---|
|hex|UInt32|十六进制颜色值near 雾起始距离，默认 1far 雾终止距离，默认 1000|
|near|Float64||
|far|Float64||

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### var color
```cj
public var color: Color
```
雾的颜色

### var far
```cj
public var far: Float64
```
雾终止距离（完全遮挡），默认 1000

### var name
```cj
public var name: String
```
用户可命名标签

### var near
```cj
public var near: Float64
```
雾起始距离（无雾），默认 1

