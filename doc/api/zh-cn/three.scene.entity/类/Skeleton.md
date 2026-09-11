# 类
## class Skeleton
```cj
public class Skeleton <: IPropertyBindingRoot
```
骨骼类，管理一组 Bone 及其逆矩阵

### func \_init\(\)
```cj
public func _init(): Unit
```
内部初始化：boneInverses 为空时自动计算；数量与 bones 不匹配时重建

### func calculateInverses\(\)
```cj
public func calculateInverses(): Unit
```
计算各髀骨的逆矩阵（matrixWorld.invert()）

### func clone\(\)
```cj
public func clone(): Skeleton
```
返回一个与本实例值相同的新骨骼实例

返回: 

- 新骨骼实例

### func computeBoneTexture\(\)
```cj
public func computeBoneTexture(): Unit
```
生成 boneTexture（将 boneMatrices 打包为 DataTexture），大骨骼用以省上传开销

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放本实例分配的 GPU 相关资源（boneTexture 贴图）

### func fromJSON\(HashMap<String,Any>,HashMap<String,Bone>\)
```cj
public func fromJSON(json: HashMap < String, Any >, bones: HashMap < String, Bone >): Skeleton
```
从 JSON 反序列化设置骨骼

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|序列化的骨骼 JSONbones 骨骼字典（uuid → Bone 实例）|
|bones|HashMap<String,Bone>||

返回: 

- 返回 this 以支持链式调用

### func getBoneByName\(String\)
```cj
public func getBoneByName(name: String): Option < Bone >
```
按名称查找髀骨

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|髀骨名称|

返回: 

- 找到的髀骨，或 None

### func getUuid\(\)
```cj
public func getUuid(): String
```
获取唯一标识（IPropertyBindingRoot 接口实现）

返回: 

- UUID 字符串

### func init\(ArrayList<Bone>,ArrayList<Matrix4>\)
```cj
public init(bones!: ArrayList < Bone >= ArrayList < Bone >(), boneInverses!: ArrayList < Matrix4 >= ArrayList < Matrix4 >())
```
构造一个新的骨骼

参数: 

|名称|类型|描述|
|---|---|---|
|bones|ArrayList<Bone>|髀骨数组，默认空数组boneInverses 髀骨逆矩阵数组，默认空数组（空时自动 calculateInverses）|
|boneInverses|ArrayList<Matrix4>||

### func pose\(\)
```cj
public func pose(): Unit
```
将各髀骨 pose 到初始姿势，随后重算各髀骨的 matrix/position/quaternion/scale

### func syncFromSkeletonData\(SkeletonData\)
```cj
public func syncFromSkeletonData(skelData: SkeletonData): Unit
```
从 SkeletonData 同步骨骼数据

参数: 

|名称|类型|描述|
|---|---|---|
|skelData|SkeletonData|骨骼计算数据|

### func update\(\)
```cj
public func update(): Unit
```
更新各髀骨的 offsetMatrix 并写入 boneMatrices

### var boneInverses
```cj
public var boneInverses: ArrayList < Matrix4 >
```
各髀骨的逆矩阵（世界空间 → 髀骨局部空间）

### var boneMatrices
```cj
public var boneMatrices: Option < Array < Float64 >>
```
髀骨偏移矩阵的扁平数组（每髀骨 16 个 Float64），渲染时内部使用

### var boneTexture
```cj
public var boneTexture: Option < DataTexture >
```
boneMatrices 的 GPU 贴图封装（大骨骼用，替代 boneMatrices 数组上传）

### var bones
```cj
public var bones: ArrayList < Bone >
```
髀骨数组

### var kind
```cj
public var kind: String
```
类型标签

### var uuid
```cj
public var uuid: String
```
唯一标识

