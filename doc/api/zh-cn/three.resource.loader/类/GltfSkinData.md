# 类
## class GltfSkinData
```cj
public class GltfSkinData
```
glTF Skin 解析结果

### func init\(String,Array<Array<Float64>>,Int,Array<Int>\)
```cj
public init(name: String, inverseBindMatrices: Array < Array < Float64 >>, skeletonRoot: Int, joints: Array < Int >)
```
创建 Skin 数据

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|蒙皮名称|
|inverseBindMatrices|Array<Array<Float64>>|逆绑定矩阵列表|
|skeletonRoot|Int|骨骼根节点索引|
|joints|Array<Int>|关节节点索引列表|

### let inverseBindMatrices
```cj
public let inverseBindMatrices: Array < Array < Float64 >>
```
逆绑定矩阵列表

### let joints
```cj
public let joints: Array < Int >
```
关节节点索引列表

### let name
```cj
public let name: String
```
蒙皮名称

### let skeletonRoot
```cj
public let skeletonRoot: Int
```
骨骼根节点索引

