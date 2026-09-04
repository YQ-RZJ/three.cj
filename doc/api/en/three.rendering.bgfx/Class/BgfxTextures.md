# Class
## class BgfxTextures
```cj
public class BgfxTextures
```
bgfx texture management

### func convertTextureFlags\(Bool,Bool,Int64\)
```cj
public static func convertTextureFlags(sRGB: Bool, renderTarget: Bool, msaa: Int64): UInt64
```
Convert three.js texture parameters to bgfx texture flags

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sRGB|Bool|Whether to use sRGBrenderTarget Whether this is a render targetmsaa MSAA sample count|
|renderTarget|Bool||
|msaa|Int64||

Return: 

- bgfx texture flags

### func createTexture2D\(Int64,Int64,Int64,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTexture2D(textureId: Int64, width: Int64, height: Int64, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
Create 2D texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureId|Int64|Texture object IDwidth Texture widthheight Texture heightformat bgfx texture formatflags Texture flags (TEXTURE_RT, TEXTURE_SRGB, etc.)mem Texture data memory (Some=has data; None=empty RT)|
|width|Int64||
|height|Int64||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

Return: 

- Texture handle

### func destroyTexture\(Int64\)
```cj
public func destroyTexture(textureId: Int64): Unit
```
Destroy texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureId|Int64|Texture ID|

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose all textures

### func get\(Int64\)
```cj
public func get(textureId: Int64): Option < TextureInfo >
```
Get texture information

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureId|Int64|Texture ID|

Return: 

- Texture information

### func init\(BgfxCapabilities,BgfxUtils,BgfxInfo,BgfxProperties\)
```cj
public init(capabilities!: BgfxCapabilities, utils!: BgfxUtils, info!: BgfxInfo, properties!: BgfxProperties)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|capabilities|BgfxCapabilities||
|utils|BgfxUtils||
|info|BgfxInfo||
|properties|BgfxProperties||

### func updateTexture2D\(Int64,UInt16,UInt16,UInt16,UInt16,BgfxMemory,UInt16\)
```cj
public func updateTexture2D(textureId: Int64, x: UInt16, y: UInt16, width: UInt16, height: UInt16, mem: BgfxMemory, pitch: UInt16): Unit
```
Update 2D texture data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureId|Int64|Texture IDx Update region X offsety Update region Y offsetwidth Update region widthheight Update region heightmem Texture data memorypitch Row pitch|
|x|UInt16||
|y|UInt16||
|width|UInt16||
|height|UInt16||
|mem|BgfxMemory||
|pitch|UInt16||

