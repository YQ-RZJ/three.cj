# Class
## class PVRLoader
```cj
public class PVRLoader <: CompressedTextureLoader
```
PVR compressed texture loader

### func init\(LoadingManager\)
```cj
public init(manager: LoadingManager)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|manager|LoadingManager||

### func init\(\)
```cj
public init()
```


### func parse\(Array<UInt8>,Bool\)
```cj
public override func parse(buffer: Array < UInt8 >, isCubemap: Bool): HashMap < String, Any >
```
Parse PVR byte data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|Array<UInt8>|PVR file bytesisCubemap Whether to parse as cubemap|
|isCubemap|Bool||

Return: 

- texData (width/height/format/mipmaps/mipmapCount)

