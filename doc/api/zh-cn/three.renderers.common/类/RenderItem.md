# 类
## class RenderItem
```cj
public class RenderItem
```
渲染列表中的单个渲染项

### func init\(Int64,Object3D,BufferGeometry,Material,Int64,Int64,Float64,Int64\)
```cj
public init(id: Int64, object: Object3D, geometry: BufferGeometry, material: Material, groupOrder: Int64, renderOrder: Int64, z: Float64, group: Int64)
```


参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64||
|object|Object3D||
|geometry|BufferGeometry||
|material|Material||
|groupOrder|Int64||
|renderOrder|Int64||
|z|Float64||
|group|Int64||

### func reset\(Int64,Object3D,BufferGeometry,Material,Int64,Int64,Float64,Int64\)
```cj
public func reset(id: Int64, object: Object3D, geometry: BufferGeometry, material: Material, groupOrder: Int64, renderOrder: Int64, z: Float64, group: Int64): Unit
```
复用渲染项：按新帧数据重置各字段（池化路径）

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64||
|object|Object3D||
|geometry|BufferGeometry||
|material|Material||
|groupOrder|Int64||
|renderOrder|Int64||
|z|Float64||
|group|Int64||

### var \`object\`
```cj
public var `object`: Object3D
```
渲染对象

### var geometry
```cj
public var geometry: BufferGeometry
```
几何体

### var groupOrder
```cj
public var groupOrder: Int64
```
组顺序

### var group
```cj
public var group: Int64
```
组索引

### var id
```cj
public var id: Int64
```
唯一 ID（自增，用于稳定排序）

### var material
```cj
public var material: Material
```
材质

### var renderOrder
```cj
public var renderOrder: Int64
```
渲染顺序

### var routeSuppressed
```cj
public var routeSuppressed: Bool = false
```
本帧是否已被聚合路由取代（自动实例化移除标记）

### var z
```cj
public var z: Float64
```
深度值（相机空间 z）

