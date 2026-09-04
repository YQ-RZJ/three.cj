# 包 three.rendering.lights 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[AmbientLight](./类/AmbientLight.md#class-ambientlight)|环境光，从各方向均匀照射场景的光源|
|[DirectionalLightShadow](./类/DirectionalLightShadow.md#class-directionallightshadow)|平行光阴影配置，专用于 DirectionalLight|
|[DirectionalLight](./类/DirectionalLight.md#class-directionallight)|方向光，从特定方向平行照射场景的光源|
|[HemisphereLight](./类/HemisphereLight.md#class-hemispherelight)|半球光，从天顶与地底两方向照射的光源|
|[LightProbe](./类/LightProbe.md#class-lightprobe)|光照探针，用球面调和描述场景光照环境的光源|
|[LightShadow](./类/LightShadow.md#class-lightshadow)|光源阴影配置的抽象基类，各具体光源阴影类型继承本类|
|[Light](./类/Light.md#class-light)|光源抽象基类，所有具体光源类型继承本类|
|[PointLightShadow](./类/PointLightShadow.md#class-pointlightshadow)|专用于PointLight的阴影配置，内部相机为透视投影|
|[PointLight](./类/PointLight.md#class-pointlight)|从某点向各方向均匀照射的光源|
|[RectAreaLight](./类/RectAreaLight.md#class-rectarealight)|以矩形面积发光的光源|
|[SpotLightShadow](./类/SpotLightShadow.md#class-spotlightshadow)|专用于SpotLight的阴影配置，根据光源角度动态调整相机视锥|
|[SpotLight](./类/SpotLight.md#class-spotlight)|从某点沿某方向以圆锥形照射的光源|

### 变量与常量
|  名称   | 描述  |
|  ----  | ----  |
|[BASIC_SHADOW_MAP](./变量与常量.md#let-basic_shadow_map)|阴影贴图实现类型 (SmImpl)|
|[CSM_CASCADE_COUNT](./变量与常量.md#let-csm_cascade_count)|CSM 级联数量常量|
|[DEPTH_IMPL_INVZ](./变量与常量.md#let-depth_impl_invz)|深度计算方式 (DepthImpl)|
|[DEPTH_IMPL_LINEAR](./变量与常量.md#let-depth_impl_linear)|线性深度（光空间距离）|
|[ESM_SHADOW_MAP](./变量与常量.md#let-esm_shadow_map)|ESM 阴影贴图（16-shadowmaps 独有）|
|[PACK_DEPTH_RGBA](./变量与常量.md#let-pack_depth_rgba)|深度打包方式 (PackDepth)|
|[PACK_DEPTH_VSM](./变量与常量.md#let-pack_depth_vsm)|VSM 深度打包（depth + depth² → 2× half float）|
|[PCF_SHADOW_MAP](./变量与常量.md#let-pcf_shadow_map)|PCF 阴影贴图|
|[PCF_SOFT_SHADOW_MAP](./变量与常量.md#let-pcf_soft_shadow_map)|PCF 柔和阴影贴图（已废弃，统一降级为 PCF）|
|[PCSS_SHADOW_MAP](./变量与常量.md#let-pcss_shadow_map)|PCSS 阴影贴图（16-shadowmaps 独有）|
|[SM_TYPE_CASCADE](./变量与常量.md#let-sm_type_cascade)|CSM 级联（4 级 atlas，方向光远距场景）|
|[SM_TYPE_OMNI](./变量与常量.md#let-sm_type_omni)|立方体贴图分布（点光源）或 tetrahedron 4 面|
|[SM_TYPE_SINGLE](./变量与常量.md#let-sm_type_single)|阴影贴图分布类型 (SmType)|
|[VSM_SHADOW_MAP](./变量与常量.md#let-vsm_shadow_map)|VSM 阴影贴图|

