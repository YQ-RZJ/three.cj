# Class
## class Texture
```cj
public open class Texture <: EventDispatcher & IRenderTargetTexture & IBackground & ILoadResult
```
Texture resource base class

### func clone\(\)
```cj
public open func clone(): Texture
```
Return a new texture instance with the same values as this instance

Return: 

- Cloned texture instance

### func copy\(Texture\)
```cj
public open func copy(source: Texture): Texture
```
Copy values from the given texture instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Texture|Source texture|

Return: 

- This instance

### func dispose\(\)
```cj
public open func dispose(): Unit
```
Release GPU-related resources allocated by this instance and dispatch dispose event

### func getIsData3DTexture\(\)
```cj
public open func getIsData3DTexture(): Bool
```
Whether this is a 3D data texture (subclass overrides to true)

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,String\)
```cj
public init(image!: Array < UInt8 >= Array < UInt8 >(), width!: Int64 = 0, height!: Int64 = 0, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, mapping!: Int64 = UVMapping, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1, colorSpace!: String = "")
```
Construct a new texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|image|Array<UInt8>|Pixel array, defaults to emptywidth Texture width in pixels, defaults to 0height Texture height in pixels, defaults to 0wrapS Horizontal wrap mode, defaults to ClampToEdgeWrappingwrapT Vertical wrap mode, defaults to ClampToEdgeWrappingmagFilter Magnification filter, defaults to LinearFilterminFilter Minification filter, defaults to LinearMipmapLinearFiltermapping UV mapping mode, defaults to UVMappingformat Pixel format, defaults to RGBAFormattype Pixel data type, defaults to UnsignedByteTypeanisotropy Anisotropy level, defaults to 1colorSpace Color space, defaults to empty|
|width|Int64||
|height|Int64||
|wrapS|Int64||
|wrapT|Int64||
|magFilter|Int64||
|minFilter|Int64||
|mapping|Int64||
|format|Int64||
|`type`|Int64||
|anisotropy|Int64||
|colorSpace|String||

### func rtClone\(\)
```cj
public func rtClone(): IRenderTargetTexture
```
IRenderTargetTexture interface: clone itself

### func rtIsData3DTexture\(\)
```cj
public func rtIsData3DTexture(): Bool
```
IRenderTargetTexture interface: whether 3D data texture

### func setValues\(HashMap<String,Any>\)
```cj
public func setValues(values: HashMap < String, Any >): Unit
```
Batch set texture fields from HashMap values (key names match field names)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|values|HashMap<String,Any>|Field value dictionary|

### func transformUv\(Vector2,Vector2\)
```cj
public func transformUv(uv: Vector2, target: Vector2): Vector2
```
Transform UV coordinates by this texture's offset/repeat/center/rotation and write to target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|uv|Vector2|UV coordinates to transformtarget Target vector to receive the result|
|target|Vector2||

Return: 

- Transformed UV coordinates

### func updateMatrix\(\)
```cj
public func updateMatrix(): Unit
```
Recalculate UV transform matrix (by offset/repeat/rotation/center)

### func update\(\)
```cj
public open func update(): Unit
```
Notify the renderer that texture content has changed, next render will re-upload GPU texture

### prop needsUpdate: Bool
```cj
public mut prop needsUpdate: Bool
```
Renderer internal incremental update flag, when true the next render will re-upload GPU texture

### prop rtDepth: Int64
```cj
public mut prop rtDepth: Int64
```
IRenderTargetTexture interface: texture depth

### prop rtHeight: Int64
```cj
public mut prop rtHeight: Int64
```
IRenderTargetTexture interface: texture height

### prop rtIsArrayTexture: Bool
```cj
public mut prop rtIsArrayTexture: Bool
```
IRenderTargetTexture interface: whether array texture

### prop rtIsRenderTargetTexture: Bool
```cj
public mut prop rtIsRenderTargetTexture: Bool
```
IRenderTargetTexture interface: whether render target texture

### prop rtRenderTarget:?RenderTarget
```cj
public mut prop rtRenderTarget:?RenderTarget
```
IRenderTargetTexture interface: render target back reference

### prop rtWidth: Int64
```cj
public mut prop rtWidth: Int64
```
IRenderTargetTexture interface: texture width

### var \`type\`
```cj
public var `type`: Int64
```
Texture pixel data type, defaults to UnsignedByteType

### var anisotropy
```cj
public var anisotropy: Int64
```
Anisotropy sampling level, defaults to 1

### var center
```cj
public var center: Vector2
```
UV rotation center

### var channel
```cj
public var channel: Int64
```
Channel offset (reinterprets a channel as another in WebGL2/GLSL3, 0=no offset)

### var colorSpace
```cj
public var colorSpace: String
```
Color space, defaults to empty (follows renderer global)

### var depth
```cj
public var depth: Int64
```
Texture depth (for 3D textures, defaults to 1)

### var flipY
```cj
public var flipY: Bool
```
Whether to flip along Y axis on upload

### var format
```cj
public var format: Int64
```
Texture pixel format, defaults to RGBAFormat

### var generateMipmaps
```cj
public var generateMipmaps: Bool
```
Whether to auto-generate mipmaps

### var height
```cj
public var height: Int64
```
Texture height in pixels

### var image
```cj
public var image: Array < UInt8 >
```
Texture data (pixel array)

### var internalFormat
```cj
public var internalFormat: Option < String >
```
Pixel format override (e.g. "GL_RGBA16F"/"GL_R32F"), None means auto-derived from format+type

### var isArrayTexture
```cj
public var isArrayTexture: Bool
```
Whether this is an array texture

### var isRenderTargetTexture
```cj
public var isRenderTargetTexture: Bool
```
Whether this is a render target texture

### var kind
```cj
public var kind: String
```
Type tag

### var magFilter
```cj
public var magFilter: Int64
```
Magnification filter, defaults to LinearFilter

### var mapping
```cj
public var mapping: Int64
```
UV mapping mode, defaults to UVMapping

### var matrixAutoUpdate
```cj
public var matrixAutoUpdate: Bool
```
Whether to auto-update UV transform matrix

### var matrix
```cj
public var matrix: Matrix3
```
UV transform matrix (3×3)

### var minFilter
```cj
public var minFilter: Int64
```
Minification filter, defaults to LinearMipmapLinearFilter

### var mipmaps
```cj
public var mipmaps: ArrayList < Any >
```
Pre-generated mipmap array (filled when using manual mipmaps)

### var name
```cj
public var name: String
```
User-namable tag

### var normalized
```cj
public var normalized: Bool
```
Whether to use 16-bit normalized integer format, defaults to false

### var offset
```cj
public var offset: Vector2
```
UV offset

### var premultiplyAlpha
```cj
public var premultiplyAlpha: Bool
```
Whether to premultiply alpha before upload

### var renderTarget
```cj
public var renderTarget:?RenderTarget
```
Render target back reference

### var repeat
```cj
public var repeat: Vector2
```
UV repeat

### var rotation
```cj
public var rotation: Float64
```
UV rotation angle in radians

### var source
```cj
public var source: Source
```
Texture data source (holds data + needsUpdate + version)

### var unpackAlignment
```cj
public var unpackAlignment: Int64
```
Pixel row alignment bytes (1/2/4/8), defaults to 4

### var userData
```cj
public var userData: HashMap < String, Any >
```
User custom data container

### var uuid
```cj
public var uuid: String
```
Unique identifier

### var version
```cj
public var version: Int64
```
Renderer internal version number, incremented each update()

### var width
```cj
public var width: Int64
```
Texture width in pixels

### var wrapS
```cj
public var wrapS: Int64
```
Horizontal sampling wrap mode, defaults to ClampToEdgeWrapping

### var wrapT
```cj
public var wrapT: Int64
```
Vertical sampling wrap mode, defaults to ClampToEdgeWrapping

