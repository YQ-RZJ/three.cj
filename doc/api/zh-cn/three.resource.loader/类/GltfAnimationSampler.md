# 类
## class GltfAnimationSampler
```cj
public class GltfAnimationSampler
```
glTF Animation Sampler 解析结果

### func init\(Int,Int,String\)
```cj
public init(input: Int, output: Int, interpolation: String)
```
创建 Animation Sampler

参数: 

|名称|类型|描述|
|---|---|---|
|input|Int|时间输入 accessor 索引|
|output|Int|值输出 accessor 索引|
|interpolation|String|插值方式|

### let input
```cj
public let input: Int
```
时间输入 accessor 索引

### let interpolation
```cj
public let interpolation: String
```
插值方式（LINEAR/STEP/CUBICSPLINE）

### let output
```cj
public let output: Int
```
值输出 accessor 索引

