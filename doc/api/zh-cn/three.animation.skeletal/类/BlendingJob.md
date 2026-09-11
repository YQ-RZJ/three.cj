# 类
## class BlendingJob
```cj
public class BlendingJob
```
多动画混合 Job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
执行混合

返回: 

- true 表示成功

### func validate\(\)
```cj
public func validate(): Bool
```
验证输入合法性

### var additiveLayers
```cj
public var additiveLayers: ArrayList < BlendLayer >
```
叠加混合层列表

### var layers
```cj
public var layers: ArrayList < BlendLayer >
```
普通混合层列表

### var output
```cj
public var output: Array < SoaTransform >
```
输出缓冲区

### var restPose
```cj
public var restPose: Array < SoaTransform >
```
骨骼休息姿势

### var threshold
```cj
public var threshold: Float32
```
权重阈值：累积权重低于此值的关节使用 rest pose

