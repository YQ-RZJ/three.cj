# 类
## class BgfxObjects
```cj
public class BgfxObjects
```
bgfx 场景对象管理

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有更新映射

### func init\(BgfxGeometries,BgfxAttributes,BgfxInfo\)
```cj
public init(geometries!: BgfxGeometries, attributes!: BgfxAttributes, info!: BgfxInfo)
```


参数: 

|名称|类型|描述|
|---|---|---|
|geometries|BgfxGeometries||
|attributes|BgfxAttributes||
|info|BgfxInfo||

### func update\(Int64,Int64,Bool,Bool\)
```cj
public func update(objectId: Int64, geometryId: Int64, isInstancedMesh: Bool, isSkinnedMesh: Bool): Int64
```
更新对象的渲染数据

参数: 

|名称|类型|描述|
|---|---|---|
|objectId|Int64|对象 IDgeometryId 几何体 IDisInstancedMesh 是否为实例化网格isSkinnedMesh 是否为蒙皮网格|
|geometryId|Int64||
|isInstancedMesh|Bool||
|isSkinnedMesh|Bool||

返回: 

- 几何体缓冲数据 ID

