# Class
## class TGALoader
```cj
public class TGALoader <: DataTextureLoader
```
TGA loader, loads Targa format images as DataTexture

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


### func parse\(Array<UInt8>\)
```cj
public override func parse(buffer: Array < UInt8 >): HashMap < String, Any >
```
Parse TGA byte data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|Array<UInt8>|.tga file bytes|

Return: 

- texData (data=RGBA8/width/height/flipY/generateMipmaps/minFilter)

