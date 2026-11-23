# 枚举
## enum PhysicsShapeType
```cj
public enum PhysicsShapeType
```
形状类型枚举（不带参数，参数由 PhysicsShape 结构体持有）

### Box
```cj
Box
```
盒体

### Capsule
```cj
Capsule
```
胶囊体

### Compound
```cj
Compound
```
复合形状（多个子形状 + 相对变换，JPH_CompoundShape）

### ConvexHull
```cj
ConvexHull
```
凸包形状（顶点列表，JPH_ConvexHullShape）

### Cylinder
```cj
Cylinder
```
圆柱体

### Mesh
```cj
Mesh
```
三角网格形状（顶点 + 索引三角形，JPH_MeshShape）

### Plane
```cj
Plane
```
无限平面（后端近似）

### Sphere
```cj
Sphere
```
球体

