# 类
## class RenderList
```cj
public open class RenderList
```
渲染列表

### func clear\(\)
```cj
public func clear(): Unit
```
清空渲染列表

### func finish\(\)
```cj
public func finish(): ArrayList < RenderItem >
```
完成收集，返回排序后的渲染项列表

返回: 

- 排序后的渲染项列表

### func init\(\)
```cj
public init()
```
构造默认渲染列表

### func push\(Object3D,BufferGeometry,Material,Int64,Int64,Float64,Int64\)
```cj
public func push(object: Object3D, geometry: BufferGeometry, material: Material, groupOrder: Int64, renderOrder: Int64, z: Float64, group: Int64): Unit
```
添加渲染对象

参数: 

|名称|类型|描述|
|---|---|---|
|object|Object3D|渲染对象geometry 几何体material 材质groupOrder 组顺序renderOrder 渲染顺序z 深度值group 组索引|
|geometry|BufferGeometry||
|material|Material||
|groupOrder|Int64||
|renderOrder|Int64||
|z|Float64||
|group|Int64||

### func sort\(\)
```cj
public func sort(): Unit
```
三级排序

