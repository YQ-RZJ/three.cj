# Class
## class GltfAnimationChannel
```cj
public class GltfAnimationChannel
```
Parsed glTF Animation Channel

### func init\(Int,Int,String\)
```cj
public init(sampler: Int, targetNode: Int, targetPath: String)
```
Create an Animation Channel

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sampler|Int|Sampler index|
|targetNode|Int|Target node index|
|targetPath|String|Target property path|

### let sampler
```cj
public let sampler: Int
```
Sampler index

### let targetNode
```cj
public let targetNode: Int
```
Target node index

### let targetPath
```cj
public let targetPath: String
```
Target property path (translation/rotation/scale)

