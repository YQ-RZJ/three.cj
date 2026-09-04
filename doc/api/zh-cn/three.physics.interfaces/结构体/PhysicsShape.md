# 结构体
## struct PhysicsShape
```cj
public struct PhysicsShape
```
物理形状描述（后端无关）

### func box\(Float64,Float64,Float64\)
```cj
public static func box(width: Float64, height: Float64, depth: Float64): PhysicsShape
```
创建 Box 形状（全尺寸 width/height/depth，内部转半边长）

参数: 

|名称|类型|描述|
|---|---|---|
|width|Float64|宽度height 高度depth 深度|
|height|Float64||
|depth|Float64||

返回: 

- Box 形状描述

### func capsule\(Float64,Float64\)
```cj
public static func capsule(halfHeight: Float64, radius: Float64): PhysicsShape
```
创建 Capsule 形状（halfHeight = 圆柱段半高，不含半球帽）

参数: 

|名称|类型|描述|
|---|---|---|
|halfHeight|Float64|圆柱段半高radius 半径|
|radius|Float64||

返回: 

- Capsule 形状描述

### func compound\(Array<PhysicsCompoundPart>\)
```cj
public static func compound(parts: Array < PhysicsCompoundPart >): PhysicsShape
```
创建 Compound 复合形状（多个子形状 + 相对质心的变换）

参数: 

|名称|类型|描述|
|---|---|---|
|parts|Array<PhysicsCompoundPart>|子形状部件数组|

返回: 

- Compound 形状描述

### func convexHull\(Array<Vector3>\)
```cj
public static func convexHull(points: Array < Vector3 >): PhysicsShape
```
创建 ConvexHull 凸包形状（顶点列表，自动求凸包）

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|凸包顶点列表|

返回: 

- ConvexHull 形状描述

### func cylinder\(Float64,Float64\)
```cj
public static func cylinder(halfHeight: Float64, radius: Float64): PhysicsShape
```
创建 Cylinder 形状（halfHeight = 半高）

参数: 

|名称|类型|描述|
|---|---|---|
|halfHeight|Float64|半高radius 半径|
|radius|Float64||

返回: 

- Cylinder 形状描述

### func init\(PhysicsShapeType,Vector3,Float64,Float64,Array<Vector3>,Array<UInt32>,Array<PhysicsCompoundPart>\)
```cj
public init(shapeType!: PhysicsShapeType, halfExtent!: Vector3 = Vector3(), halfHeight!: Float64 = 0.0, radius!: Float64 = 0.0, vertices!: Array < Vector3 >=[], triangles!: Array < UInt32 >=[], parts!: Array < PhysicsCompoundPart >=[])
```
创建形状描述（按 shapeType 填写相应字段，其余保持默认）

参数: 

|名称|类型|描述|
|---|---|---|
|shapeType|PhysicsShapeType|形状类型halfExtent 半边长（Box），默认零向量halfHeight 胶囊/圆柱段半高，默认 0radius 球/胶囊/圆柱半径，默认 0vertices 顶点数组（Mesh/ConvexHull 用），默认空triangles 三角形索引（Mesh 用），默认空parts 复合子部件（Compound 用），默认空|
|halfExtent|Vector3||
|halfHeight|Float64||
|radius|Float64||
|vertices|Array<Vector3>||
|triangles|Array<UInt32>||
|parts|Array<PhysicsCompoundPart>||

### func mesh\(Array<Vector3>,Array<UInt32>\)
```cj
public static func mesh(vertices: Array < Vector3 >, triangles: Array < UInt32 >): PhysicsShape
```
创建 Mesh 三角网格形状（顶点 + 索引三角形）

参数: 

|名称|类型|描述|
|---|---|---|
|vertices|Array<Vector3>|顶点数组（世界坐标）triangles 三角形索引（每 3 个一组）|
|triangles|Array<UInt32>||

返回: 

- Mesh 形状描述

### func plane\(\)
```cj
public static func plane(): PhysicsShape
```
创建 Plane 形状（后端用大盒子近似无限平面）

返回: 

- Plane 形状描述

### func sphere\(Float64\)
```cj
public static func sphere(radius: Float64): PhysicsShape
```
创建 Sphere 形状（半径）

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|半径|

返回: 

- Sphere 形状描述

### let halfExtent
```cj
public let halfExtent: Vector3
```
半边长（Box）/ 半径（Sphere/Capsule/Cylinder）

### let halfHeight
```cj
public let halfHeight: Float64
```
胶囊/圆柱段半高

### let parts
```cj
public let parts: Array < PhysicsCompoundPart >
```
复合形状子部件（Compound 用）

### let radius
```cj
public let radius: Float64
```
球/胶囊/圆柱半径

### let shapeType
```cj
public let shapeType: PhysicsShapeType
```
形状类型

### let triangles
```cj
public let triangles: Array < UInt32 >
```
三角形索引（Mesh 用，每 3 个一组，顶点索引）

### let vertices
```cj
public let vertices: Array < Vector3 >
```
顶点数组（Mesh/ConvexHull 用）

