# Class
## class Material
```cj
public open class Material <: EventDispatcher & IMaterial & ILoadResult
```
Abstract base class for materials, subclassed by all concrete material types

### func clone\(\)
```cj
public func clone(): Material
```
Return a new material instance with the same values as this instance

Return: 

- Cloned material instance

### func copy\(Material\)
```cj
public func copy(source: Material): Material
```
Copy the values from the given material instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Material|Source material instance|

Return: 

- This instance

### func createFromJSON\(HashMap<String,Any>,HashMap<String,Texture>\)
```cj
public static func createFromJSON(json: HashMap < String, Any >, textures: HashMap < String, Texture >): Option < Material >
```
Construct a material from JSON deserialization

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|JSON datatextures Texture mapping|
|textures|HashMap<String,Texture>||

Return: 

- Constructed material instance, or None if type is unknown

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU-related resources and dispatch dispose event

### func fromJSON\(HashMap<String,Any>,HashMap<String,Texture>\)
```cj
public open func fromJSON(json: HashMap < String, Any >, textures: HashMap < String, Texture >): Unit
```
Set material properties from JSON deserialization

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|JSON datatextures Texture mapping|
|textures|HashMap<String,Texture>||

### func init\(\)
```cj
public init()
```
Construct a new material

### func setValues\(HashMap<String,Any>\)
```cj
public func setValues(values: HashMap < String, Any >): Unit
```
Batch set material fields from a HashMap

Parameter: 

|Name|Type|Describe|
|---|---|---|
|values|HashMap<String,Any>|HashMap containing field names and values|

### prop alphaTest: Float64
```cj
public mut prop alphaTest: Float64
```
Accessor property for alpha test threshold

### var alphaToCoverage
```cj
public var alphaToCoverage: Bool
```
Whether to enable alpha-to-coverage, default false

### var blendDst
```cj
public var blendDst: Int64
```
Destination color blend factor, default OneMinusSrcAlphaFactor

### var blendEquation
```cj
public var blendEquation: Int64
```
Blend equation, default AddEquation

### var blendSrc
```cj
public var blendSrc: Int64
```
Source color blend factor, default SrcAlphaFactor

### var blending
```cj
public var blending: Int64
```
Blending mode, default NormalBlending

### var clipIntersection
```cj
public var clipIntersection: Bool
```
Whether to use clip intersection mode

### var clipShadows
```cj
public var clipShadows: Bool
```
Whether to clip shadows

### var clippingPlanes
```cj
public var clippingPlanes: Option < ArrayList < Plane >>
```
Clipping planes array

### var colorWrite
```cj
public var colorWrite: Bool
```
Whether to write to color channels, default true

### var color
```cj
public var color: Color
```
Material main color, default 0xffffff

### var customProgramCacheKey
```cj
public var customProgramCacheKey: Option <() -> String >
```
Custom program cache key callback function

### var depthFunc
```cj
public var depthFunc: Int64
```
Depth comparison function, default LessEqualDepth

### var depthTest
```cj
public var depthTest: Bool
```
Whether to enable depth test, default true

### var depthWrite
```cj
public var depthWrite: Bool
```
Whether to write to depth buffer, default true

### var dithering
```cj
public var dithering: Bool
```
Whether to enable dithering, default false

### var envMapIntensity
```cj
public var envMapIntensity: Float64
```
Environment map intensity, default 1

### var envMapRotation
```cj
public var envMapRotation: Option < Euler >
```
Environment map rotation

### var envMap
```cj
public var envMap: Option < Texture >
```
Environment map

### var flatShading
```cj
public var flatShading: Bool
```
Whether to use flat shading, default false

### var fog
```cj
public var fog: Bool
```
Whether to enable fog, default true

### var forceSinglePass
```cj
public var forceSinglePass: Bool
```
Whether to force single-pass rendering, default false

### var name
```cj
public var name: String
```
User-namable label

### var onBeforeCompile
```cj
public var onBeforeCompile: Option <(shaderobject: IShaderProgram, renderer: IRenderer) -> Unit >
```
Before-compile callback function

### var onBeforeRender
```cj
public var onBeforeRender: Option <(renderer: IRenderer, scene: IScene, camera: Camera, geometry: BufferGeometry, object: Object3D, group: IGroup) -> Unit >
```
Before-render callback function

### var opacity
```cj
public var opacity: Float64
```
Opacity (0.0~1.0), default 1.0

### var polygonOffsetFactor
```cj
public var polygonOffsetFactor: Float64
```
Polygon offset factor, default 0

### var polygonOffsetUnits
```cj
public var polygonOffsetUnits: Float64
```
Polygon offset units, default 0

### var polygonOffset
```cj
public var polygonOffset: Bool
```
Whether to enable polygon offset, default false

### var premultipliedAlpha
```cj
public var premultipliedAlpha: Bool
```
Whether alpha is premultiplied, default false

### var shadowSide
```cj
public var shadowSide: Option < Int64 >
```
Shadow side, None means same as side

### var side
```cj
public var side: Int64
```
Rendering side (FrontSide/BackSide/DoubleSide), default FrontSide

### var stencilFail
```cj
public var stencilFail: Int64
```
Stencil fail operation, default KeepStencilOp

### var stencilFuncMask
```cj
public var stencilFuncMask: Int64
```
Stencil comparison mask, default 0xFF

### var stencilFunc
```cj
public var stencilFunc: Int64
```
Stencil comparison function, default AlwaysStencilFunc

### var stencilRef
```cj
public var stencilRef: Int64
```
Stencil reference value, default 0

### var stencilWriteMask
```cj
public var stencilWriteMask: Int64
```
Stencil write mask, default 0xFF

### var stencilWrite
```cj
public var stencilWrite: Bool
```
Whether to enable stencil writing, default false

### var stencilZFail
```cj
public var stencilZFail: Int64
```
Stencil depth test fail operation, default KeepStencilOp

### var stencilZPass
```cj
public var stencilZPass: Int64
```
Stencil depth test pass operation, default KeepStencilOp

### var toneMapped
```cj
public var toneMapped: Bool
```
Whether to apply tone mapping, default true

### var transparent
```cj
public var transparent: Bool
```
Whether transparent, default false

### var userData
```cj
public var userData: HashMap < String, Any >
```
User-defined metadata

### var uuid
```cj
public var uuid: String
```
Unique identifier

### var version
```cj
public var version: Int64
```
Renderer internal version number, incremented on each field change

### var vertexColors
```cj
public var vertexColors: Bool
```
Whether to enable vertex colors, default false

### var visible
```cj
public var visible: Bool
```
Whether visible, default true

### var wireframe
```cj
public var wireframe: Bool
```
Whether to render in wireframe mode, default false

