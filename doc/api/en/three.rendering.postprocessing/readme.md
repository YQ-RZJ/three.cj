# Package three.rendering.postprocessing 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[AfterimagePass](./Class/AfterimagePass.md#class-afterimagepass)|Afterimage post-processing pass|
|[BgfxBloomPass](./Class/BgfxBloomPass.md#class-bgfxbloompass)|Bloom post-processing pass (simple version)|
|[BgfxGTAOPass](./Class/BgfxGTAOPass.md#class-bgfxgtaopass)||
|[BgfxSAOPass](./Class/BgfxSAOPass.md#class-bgfxsaopass)||
|[BgfxSSAOPass](./Class/BgfxSSAOPass.md#class-bgfxssaopass)||
|[BgfxSSRPass](./Class/BgfxSSRPass.md#class-bgfxssrpass)||
|[BgfxUnrealBloomPass](./Class/BgfxUnrealBloomPass.md#class-bgfxunrealbloompass)|Bloom post-processing pass (full 5-level pyramid UnrealBloom implementation)|
|[BloomMipLevel](./Class/BloomMipLevel.md#class-bloommiplevel)|单级金字塔 RT 资源（水平 + 垂直各一个 RT）。|
|[BokehPass](./Class/BokehPass.md#class-bokehpass)|Depth of Field (DOF) post-processing pass|
|[ClearMaskPass](./Class/ClearMaskPass.md#class-clearmaskpass)|Clear-mask pass|
|[ClearPass](./Class/ClearPass.md#class-clearpass)|Clear pass|
|[CubeTexturePass](./Class/CubeTexturePass.md#class-cubetexturepass)|Cube-texture background pass|
|[DotScreenPass](./Class/DotScreenPass.md#class-dotscreenpass)|Dot screen post-processing pass|
|[EffectComposer](./Class/EffectComposer.md#class-effectcomposer)|Post-processing pass chain scheduler|
|[FXAAPass](./Class/FXAAPass.md#class-fxaapass)|FXAA post-processing pass|
|[FilmPass](./Class/FilmPass.md#class-filmpass)|Film grain post-processing pass|
|[FullScreenQuad](./Class/FullScreenQuad.md#class-fullscreenquad)|Full-screen quad shared resources|
|[GlitchPass](./Class/GlitchPass.md#class-glitchpass)|Digital glitch post-processing pass|
|[HalftonePass](./Class/HalftonePass.md#class-halftonepass)|RGB halftone post-processing pass|
|[LUTPass](./Class/LUTPass.md#class-lutpass)|Color grading (LUT) post-processing pass|
|[MaskPass](./Class/MaskPass.md#class-maskpass)|Mask pass|
|[OutlinePass](./Class/OutlinePass.md#class-outlinepass)|Outline post-processing pass|
|[OutputPass](./Class/OutputPass.md#class-outputpass)|Output pass|
|[Pass](./Class/Pass.md#class-pass)|Post-processing pass abstract base class|
|[PostProcessingShaders](./Class/PostProcessingShaders.md#class-postprocessingshaders)|后处理内部 shader 注册表。  各后处理 shader 的注册与使用（按效果族组织）。 取代此前从 ShaderLibs.get() 取后处理 shader 的方式。|
|[RenderPass](./Class/RenderPass.md#class-renderpass)|Scene rendering pass|
|[RenderPixelatedPass](./Class/RenderPixelatedPass.md#class-renderpixelatedpass)|Pixelated render pass|
|[RenderTransitionPass](./Class/RenderTransitionPass.md#class-rendertransitionpass)|Scene transition render pass|
|[SMAAPass](./Class/SMAAPass.md#class-smaapass)|SMAA post-processing pass|
|[SSAARenderPass](./Class/SSAARenderPass.md#class-ssaarenderpass)|Supersampling antialiasing render pass|
|[SavePass](./Class/SavePass.md#class-savepass)|Save pass|
|[ShaderPass](./Class/ShaderPass.md#class-shaderpass)|Generic shader pass|
|[TAARenderPass](./Class/TAARenderPass.md#class-taarenderpass)|Temporal antialiasing render pass|
|[TexturePass](./Class/TexturePass.md#class-texturepass)|Texture overlay pass|
|[VolumeCloudPass](./Class/VolumeCloudPass.md#class-volumecloudpass)|Volume cloud post-processing pass (full-screen ray marching)|

### Variables & constants
|  Name   | Describe  |
|  ----  | ----  |
|[JITTER_VECTORS](./Variables%20&%20constants.md#let-jitter_vectors)|Jitter 向量表。 索引 = sampleLevel，值为该 sampleLevel 下所有 jitter 偏移量（整数，需 ×0.0625=1/16 映射到 [-0.5,0.5)）。|
|[TAA_JITTER_VECTORS](./Variables%20&%20constants.md#let-taa_jitter_vectors)|TAA jitter 向量表（索引 5 = 32 样本）。 TAARenderPass 固定使用 _JitterVectors[5]（32 样本），跨帧累加。|

