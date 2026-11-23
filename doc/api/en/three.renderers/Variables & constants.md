# Variables & constants
## let BGFX\_ATTRIB\_POSITION
```cj
public let BGFX_ATTRIB_POSITION: UInt32 = GfxAttrib.Position.value()
```
Vertex attribute semantic: position

## let BGFX\_UNIFORM\_MAT4
```cj
public let BGFX_UNIFORM_MAT4: UInt32 = GfxUniformType.Mat4.value()
```
Uniform type: Mat4

## let BGFX\_UNIFORM\_VEC4
```cj
public let BGFX_UNIFORM_VEC4: UInt32 = GfxUniformType.Vec4.value()
```
Uniform type: Vec4

## let CLEAR\_COLOR
```cj
public let CLEAR_COLOR: UInt16 = GfxClearFlag.COLOR
```
Clear color flag bit

## let CLEAR\_DEPTH
```cj
public let CLEAR_DEPTH: UInt16 = GfxClearFlag.DEPTH
```
Clear depth flag bit

## let DEFAULT\_RENDERER\_TYPE
```cj
@When[os != "Windows" && os != "Linux" && os != "macOS" && os != "iOS"]
public let DEFAULT_RENDERER_TYPE: UInt32 = 0u32
```
Default renderer type (unknown platform fallback value)

