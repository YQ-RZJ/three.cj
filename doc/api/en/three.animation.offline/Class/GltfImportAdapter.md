# Class
## class GltfImportAdapter
```cj
public class GltfImportAdapter
```
glTF to offline skeleton/animation data adapter (all static methods)

### func buildRawAnimation\(GltfAnimationData,GltfSkinData,Array<Any>,Array<Any>,ArrayList<Array<UInt8>>,?RawSkeleton\)
```cj
public static func buildRawAnimation(animData: GltfAnimationData, skinData: GltfSkinData, accessors: Array < Any >, bufferViews: Array < Any >, loadedBuffers: ArrayList < Array < UInt8 >>, rawSkeleton!:?RawSkeleton = None): RawAnimation
```
Build offline animation from glTF animation and skin

Parameter: 

|Name|Type|Describe|
|---|---|---|
|animData|GltfAnimationData|Parsed glTF animation (channels, samplers)|
|skinData|GltfSkinData|Associated skin (for node-index to joint-index mapping)|
|accessors|Array<Any>|glTF accessor array|
|bufferViews|Array<Any>|glTF bufferView array|
|loadedBuffers|ArrayList<Array<UInt8>>|Loaded binary buffer list|
|rawSkeleton|?RawSkeleton||

Return: 

- RawAnimation with keyframes filled (sorted by time)

### func buildRawSkeleton\(GltfSkinData,Array<Any>\)
```cj
public static func buildRawSkeleton(skinData: GltfSkinData, nodes: Array < Any >): RawSkeleton
```
Build offline skeleton from glTF skin and node data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skinData|GltfSkinData|Parsed glTF skin (joint node indices, name, etc.)|
|nodes|Array<Any>|glTF node array (elements are HashMap<String, Any>)|

Return: 

- RawSkeleton with hierarchy and local rest poses filled

