# 包 three.rendering.postprocessing 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[AfterimagePass](./类/AfterimagePass.md#class-afterimagepass)|残影后处理 pass|
|[BgfxBloomPass](./类/BgfxBloomPass.md#class-bgfxbloompass)|Bloom 后处理 pass（简单版）|
|[BgfxGTAOPass](./类/BgfxGTAOPass.md#class-bgfxgtaopass)||
|[BgfxSAOPass](./类/BgfxSAOPass.md#class-bgfxsaopass)||
|[BgfxSSAOPass](./类/BgfxSSAOPass.md#class-bgfxssaopass)||
|[BgfxSSRPass](./类/BgfxSSRPass.md#class-bgfxssrpass)||
|[BgfxUnrealBloomPass](./类/BgfxUnrealBloomPass.md#class-bgfxunrealbloompass)|Bloom 后处理 pass（UnrealBloom 完整 5 级金字塔实现）|
|[BloomMipLevel](./类/BloomMipLevel.md#class-bloommiplevel)|单级金字塔 RT 资源（水平 + 垂直各一个 RT）。|
|[BokehPass](./类/BokehPass.md#class-bokehpass)|景深（DOF）后处理 pass|
|[ClearMaskPass](./类/ClearMaskPass.md#class-clearmaskpass)|清遮罩 pass|
|[ClearPass](./类/ClearPass.md#class-clearpass)|清屏 pass|
|[CubeTexturePass](./类/CubeTexturePass.md#class-cubetexturepass)|立方体贴图背景 pass|
|[DotScreenPass](./类/DotScreenPass.md#class-dotscreenpass)|点阵屏后处理 pass|
|[EffectComposer](./类/EffectComposer.md#class-effectcomposer)|后处理 pass 链调度器|
|[FXAAPass](./类/FXAAPass.md#class-fxaapass)|FXAA 后处理 pass|
|[FilmPass](./类/FilmPass.md#class-filmpass)|胶片颗粒后处理 pass|
|[FullScreenQuad](./类/FullScreenQuad.md#class-fullscreenquad)|全屏四边形共享资源|
|[GlitchPass](./类/GlitchPass.md#class-glitchpass)|数字故障后处理 pass|
|[HalftonePass](./类/HalftonePass.md#class-halftonepass)|RGB 半色调后处理 pass|
|[LUTPass](./类/LUTPass.md#class-lutpass)|颜色分级（LUT）后处理 pass|
|[MaskPass](./类/MaskPass.md#class-maskpass)|遮罩 pass|
|[OutlinePass](./类/OutlinePass.md#class-outlinepass)|Outline 后处理 pass|
|[OutputPass](./类/OutputPass.md#class-outputpass)|输出 pass|
|[Pass](./类/Pass.md#class-pass)|后处理 pass 抽象基类|
|[PostProcessingShaders](./类/PostProcessingShaders.md#class-postprocessingshaders)|后处理内部 shader 注册表。  各后处理 shader 的注册与使用（按效果族组织）。 取代此前从 ShaderLibs.get() 取后处理 shader 的方式。|
|[RenderPass](./类/RenderPass.md#class-renderpass)|场景渲染 pass|
|[RenderPixelatedPass](./类/RenderPixelatedPass.md#class-renderpixelatedpass)|像素化渲染 pass|
|[RenderTransitionPass](./类/RenderTransitionPass.md#class-rendertransitionpass)|场景过渡渲染 pass|
|[SMAAPass](./类/SMAAPass.md#class-smaapass)|SMAA 后处理 pass|
|[SSAARenderPass](./类/SSAARenderPass.md#class-ssaarenderpass)|超采样抗锯齿渲染 pass|
|[SavePass](./类/SavePass.md#class-savepass)|保存 pass|
|[ShaderPass](./类/ShaderPass.md#class-shaderpass)|通用 shader pass|
|[TAARenderPass](./类/TAARenderPass.md#class-taarenderpass)|时间抗锯齿渲染 pass|
|[TexturePass](./类/TexturePass.md#class-texturepass)|贴纹理 pass|
|[VolumeCloudPass](./类/VolumeCloudPass.md#class-volumecloudpass)|体积云后处理 pass（全屏 ray marching）|

### 变量与常量
|  名称   | 描述  |
|  ----  | ----  |
|[JITTER_VECTORS](./变量与常量.md#let-jitter_vectors)|Jitter 向量表。 索引 = sampleLevel，值为该 sampleLevel 下所有 jitter 偏移量（整数，需 ×0.0625=1/16 映射到 [-0.5,0.5)）。|
|[TAA_JITTER_VECTORS](./变量与常量.md#let-taa_jitter_vectors)|TAA jitter 向量表（索引 5 = 32 样本）。 TAARenderPass 固定使用 _JitterVectors[5]（32 样本），跨帧累加。|

