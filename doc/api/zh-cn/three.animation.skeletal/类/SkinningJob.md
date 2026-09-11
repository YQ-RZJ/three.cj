# 类
## class SkinningJob
```cj
public class SkinningJob
```
CPU 端顶点蒙皮 Job

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
public var input:?SkinInput
```
蒙皮输入

### var jointMatrices
```cj
public var jointMatrices: Array < Float32 >
```
关节模型空间矩阵数组

### var output
```cj
public var output: SkinOutput
```
蒙皮输出

### var weights
```cj
public var weights:?SkinWeights
```
蒙皮权重

