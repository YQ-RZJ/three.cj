# Struct
## struct PhysicsShape
```cj
public struct PhysicsShape
```
Physics shape description (backend-agnostic)

### func box\(Float64,Float64,Float64\)
```cj
public static func box(width: Float64, height: Float64, depth: Float64): PhysicsShape
```
Creates a Box shape (full width/height/depth, converted to half extents internally)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Float64|The widthheight The heightdepth The depth|
|height|Float64||
|depth|Float64||

Return: 

- The Box shape description

### func capsule\(Float64,Float64\)
```cj
public static func capsule(halfHeight: Float64, radius: Float64): PhysicsShape
```
Creates a Capsule shape (halfHeight = half height of the cylindrical segment, excluding the hemisphere caps)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|halfHeight|Float64|The half height of the cylindrical segmentradius The radius|
|radius|Float64||

Return: 

- The Capsule shape description

### func compound\(Array<PhysicsCompoundPart>\)
```cj
public static func compound(parts: Array < PhysicsCompoundPart >): PhysicsShape
```
Creates a Compound shape (multiple sub-shapes + transforms relative to the center of mass)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|parts|Array<PhysicsCompoundPart>|The array of sub-shape parts|

Return: 

- The Compound shape description

### func convexHull\(Array<Vector3>\)
```cj
public static func convexHull(points: Array < Vector3 >): PhysicsShape
```
Creates a ConvexHull shape (vertex list, convex hull computed automatically)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|The convex-hull vertex list|

Return: 

- The ConvexHull shape description

### func cylinder\(Float64,Float64\)
```cj
public static func cylinder(halfHeight: Float64, radius: Float64): PhysicsShape
```
Creates a Cylinder shape (halfHeight = half height)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|halfHeight|Float64|The half heightradius The radius|
|radius|Float64||

Return: 

- The Cylinder shape description

### func init\(PhysicsShapeType,Vector3,Float64,Float64,Array<Vector3>,Array<UInt32>,Array<PhysicsCompoundPart>\)
```cj
public init(shapeType!: PhysicsShapeType, halfExtent!: Vector3 = Vector3(), halfHeight!: Float64 = 0.0, radius!: Float64 = 0.0, vertices!: Array < Vector3 >=[], triangles!: Array < UInt32 >=[], parts!: Array < PhysicsCompoundPart >=[])
```
Creates a shape description (fill in the fields relevant to shapeType, leave the rest default)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shapeType|PhysicsShapeType|The shape typehalfExtent Half extents (Box); zero vector by defaulthalfHeight Capsule/cylinder segment half height; 0 by defaultradius Sphere/capsule/cylinder radius; 0 by defaultvertices Vertex array (Mesh/ConvexHull); empty by defaulttriangles Triangle indices (Mesh); empty by defaultparts Compound sub-parts (Compound); empty by default|
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
Creates a Mesh triangle-mesh shape (vertices + indexed triangles)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vertices|Array<Vector3>|The vertex array (world coordinates)triangles The triangle indices (triplets)|
|triangles|Array<UInt32>||

Return: 

- The Mesh shape description

### func plane\(\)
```cj
public static func plane(): PhysicsShape
```
Creates a Plane shape (the backend approximates an infinite plane with a big box)

Return: 

- The Plane shape description

### func sphere\(Float64\)
```cj
public static func sphere(radius: Float64): PhysicsShape
```
Creates a Sphere shape (radius)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|The radius|

Return: 

- The Sphere shape description

### let halfExtent
```cj
public let halfExtent: Vector3
```
Half extents (Box) / radius (Sphere/Capsule/Cylinder)

### let halfHeight
```cj
public let halfHeight: Float64
```
Half height of the capsule/cylinder segment

### let parts
```cj
public let parts: Array < PhysicsCompoundPart >
```
Compound sub-parts (used by Compound)

### let radius
```cj
public let radius: Float64
```
Sphere/capsule/cylinder radius

### let shapeType
```cj
public let shapeType: PhysicsShapeType
```
The shape type

### let triangles
```cj
public let triangles: Array < UInt32 >
```
Triangle indices (used by Mesh, triplets of vertex indices)

### let vertices
```cj
public let vertices: Array < Vector3 >
```
Vertex array (used by Mesh/ConvexHull)

