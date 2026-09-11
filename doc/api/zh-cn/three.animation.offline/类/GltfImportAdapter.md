# 类
## class GltfImportAdapter
```cj
public class GltfImportAdapter
```
glTF → 离线骨骼/动画数据适配器（全部为静态方法）

### func buildRawAnimation\(GltfAnimationData,GltfSkinData,Array<Any>,Array<Any>,ArrayList<Array<UInt8>>,?RawSkeleton\)
```cj
public static func buildRawAnimation(animData: GltfAnimationData, skinData: GltfSkinData, accessors: Array < Any >, bufferViews: Array < Any >, loadedBuffers: ArrayList < Array < UInt8 >>, rawSkeleton!:?RawSkeleton = None): RawAnimation
```
由 glTF animation 与 skin 构建离线动画

参数: 

|名称|类型|描述|
|---|---|---|
|animData|GltfAnimationData|glTF 动画解析结果（通道、采样器）|
|skinData|GltfSkinData|关联的 skin（用于节点索引→关节索引映射）|
|accessors|Array<Any>|glTF accessor 数组|
|bufferViews|Array<Any>|glTF bufferView 数组|
|loadedBuffers|ArrayList<Array<UInt8>>|已加载的二进制缓冲列表|
|rawSkeleton|?RawSkeleton||

返回: 

- 填充好关键帧的 RawAnimation（已按时间排序）

### func buildRawSkeleton\(GltfSkinData,Array<Any>\)
```cj
public static func buildRawSkeleton(skinData: GltfSkinData, nodes: Array < Any >): RawSkeleton
```
由 glTF skin 与节点数据构建离线骨骼

参数: 

|名称|类型|描述|
|---|---|---|
|skinData|GltfSkinData|glTF skin 解析结果（关节节点索引、名称等）|
|nodes|Array<Any>|glTF 节点数组（元素为 HashMap<String, Any>）|

返回: 

- 填充好层级与局部休息姿势的 RawSkeleton

