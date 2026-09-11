# 类
## class GpuSkinningJob
```cj
public class GpuSkinningJob
```
GPU 蒙皮 Job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
执行蒙皮

返回: 

- true 表示成功

### func validate\(\)
```cj
public func validate(): Bool
```
验证输入合法性

### var input
```cj
public var input:?GpuSkinningInput
```
蒙皮输入

### var mode
```cj
public var mode: SkinningMode
```
蒙皮模式

### var output
```cj
public var output:?GpuSkinningOutput
```
蒙皮输出

