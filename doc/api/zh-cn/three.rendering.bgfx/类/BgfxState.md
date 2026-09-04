# 类
## class BgfxState
```cj
public class BgfxState
```
bgfx 渲染状态管理

### func disable\(Int64\)
```cj
public func disable(id: Int64): Unit
```
禁用 GL 状态

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|状态 ID|

### func enable\(Int64\)
```cj
public func enable(id: Int64): Unit
```
启用 GL 状态

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|状态 ID|

### func getState\(\)
```cj
public func getState(): UInt64
```
获取当前 bgfx 状态标志位

返回: 

- bgfx 状态标志位

### func init\(\)
```cj
public init()
```


### func reset\(\)
```cj
public func reset(): Unit
```
重置所有状态

### func setBlending\(Int64,Int64,Int64,Int64,Int64,Int64,Int64,Bool\)
```cj
public func setBlending(blending: Int64, blendEquation: Int64, blendSrc: Int64, blendDst: Int64, blendEquationAlpha: Int64, blendSrcAlpha: Int64, blendDstAlpha: Int64, premultipliedAlpha: Bool): Unit
```
设置混合模式

参数: 

|名称|类型|描述|
|---|---|---|
|blending|Int64|混合模式blendEquation 混合方程blendSrc 源混合因子blendDst 目标混合因子blendEquationAlpha Alpha 混合方程blendSrcAlpha Alpha 源混合因子blendDstAlpha Alpha 目标混合因子premultipliedAlpha 是否预乘 Alpha|
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
设置剔除面

参数: 

|名称|类型|描述|
|---|---|---|
|cullFace|Int64|剔除面模式|

### func setFlipSided\(Bool\)
```cj
public func setFlipSided(flipSided: Bool): Unit
```
设置翻转面

参数: 

|名称|类型|描述|
|---|---|---|
|flipSided|Bool|是否翻转|

### func setLineWidth\(Float64\)
```cj
public func setLineWidth(width: Float64): Unit
```
设置线宽

参数: 

|名称|类型|描述|
|---|---|---|
|width|Float64|线宽|

### func setMaterial\(Material,Bool\)
```cj
public func setMaterial(material: Material, frontFaceCW: Bool): Unit
```
设置材质渲染状态

参数: 

|名称|类型|描述|
|---|---|---|
|material|Material|材质对象frontFaceCW 是否正面顺时针|
|frontFaceCW|Bool||

### func setPolygonOffset\(Bool,Float64,Float64\)
```cj
public func setPolygonOffset(polygonOffset: Bool, factor: Float64, units: Float64): Unit
```
设置多边形偏移

参数: 

|名称|类型|描述|
|---|---|---|
|polygonOffset|Bool|是否启用多边形偏移factor 偏移因子units 偏移单位|
|factor|Float64||
|units|Float64||

### func setScissorTest\(Bool\)
```cj
public func setScissorTest(scissorTest: Bool): Unit
```
设置裁剪测试区域

参数: 

|名称|类型|描述|
|---|---|---|
|scissorTest|Bool|是否启用裁剪测试|

### func setViewport\(Float64,Float64,Float64,Float64\)
```cj
public func setViewport(x: Float64, y: Float64, width: Float64, height: Float64): Unit
```
设置视口

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|X 坐标y Y 坐标width 宽度height 高度|
|y|Float64||
|width|Float64||
|height|Float64||

### func useProgram\(UInt16\)
```cj
public func useProgram(program: UInt16): Bool
```
使用着色器程序

参数: 

|名称|类型|描述|
|---|---|---|
|program|UInt16|着色器程序句柄|

返回: 

- 是否切换了程序

### let colorBuffer
```cj
public let colorBuffer: ColorBuffer
```
颜色缓冲状态

### let depthBuffer
```cj
public let depthBuffer: DepthBuffer
```
深度缓冲状态

### let stencilBuffer
```cj
public let stencilBuffer: StencilBuffer
```
模板缓冲状态

