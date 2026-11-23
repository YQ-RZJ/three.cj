# 类
## class SceneCullIndex
```cj
public class SceneCullIndex
```
场景空间索引

### func needsRebuild\(\)
```cj
public func needsRebuild(): Bool
```
检查索引是否需要重建（场景结构有变化）

### func queryArrayFrustum\(FrustumArray\)
```cj
public func queryArrayFrustum(frustumArray: FrustumArray): Unit
```
刷新包围盒并做多眼视锥查询（任一眼可见即不剔除）

参数: 

|名称|类型|描述|
|---|---|---|
|frustumArray|FrustumArray|多眼视锥|

### func query\(Frustum\)
```cj
public func query(frustum: Frustum): Unit
```
刷新包围盒并做视锥查询，结果写入各对象的 cullVisible 标记

参数: 

|名称|类型|描述|
|---|---|---|
|frustum|Frustum|视锥|

### func rebuild\(Object3D\)
```cj
public func rebuild(scene: Object3D): Unit
```
重建索引：遍历场景收集可剔除对象并建立 BVH

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Object3D|场景根节点|

### prop alwaysVisibleCount: Int64
```cj
public prop alwaysVisibleCount: Int64
```
恒可见对象数量

### prop indexedCount: Int64
```cj
public prop indexedCount: Int64
```
参与空间索引的对象数量

