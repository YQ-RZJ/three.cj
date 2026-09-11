# 类
## class GltfAnimationData
```cj
public class GltfAnimationData
```
glTF Animation 解析结果

### func init\(String,Array<GltfAnimationChannel>,Array<GltfAnimationSampler>\)
```cj
public init(name: String, channels: Array < GltfAnimationChannel >, samplers: Array < GltfAnimationSampler >)
```
创建 Animation 数据

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|动画名称|
|channels|Array<GltfAnimationChannel>|动画通道列表|
|samplers|Array<GltfAnimationSampler>|动画采样器列表|

### let channels
```cj
public let channels: Array < GltfAnimationChannel >
```
动画通道列表

### let name
```cj
public let name: String
```
动画名称

### let samplers
```cj
public let samplers: Array < GltfAnimationSampler >
```
动画采样器列表

