# Function
## func contain\(Texture,Float64\)
```cj
public func contain(texture: Texture, aspect: Float64): Texture
```
Scale texture in contain mode (package-level convenience function, forwards to TextureUtils.contain)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Target textureaspect Target surface aspect ratio|
|aspect|Float64||

Return: 

- Modified texture

## func cover\(Texture,Float64\)
```cj
public func cover(texture: Texture, aspect: Float64): Texture
```
Scale texture in cover mode (package-level convenience function, forwards to TextureUtils.cover)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Target textureaspect Target surface aspect ratio|
|aspect|Float64||

Return: 

- Modified texture

## func fill\(Texture\)
```cj
public func fill(texture: Texture): Texture
```
Reset texture to default transform (package-level convenience function, forwards to TextureUtils.fill)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Target texture|

Return: 

- Modified texture

## func getTextureTypeByteLength\(Int64\)
```cj
public func getTextureTypeByteLength(`type`: Int64): TypeByteLength
```
Look up bytes per pixel and components for the given texture type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|Int64||

Return: 

- TypeByteLength structure

