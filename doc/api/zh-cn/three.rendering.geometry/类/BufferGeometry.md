# 类
## class BufferGeometry
```cj
public open class BufferGeometry <: ILoadResult & IGeometryProvider
```
缓冲几何体类：描述几何体数据（顶点/法线/UV 等属性）

### func addGroup\(Int64,Int64,Int64\)
```cj
public func addGroup(start: Int64, count: Int64, materialIndex!: Int64 = 0): Unit
```
向此几何体添加绘制组

参数: 

|名称|类型|描述|
|---|---|---|
|start|Int64|此绘制调用中的第一个元素count 此组包含多少顶点（或索引）materialIndex 使用的材质数组索引，默认为 0|
|count|Int64||
|materialIndex|Int64||

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): BufferGeometry
```
将给定的 4x4 变换矩阵应用到几何体

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Matrix4|要应用的 4x4 矩阵|

返回: 

- 当前实例的引用

### func applyQuaternion\(Quaternion\)
```cj
public func applyQuaternion(q: Quaternion): BufferGeometry
```
将给定的四元数表示的旋转应用到几何体

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|要应用的四元数|

返回: 

- 当前实例的引用

### func center\(\)
```cj
public func center(): BufferGeometry
```
基于包围盒将几何体居中

返回: 

- 当前实例的引用

### func clearGroups\(\)
```cj
public func clearGroups(): Unit
```
清除所有绘制组

### func clone\(\)
```cj
public func clone(): BufferGeometry
```
返回从此实例复制值的新几何体

返回: 

- 此实例的克隆

### func computeBoundingBox\(\)
```cj
public func computeBoundingBox(): Unit
```
计算几何体的包围盒并更新 boundingBox 成员

### func computeBoundingSphere\(\)
```cj
public func computeBoundingSphere(): Unit
```
计算几何体的包围球并更新 boundingSphere 成员

### func computeTangents\(\)
```cj
public func computeTangents(): Unit
```
计算并添加此几何体的切线属性

### func computeVertexNormals\(\)
```cj
public func computeVertexNormals(): Unit
```
为给定顶点数据计算顶点法线

### func copy\(BufferGeometry\)
```cj
public func copy(source: BufferGeometry): BufferGeometry
```
将给定几何体的值复制到此实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|BufferGeometry|要复制的几何体|

返回: 

- 当前实例的引用

### func deleteAttribute\(String\)
```cj
public func deleteAttribute(name: String): BufferGeometry
```
删除指定名称的属性

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|属性名|

返回: 

- 当前实例的引用

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放此实例分配的 GPU 相关资源

### func getAttributeReader\(String\)
```cj
public func getAttributeReader(name: String): Option < AttributeReader >
```
按名称获取顶点属性（接口实现，转为 AttributeReader 只读视图）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func getAttribute\(String\)
```cj
public func getAttribute(name: String):?BufferAttribute
```
返回指定名称的属性

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|属性名|

返回: 

- 对应的缓冲区属性；若不存在返回 None

### func getBoundingBox\(\)
```cj
public func getBoundingBox(): Option < Box3 >
```
获取包围盒（接口实现，返回当前 boundingBox）

### func getBoundingSphere\(\)
```cj
public func getBoundingSphere(): Option < Sphere >
```
获取包围球（接口实现，返回当前 boundingSphere）

### func getIndex\(\)
```cj
public func getIndex():?BufferAttribute
```
返回此几何体的索引

返回: 

- 索引缓冲区属性；若未定义索引则返回 None

### func getIndirect\(\)
```cj
public func getIndirect():?BufferAttribute
```
返回此几何体的间接绘制属性

返回: 

- 间接绘制属性；若未定义则返回 None

### func getParameters\(\)
```cj
public open func getParameters():?HashMap < String, Any >
```
返回本几何体的生成参数

返回: 

- 生成参数 HashMap，无参数时返回 None

### func hasAttribute\(String\)
```cj
public func hasAttribute(name: String): Bool
```
返回此几何体是否具有指定名称的属性

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|属性名|

返回: 

- 是否存在该属性

### func init\(\)
```cj
public init()
```
构造新的缓冲几何体

### func lookAt\(Vector3\)
```cj
public func lookAt(vector: Vector3): BufferGeometry
```
旋转几何体使其面向 3D 空间中的某点

参数: 

|名称|类型|描述|
|---|---|---|
|vector|Vector3|目标点|

返回: 

- 当前实例的引用

### func normalizeNormals\(\)
```cj
public func normalizeNormals(): Unit
```
确保几何体中每个法线向量长度为 1

### func rotateX\(Float64\)
```cj
public func rotateX(angle: Float64): BufferGeometry
```
绕世界 X 轴旋转几何体

参数: 

|名称|类型|描述|
|---|---|---|
|angle|Float64|旋转角度（弧度）|

返回: 

- 当前实例的引用

### func rotateY\(Float64\)
```cj
public func rotateY(angle: Float64): BufferGeometry
```
绕世界 Y 轴旋转几何体

参数: 

|名称|类型|描述|
|---|---|---|
|angle|Float64|旋转角度（弧度）|

返回: 

- 当前实例的引用

### func rotateZ\(Float64\)
```cj
public func rotateZ(angle: Float64): BufferGeometry
```
绕世界 Z 轴旋转几何体

参数: 

|名称|类型|描述|
|---|---|---|
|angle|Float64|旋转角度（弧度）|

返回: 

- 当前实例的引用

### func scale\(Float64,Float64,Float64\)
```cj
public func scale(x: Float64, y: Float64, z: Float64): BufferGeometry
```
缩放几何体

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 方向缩放y y 方向缩放z z 方向缩放|
|y|Float64||
|z|Float64||

返回: 

- 当前实例的引用

### func setAttribute\(String,BufferAttribute\)
```cj
public func setAttribute(name: String, attribute: BufferAttribute): BufferGeometry
```
为指定名称设置给定属性

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|属性名attribute 要设置的属性|
|attribute|BufferAttribute||

返回: 

- 当前实例的引用

### func setDrawRange\(Int64,Int64\)
```cj
public func setDrawRange(start: Int64, count: Int64): Unit
```
设置此几何体的绘制范围

参数: 

|名称|类型|描述|
|---|---|---|
|start|Int64|非索引几何体的第一个顶点，否则为第一个三角形索引count 非索引几何体要渲染的顶点数，或索引几何体要渲染的索引数|
|count|Int64||

### func setFromPoints\(Array<Vector3>\)
```cj
public func setFromPoints(points: Array < Vector3 >): BufferGeometry
```
通过给定点的数组定义几何体（创建 position 属性）

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|点数组|

返回: 

- 当前实例的引用

### func setIndex\(BufferAttribute\)
```cj
public func setIndex(index: BufferAttribute): BufferGeometry
```
设置此几何体的索引

参数: 

|名称|类型|描述|
|---|---|---|
|index|BufferAttribute|索引缓冲区属性|

返回: 

- 当前实例的引用

### func setIndirect\(BufferAttribute,Int64\)
```cj
public func setIndirect(indirect: BufferAttribute, indirectOffset!: Int64 = 0): BufferGeometry
```
设置此几何体的间接绘制属性

参数: 

|名称|类型|描述|
|---|---|---|
|indirect|BufferAttribute|持有间接绘制调用的属性indirectOffset 间接绘制缓冲中的偏移量（字节）|
|indirectOffset|Int64||

返回: 

- 当前实例的引用

### func toNonIndexed\(\)
```cj
public func toNonIndexed(): BufferGeometry
```
返回此索引几何体的非索引版本

返回: 

- 此索引几何体的非索引版本

### func translate\(Float64,Float64,Float64\)
```cj
public func translate(x: Float64, y: Float64, z: Float64): BufferGeometry
```
平移几何体

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 方向偏移y y 方向偏移z z 方向偏移|
|y|Float64||
|z|Float64||

返回: 

- 当前实例的引用

### var attributes
```cj
public var attributes: HashMap < String, BufferAttribute >
```
命名顶点属性字典，通过 setAttribute/getAttribute 访问

### var boundingBox
```cj
public var boundingBox:?Box3
```
包围盒，可通过 computeBoundingBox() 计算

### var boundingSphere
```cj
public var boundingSphere:?Sphere
```
包围球，可通过 computeBoundingSphere() 计算

### var drawRange
```cj
public var drawRange:(Int64, Int64)
```
确定要渲染的几何体部分，使用 setDrawRange() 设置

### var groups
```cj
public var groups: ArrayList < BufferGeometryGroup >
```
将几何体分为多个绘制组，每组使用不同材质，通过 addGroup/clearGroups 编辑

### var index
```cj
public var index:?BufferAttribute
```
索引缓冲区属性，启用顶点复用；若未设置，渲染器假设每三个连续顶点构成一个三角形

### var indirectOffset
```cj
public var indirectOffset: Int64
```
间接绘制缓冲中的偏移量（字节）

### var indirect
```cj
public var indirect:?BufferAttribute
```
间接绘制属性（仅 WebGPU 后端支持）

### var kind
```cj
public var kind: String
```
几何体类型字符串

### var morphAttributes
```cj
public var morphAttributes: HashMap < String, ArrayList < BufferAttribute >>
```
形变目标属性字典；一旦几何体被渲染，形变属性数据不可更改，需要 dispose() 并重建

### var morphTargetsRelative
```cj
public var morphTargetsRelative: Bool
```
控制形变目标行为：true 为相对偏移，false 为绝对位置/法线

### var name
```cj
public var name: String
```
几何体名称

### var userData
```cj
public var userData: HashMap < String, Any >
```
序列化忽略：userData 为运行时自定义数据（JsonValue 容器，fastjson 宏不支持）。

### var uuid
```cj
public var uuid: String
```
几何体的 UUID

