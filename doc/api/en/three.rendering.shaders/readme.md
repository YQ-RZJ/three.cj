# Package three.rendering.shaders 

## API List

### Function
|  Name   | Describe  |
|  ----  | ----  |
|[getDFGLUT()](./Function.md#func-getdfglut)|Get the DFG LUT data texture|

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[SamplerStages](./Class/SamplerStages.md#class-samplerstages)|Global sampler stage allocator|
|[ShaderChunks](./Class/ShaderChunks.md#class-shaderchunks)|Manage registration and composition of all shader chunks|
|[ShaderCompileJob](./Class/ShaderCompileJob.md#class-shadercompilejob)|Shader compilation job|
|[ShaderCompiler](./Class/ShaderCompiler.md#class-shadercompiler)|Shader compiler|
|[ShaderLibs](./Class/ShaderLibs.md#class-shaderlibs)|Shader library managing shader programs for all material types|
|[ShaderProgram](./Class/ShaderProgram.md#class-shaderprogram)|Shader program definition containing vertex and fragment shader sources|
|[ShaderVariant](./Class/ShaderVariant.md#class-shadervariant)|Shader variant manager|
|[UniformsLib](./Class/UniformsLib.md#class-uniformslib)|Material uniform library|
|[UniformsUtils](./Class/UniformsUtils.md#class-uniformsutils)|Uniform utility functions|

### Variables & constants
|  Name   | Describe  |
|  ----  | ----  |
|[BGFX_SHADER_SOURCE](./Variables%20&%20constants.md#const-bgfx_shader_source)|Complete content of bgfx_shader.sh, replacing runtime file lookup for #include <bgfx_shader.sh>|
|[DFG_LUT_DATA](./Variables%20&%20constants.md#let-dfg_lut_data)|DFG LUT raw data (UInt16 array, 512 elements = 16x16 x 2 channels)|
|[SHADER_LANGUAGE_DEFINE](./Variables%20&%20constants.md#let-shader_language_define)|兜底：其他平台 → SPIR-V|
|[SHADER_PLATFORM](./Variables%20&%20constants.md#let-shader_platform)|兜底：其他平台 → SPIR-V|
|[SHADER_PROFILE](./Variables%20&%20constants.md#let-shader_profile)||

