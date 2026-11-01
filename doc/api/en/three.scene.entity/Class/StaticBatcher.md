# Class
## class StaticBatcher
```cj
public class StaticBatcher
```
CPU static batching utility (pure static method set)

### func mergeMeshes\(ArrayList<Mesh>\)
```cj
public static func mergeMeshes(meshes: ArrayList < Mesh >): Mesh
```
Merge multiple meshes into a single static mesh

Parameter: 

|Name|Type|Describe|
|---|---|---|
|meshes|ArrayList<Mesh>|Mesh list to merge (non-empty)|

Return: 

- Merged new Mesh (at world origin, isStatic=true)

### func process\(Object3D\)
```cj
public static func process(root: Object3D): ArrayList < Mesh >
```
Traverse the scene subtree and auto-group/merge static meshes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|root|Object3D|Traversal root node (usually Scene or Group)|

Return: 

- Newly merged Mesh list (not added to scene; caller must add them manually)

