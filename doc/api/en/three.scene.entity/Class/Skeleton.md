# Class
## class Skeleton
```cj
public class Skeleton <: IPropertyBindingRoot
```
Skeleton class, manages a set of Bones and their inverse matrices

### func \_init\(\)
```cj
public func _init(): Unit
```
Internal initialization: auto-calculates when boneInverses is empty; rebuilds when count mismatch

### func calculateInverses\(\)
```cj
public func calculateInverses(): Unit
```
Calculate inverse matrices for each bone (matrixWorld.invert())

### func clone\(\)
```cj
public func clone(): Skeleton
```
Return a new skeleton instance with the same values as this instance

Return: 

- New skeleton instance

### func computeBoneTexture\(\)
```cj
public func computeBoneTexture(): Unit
```
Generate boneTexture (pack boneMatrices into DataTexture), for large skeletons to save upload cost

### func dispose\(\)
```cj
public func dispose(): Unit
```
Release GPU-related resources allocated by this instance (boneTexture)

### func fromJSON\(HashMap<String,Any>,HashMap<String,Bone>\)
```cj
public func fromJSON(json: HashMap < String, Any >, bones: HashMap < String, Bone >): Skeleton
```
Set up skeleton from JSON deserialization

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|Serialized skeleton JSONbones Bone dictionary (uuid → Bone instance)|
|bones|HashMap<String,Bone>||

Return: 

- Returns this for method chaining

### func getBoneByName\(String\)
```cj
public func getBoneByName(name: String): Option < Bone >
```
Find bone by name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Bone name|

Return: 

- Found bone, or None

### func getUuid\(\)
```cj
public func getUuid(): String
```
Get unique identifier (IPropertyBindingRoot interface implementation)

Return: 

- UUID string

### func init\(ArrayList<Bone>,ArrayList<Matrix4>\)
```cj
public init(bones!: ArrayList < Bone >= ArrayList < Bone >(), boneInverses!: ArrayList < Matrix4 >= ArrayList < Matrix4 >())
```
Construct a new skeleton

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bones|ArrayList<Bone>|Bone array, default emptyboneInverses Bone inverse matrix array, default empty (auto calculateInverses when empty)|
|boneInverses|ArrayList<Matrix4>||

### func pose\(\)
```cj
public func pose(): Unit
```
Pose each bone to its initial pose, then recalculate each bone's matrix/position/quaternion/scale

### func syncFromSkeletonData\(SkeletonData\)
```cj
public func syncFromSkeletonData(skelData: SkeletonData): Unit
```
Synchronizes bone data from SkeletonData

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skelData|SkeletonData|Skeleton computation data|

### func update\(\)
```cj
public func update(): Unit
```
Update each bone's offsetMatrix and write to boneMatrices

### var boneInverses
```cj
public var boneInverses: ArrayList < Matrix4 >
```
Inverse matrices of each bone (world space → bone local space)

### var boneMatrices
```cj
public var boneMatrices: Option < Array < Float64 >>
```
Flattened bone offset matrix array (16 Float64 per bone), used internally for rendering

### var boneTexture
```cj
public var boneTexture: Option < DataTexture >
```
GPU texture wrapper of boneMatrices (for large skeletons, replaces array upload)

### var bones
```cj
public var bones: ArrayList < Bone >
```
Bone array

### var kind
```cj
public var kind: String
```
Type label

### var uuid
```cj
public var uuid: String
```
Unique identifier

