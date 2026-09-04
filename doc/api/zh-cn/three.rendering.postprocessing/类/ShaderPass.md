# 类
## class ShaderPass
```cj
public open class ShaderPass <: Pass
```
通用 shader pass

### func bindExtraUniforms\(BgfxRenderer,BgfxUniforms\)
```cj
public open func bindExtraUniforms(renderer: BgfxRenderer, uniforms: BgfxUniforms): Unit
```
子类扩展钩子：在 submit 前绑定额外 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|uniforms|BgfxUniforms|已创建 tDiffuse sampler 的 uniform 注册表（可继续创建额外 uniform）|

### func dispose\(\)
```cj
public open override func dispose(): Unit
```
释放 ShaderPass 占用的 GPU 资源

### func init\(String,String\)
```cj
public init(shaderName: String, textureID!: String = "tDiffuse")
```
构造 ShaderPass

参数: 

|名称|类型|描述|
|---|---|---|
|shaderName|String|ShaderLibs 已注册的全屏 shader 名|
|textureID|String|绑 readBuffer 的 sampler 名（默认 tDiffuse）|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public open override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 shader pass

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（renderToScreen=false 时写这里）|
|readBuffer|FrameBufferHandle|读 buffer（绑到 textureID sampler）|
|deltaTime|Float64|帧间隔|

### var clearView
```cj
public var clearView: Bool = true
```
渲染前是否清 view，默认 true

### let shaderName
```cj
public let shaderName: String
```
已注册 shader 名（PostProcessingShaders.get(name) 取）

### var stencilTestRef
```cj
public var stencilTestRef: Option < UInt32 >= None
```
可选的 stencil 测试参考值，Some(ref) 时仅在 stencil==ref 区域渲染

### var textureID
```cj
public var textureID: String = "tDiffuse"
```
纹理 uniform 名（绑 readBuffer 的 sampler），默认 tDiffuse

