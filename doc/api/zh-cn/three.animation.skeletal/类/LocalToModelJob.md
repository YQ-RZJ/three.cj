# 类
## class LocalToModelJob
```cj
public class LocalToModelJob
```
局部→模型空间转换 Job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
执行局部→模型空间转换

返回: 

- true 表示成功

### func validate\(\)
```cj
public func validate(): Bool
```
验证输入合法性

### var fromExcluded
```cj
public var fromExcluded: Bool
```
是否排除 from 关节本身（只更新其子关节）

### var from
```cj
public var from: Int
```
更新起始关节索引（默认 0 = 全部更新）

### var input
```cj
public var input: Array < SoaTransform >
```
输入：局部空间变换

### var output
```cj
public var output: Array < Matrix4F >
```
输出：模型空间 4x4 矩阵

### var rootMatrix
```cj
public var rootMatrix:?Matrix4F
```
可选的根矩阵（应用到所有关节的模型空间结果上）

### var skeleton
```cj
public var skeleton:?SkeletonData
```
骨骼层级

### var to
```cj
public var to: Int
```
更新结束关节索引（不包含，<= 0 表示更新到最后一个关节）

