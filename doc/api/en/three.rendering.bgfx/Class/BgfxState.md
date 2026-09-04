# Class
## class BgfxState
```cj
public class BgfxState
```
bgfx render state management

### func disable\(Int64\)
```cj
public func disable(id: Int64): Unit
```
Disable GL state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|State ID|

### func enable\(Int64\)
```cj
public func enable(id: Int64): Unit
```
Enable GL state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|State ID|

### func getState\(\)
```cj
public func getState(): UInt64
```
Get current bgfx state flags

Return: 

- bgfx state flags

### func init\(\)
```cj
public init()
```


### func reset\(\)
```cj
public func reset(): Unit
```
Reset all states

### func setBlending\(Int64,Int64,Int64,Int64,Int64,Int64,Int64,Bool\)
```cj
public func setBlending(blending: Int64, blendEquation: Int64, blendSrc: Int64, blendDst: Int64, blendEquationAlpha: Int64, blendSrcAlpha: Int64, blendDstAlpha: Int64, premultipliedAlpha: Bool): Unit
```
Set blending mode

Parameter: 

|Name|Type|Describe|
|---|---|---|
|blending|Int64|Blending modeblendEquation Blend equationblendSrc Source blend factorblendDst Destination blend factorblendEquationAlpha Alpha blend equationblendSrcAlpha Alpha source blend factorblendDstAlpha Alpha destination blend factorpremultipliedAlpha Whether premultiplied alpha|
|blendEquation|Int64||
|blendSrc|Int64||
|blendDst|Int64||
|blendEquationAlpha|Int64||
|blendSrcAlpha|Int64||
|blendDstAlpha|Int64||
|premultipliedAlpha|Bool||

### func setCullFace\(Int64\)
```cj
public func setCullFace(cullFace: Int64): Unit
```
Set cull face

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cullFace|Int64|Cull face mode|

### func setFlipSided\(Bool\)
```cj
public func setFlipSided(flipSided: Bool): Unit
```
Set flip sided

Parameter: 

|Name|Type|Describe|
|---|---|---|
|flipSided|Bool|Whether to flip|

### func setLineWidth\(Float64\)
```cj
public func setLineWidth(width: Float64): Unit
```
Set line width

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Float64|Line width|

### func setMaterial\(Material,Bool\)
```cj
public func setMaterial(material: Material, frontFaceCW: Bool): Unit
```
Set material render state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|material|Material|Material objectfrontFaceCW Whether front face is clockwise|
|frontFaceCW|Bool||

### func setPolygonOffset\(Bool,Float64,Float64\)
```cj
public func setPolygonOffset(polygonOffset: Bool, factor: Float64, units: Float64): Unit
```
Set polygon offset

Parameter: 

|Name|Type|Describe|
|---|---|---|
|polygonOffset|Bool|Whether to enable polygon offsetfactor Offset factorunits Offset units|
|factor|Float64||
|units|Float64||

### func setScissorTest\(Bool\)
```cj
public func setScissorTest(scissorTest: Bool): Unit
```
Set scissor test

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scissorTest|Bool|Whether to enable scissor test|

### func setViewport\(Float64,Float64,Float64,Float64\)
```cj
public func setViewport(x: Float64, y: Float64, width: Float64, height: Float64): Unit
```
Set viewport

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|X coordinatey Y coordinatewidth Widthheight Height|
|y|Float64||
|width|Float64||
|height|Float64||

### func useProgram\(UInt16\)
```cj
public func useProgram(program: UInt16): Bool
```
Use shader program

Parameter: 

|Name|Type|Describe|
|---|---|---|
|program|UInt16|Shader program handle|

Return: 

- Whether program was switched

### let colorBuffer
```cj
public let colorBuffer: ColorBuffer
```
Color buffer state

### let depthBuffer
```cj
public let depthBuffer: DepthBuffer
```
Depth buffer state

### let stencilBuffer
```cj
public let stencilBuffer: StencilBuffer
```
Stencil buffer state

