# Enum
## enum PhysicsShapeType
```cj
public enum PhysicsShapeType
```
Shape-type enum (no parameters; parameters are held by the PhysicsShape struct)

### Box
```cj
Box
```
Box

### Capsule
```cj
Capsule
```
Capsule

### Compound
```cj
Compound
```
Compound shape (multiple sub-shapes + relative transforms, JPH_CompoundShape)

### ConvexHull
```cj
ConvexHull
```
Convex-hull shape (vertex list, JPH_ConvexHullShape)

### Cylinder
```cj
Cylinder
```
Cylinder

### Mesh
```cj
Mesh
```
Triangle-mesh shape (vertices + indexed triangles, JPH_MeshShape)

### Plane
```cj
Plane
```
Infinite plane (approximated by the backend)

### Sphere
```cj
Sphere
```
Sphere

