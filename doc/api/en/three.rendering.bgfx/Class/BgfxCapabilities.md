# Class
## class BgfxCapabilities
```cj
public class BgfxCapabilities
```
bgfx rendering capabilities

### func getMaxAnisotropy\(\)
```cj
public func getMaxAnisotropy(): Int64
```
Gets maximum anisotropy filtering level

Return: 

- Maximum anisotropy filtering level

### func getMaxPrecision\(String\)
```cj
public static func getMaxPrecision(precision!: String): String
```
Gets maximum shader precision

Parameter: 

|Name|Type|Describe|
|---|---|---|
|precision|String|Requested precision level|

Return: 

- Actually supported precision level

### func init\(BgfxExtensions,String,Bool,Bool\)
```cj
public init(extensions!: BgfxExtensions = BgfxExtensions(), precision!: String = "highp", logarithmicDepthBuffer!: Bool = false, reversedDepthBuffer!: Bool = false)
```
Constructs a rendering capabilities instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|extensions|BgfxExtensions|Extension compatibility layer instanceprecision Shader precision (default highp)logarithmicDepthBuffer Whether logarithmic depth buffer is supportedreversedDepthBuffer Whether reversed depth buffer is supported|
|precision|String||
|logarithmicDepthBuffer|Bool||
|reversedDepthBuffer|Bool||

### func initialize\(\)
```cj
public func initialize(): Unit
```
Initializes capability info from bgfx Caps

### func textureFormatReadable\(Int64\)
```cj
public func textureFormatReadable(textureFormat: Int64): Bool
```
Checks if a texture format is readable

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureFormat|Int64|Texture format|

Return: 

- Whether readable

### func textureTypeReadable\(Int64\)
```cj
public func textureTypeReadable(textureType: Int64): Bool
```
Checks if a texture type is readable

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureType|Int64|Texture type|

Return: 

- Whether readable

### var logarithmicDepthBuffer
```cj
public var logarithmicDepthBuffer: Bool
```
Whether logarithmic depth buffer is supported

### var maxAnisotropy
```cj
public var maxAnisotropy: Int64
```
Maximum anisotropy filtering level

### var maxAttributes
```cj
public var maxAttributes: Int64
```
Maximum vertex attributes

### var maxCubemapSize
```cj
public var maxCubemapSize: Int64
```
Maximum cubemap size

### var maxFragmentUniforms
```cj
public var maxFragmentUniforms: Int64
```
Maximum fragment uniform vectors

### var maxSamples
```cj
public var maxSamples: Int64
```
Maximum MSAA sample count

### var maxTextureSize
```cj
public var maxTextureSize: Int64
```
Maximum texture size

### var maxTextures
```cj
public var maxTextures: Int64
```
Maximum texture units

### var maxVaryings
```cj
public var maxVaryings: Int64
```
Maximum varying vectors

### var maxVertexTextures
```cj
public var maxVertexTextures: Int64
```
Maximum vertex texture units

### var maxVertexUniforms
```cj
public var maxVertexUniforms: Int64
```
Maximum vertex uniform vectors

### var precision
```cj
public var precision: String
```
Shader precision (bgfx always supports highp)

### var reversedDepthBuffer
```cj
public var reversedDepthBuffer: Bool
```
Whether reversed depth buffer is supported

