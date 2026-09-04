# 类
## class SkeletonHelper
```cj
public class SkeletonHelper <: LineSegments
```
骨骼辅助对象，用于可视化 Skeleton 骨骼层级

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Object3D\)
```cj
public init(object: Object3D)
```
构造骨骼辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|object|Object3D|骨骼层级根对象，通常是 SkinnedMesh 或包含 Bone 的 Object3D|

### func setColors\(Color,Color\)
```cj
public func setColors(color1: Color, color2: Color): SkeletonHelper
```
设置骨骼颜色

参数: 

|名称|类型|描述|
|---|---|---|
|color1|Color|起始颜色（蓝色 0x0000ff）color2 结束颜色（绿色 0x00ff00）|
|color2|Color||

返回: 

- 自身引用

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
更新矩阵世界，计算骨骼位置

参数: 

|名称|类型|描述|
|---|---|---|
|force|Bool|是否强制更新|

### var bones
```cj
public var bones: ArrayList < Bone >
```
骨骼列表

### var root
```cj
public var root: Object3D
```
根对象

