# Class
## class TextureUtils
```cj
public class TextureUtils
```
Texture utilities class

### func contain\(Texture,Float64\)
```cj
public static func contain(texture: Texture, aspect: Float64): Texture
```
Scale texture in contain mode: fill surface as large as possible without cropping/stretching

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Target textureaspect Target surface aspect ratio|
|aspect|Float64||

Return: 

- Modified texture

### func cover\(Texture,Float64\)
```cj
public static func cover(texture: Texture, aspect: Float64): Texture
```
Scale texture in cover mode

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Target textureaspect Target surface aspect ratio|
|aspect|Float64||

Return: 

- Modified texture

### func fill\(Texture\)
```cj
public static func fill(texture: Texture): Texture
```
Reset texture to default transform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Target texture|

Return: 

- Modified texture

### func getByteLength\(Int64,Int64,Int64,Int64\)
```cj
public static func getByteLength(width: Int64, height: Int64, format: Int64, `type`: Int64): Int64
```
Estimate texture byte length for given dimensions, format, and type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Texture widthheight Texture heightformat Texture formattype Texture type|
|height|Int64||
|format|Int64||
|`type`|Int64||

Return: 

- Byte length

