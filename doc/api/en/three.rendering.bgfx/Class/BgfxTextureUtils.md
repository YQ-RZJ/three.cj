# Class
## class BgfxTextureUtils
```cj
public class BgfxTextureUtils
```
bgfx texture utilities

### func convertFormat\(Int64\)
```cj
public func convertFormat(format: Int64): UInt32
```
Convert three.js pixel format to bgfx TextureFormat

Parameter: 

|Name|Type|Describe|
|---|---|---|
|format|Int64|three.js pixel format constant|

Return: 

- bgfx TextureFormat value

### func estimateMemory\(Int64,Int64,Int64,Bool\)
```cj
public func estimateMemory(width: Int64, height: Int64, format: Int64, hasMipmaps: Bool): Int64
```
Estimate texture memory size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Texture widthheight Texture heightformat Pixel formathasMipmaps Whether has mipmaps|
|height|Int64||
|format|Int64||
|hasMipmaps|Bool||

Return: 

- Estimated memory size in bytes

### func init\(BgfxUtils\)
```cj
public init(bgfxUtils!: BgfxUtils = BgfxUtils())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|bgfxUtils|BgfxUtils||

### func isPowerOfTwo\(Int64\)
```cj
public func isPowerOfTwo(value: Int64): Bool
```
Check if value is power of two

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|Value to check|

Return: 

- Whether power of two

### func needsMipmaps\(Int64,Int64,Int64,Bool\)
```cj
public func needsMipmaps(minFilter: Int64, width: Int64, height: Int64, isPowerOfTwo: Bool): Bool
```
Check if texture needs mipmap generation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minFilter|Int64|Minification filter modewidth Texture widthheight Texture heightisPowerOfTwo Whether dimensions are power of two|
|width|Int64||
|height|Int64||
|isPowerOfTwo|Bool||

Return: 

- Whether mipmap is needed

