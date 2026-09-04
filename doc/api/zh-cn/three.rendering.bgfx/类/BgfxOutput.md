# 类
## class BgfxOutput
```cj
public class BgfxOutput
```
bgfx 输出处理

### func getOutputColorSpace\(\)
```cj
public func getOutputColorSpace(): Int64
```
获取输出颜色空间

返回: 

- 颜色空间值

### func getToneMapping\(\)
```cj
public func getToneMapping(): Int64
```
获取色调映射模式

返回: 

- 色调映射模式值

### func init\(\)
```cj
public init()
```


### func needsToneMapping\(\)
```cj
public func needsToneMapping(): Bool
```
检查是否需要色调映射

返回: 

- 是否需要色调映射

### func setOutputColorSpace\(Int64\)
```cj
public func setOutputColorSpace(value: Int64): Unit
```
设置输出颜色空间

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|颜色空间值|

### func setToneMapping\(Int64\)
```cj
public func setToneMapping(value: Int64): Unit
```
设置色调映射模式

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|色调映射模式值|

