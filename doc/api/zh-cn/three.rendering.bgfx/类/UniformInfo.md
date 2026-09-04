# 类
## class UniformInfo
```cj
public class UniformInfo
```
Uniform 信息

### func init\(\)
```cj
public init()
```


### var handle
```cj
public var handle: UniformHandle = INVALID_UNIFORM_HANDLE
```
bgfx uniform 句柄（Box 包装）

### var name
```cj
public var name: String = ""
```
uniform 名称

### var num
```cj
public var num: Int64 = 1
```
数组大小

### var uniformType
```cj
public var uniformType: UInt32 = 0u32
```
uniform 类型（vec4/mat3/mat4/sampler 等）

