# Variables & constants
## let BGFX\_ATTRIB\_POSITION
```cj
public let BGFX_ATTRIB_POSITION: UInt32 = 0u32
```
bgfx vertex attribute semantic: position

## let BGFX\_UNIFORM\_MAT4
```cj
public let BGFX_UNIFORM_MAT4: UInt32 = UniformType.Mat4.value()
```
bgfx uniform type: Mat4

## let BGFX\_UNIFORM\_VEC4
```cj
public let BGFX_UNIFORM_VEC4: UInt32 = UniformType.Vec4.value()
```
bgfx uniform type: Vec4

## let CLEAR\_COLOR
```cj
public let CLEAR_COLOR: UInt16 = 0x0001u16
```
Clear color flag bit

## let CLEAR\_DEPTH
```cj
public let CLEAR_DEPTH: UInt16 = 0x0002u16
```
Clear depth flag bit

## let DEFAULT\_RENDERER\_TYPE
```cj
@When[os != "Windows" && os != "Linux" && os != "macOS" && os != "iOS"]
public let DEFAULT_RENDERER_TYPE: UInt32 = 0u32
```
Default renderer type (unknown platform fallback value)

