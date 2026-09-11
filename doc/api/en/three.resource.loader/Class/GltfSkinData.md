# Class
## class GltfSkinData
```cj
public class GltfSkinData
```
Parsed glTF Skin

### func init\(String,Array<Array<Float64>>,Int,Array<Int>\)
```cj
public init(name: String, inverseBindMatrices: Array < Array < Float64 >>, skeletonRoot: Int, joints: Array < Int >)
```
Create Skin data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Skin name|
|inverseBindMatrices|Array<Array<Float64>>|Inverse bind matrix list|
|skeletonRoot|Int|Skeleton root node index|
|joints|Array<Int>|Joint node index list|

### let inverseBindMatrices
```cj
public let inverseBindMatrices: Array < Array < Float64 >>
```
Inverse bind matrix list

### let joints
```cj
public let joints: Array < Int >
```
Joint node index list

### let name
```cj
public let name: String
```
Skin name

### let skeletonRoot
```cj
public let skeletonRoot: Int
```
Skeleton root node index

