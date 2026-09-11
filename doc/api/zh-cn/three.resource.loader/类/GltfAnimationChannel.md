# 类
## class GltfAnimationChannel
```cj
public class GltfAnimationChannel
```
glTF Animation Channel 解析结果

### func init\(Int,Int,String\)
```cj
public init(sampler: Int, targetNode: Int, targetPath: String)
```
创建 Animation Channel

参数: 

|名称|类型|描述|
|---|---|---|
|sampler|Int|采样器索引|
|targetNode|Int|目标节点索引|
|targetPath|String|目标属性路径|

### let sampler
```cj
public let sampler: Int
```
采样器索引

### let targetNode
```cj
public let targetNode: Int
```
目标节点索引

### let targetPath
```cj
public let targetPath: String
```
目标属性路径（translation/rotation/scale）

