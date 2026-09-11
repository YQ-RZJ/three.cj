# 包 three.rendering.shaders 

## API列表

### 函数
|  名称   | 描述  |
|  ----  | ----  |
|[getDFGLUT()](./函数.md#func-getdfglut)|获取 DFG LUT 数据纹理|

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[SamplerStages](./类/SamplerStages.md#class-samplerstages)|全局 sampler stage 分配器|
|[ShaderChunks](./类/ShaderChunks.md#class-shaderchunks)|管理所有着色器块的注册和组合|
|[ShaderCompileJob](./类/ShaderCompileJob.md#class-shadercompilejob)|着色器编译任务|
|[ShaderCompiler](./类/ShaderCompiler.md#class-shadercompiler)|着色器编译器|
|[ShaderLibs](./类/ShaderLibs.md#class-shaderlibs)|着色器库，管理所有材质类型的着色器程序|
|[ShaderProgram](./类/ShaderProgram.md#class-shaderprogram)|着色器程序定义，包含顶点和片段着色器源码|
|[ShaderVariant](./类/ShaderVariant.md#class-shadervariant)|Shader 变体管理器|
|[UniformsLib](./类/UniformsLib.md#class-uniformslib)|材质 Uniform 库|
|[UniformsUtils](./类/UniformsUtils.md#class-uniformsutils)|Uniforms 工具函数|

### 变量与常量
|  名称   | 描述  |
|  ----  | ----  |
|[BGFX_SHADER_SOURCE](./变量与常量.md#const-bgfx_shader_source)|bgfx_shader.sh 的完整内容，替代 #include <bgfx_shader.sh> 的运行时文件查找|
|[DFG_LUT_DATA](./变量与常量.md#let-dfg_lut_data)|DFG LUT 原始数据（UInt16 数组，512 个元素 = 16x16 x 2 通道）|
|[SHADER_LANGUAGE_DEFINE](./变量与常量.md#let-shader_language_define)|兜底：其他平台 → SPIR-V|
|[SHADER_PLATFORM](./变量与常量.md#let-shader_platform)|兜底：其他平台 → SPIR-V|
|[SHADER_PROFILE](./变量与常量.md#let-shader_profile)||

