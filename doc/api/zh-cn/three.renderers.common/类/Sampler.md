# 类
## class Sampler
```cj
public open class Sampler
```
纹理采样器类

### func init\(\)
```cj
public init()
```
构造器，初始化所有采样参数为 0（使用后端默认值）

### var magFilter
```cj
public var magFilter: UInt32
```
放大过滤模式

### var minFilter
```cj
public var minFilter: UInt32
```
缩小过滤模式

### var wrapR
```cj
public var wrapR: UInt32
```
R 方向寻址模式

### var wrapS
```cj
public var wrapS: UInt32
```
S 方向寻址模式

### var wrapT
```cj
public var wrapT: UInt32
```
T 方向寻址模式

