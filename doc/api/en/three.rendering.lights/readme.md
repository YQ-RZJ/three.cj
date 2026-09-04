# Package three.rendering.lights 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[AmbientLight](./Class/AmbientLight.md#class-ambientlight)|Ambient light that illuminates the scene uniformly from all directions|
|[DirectionalLightShadow](./Class/DirectionalLightShadow.md#class-directionallightshadow)|Directional light shadow configuration, specific to DirectionalLight|
|[DirectionalLight](./Class/DirectionalLight.md#class-directionallight)|Directional light that illuminates the scene from a specific direction|
|[HemisphereLight](./Class/HemisphereLight.md#class-hemispherelight)|Hemisphere light illuminating from sky and ground directions|
|[LightProbe](./Class/LightProbe.md#class-lightprobe)|Light probe using spherical harmonics to describe scene lighting environment|
|[LightShadow](./Class/LightShadow.md#class-lightshadow)|Abstract base class for light shadow configuration, subclassed by concrete shadow types|
|[Light](./Class/Light.md#class-light)|Abstract base class for all light types|
|[PointLightShadow](./Class/PointLightShadow.md#class-pointlightshadow)|Shadow configuration specific to PointLight, with a perspective camera internally|
|[PointLight](./Class/PointLight.md#class-pointlight)|A light that emits uniformly in all directions from a point|
|[RectAreaLight](./Class/RectAreaLight.md#class-rectarealight)|A light that emits from a rectangular area|
|[SpotLightShadow](./Class/SpotLightShadow.md#class-spotlightshadow)|Shadow configuration specific to SpotLight, dynamically adjusts camera frustum based on light angle|
|[SpotLight](./Class/SpotLight.md#class-spotlight)|A light that emits from a point in a cone shape along a direction|

### Variables & constants
|  Name   | Describe  |
|  ----  | ----  |
|[BASIC_SHADOW_MAP](./Variables%20&%20constants.md#let-basic_shadow_map)|Shadow map implementation type (SmImpl)|
|[CSM_CASCADE_COUNT](./Variables%20&%20constants.md#let-csm_cascade_count)|CSM cascade count constant|
|[DEPTH_IMPL_INVZ](./Variables%20&%20constants.md#let-depth_impl_invz)|Depth calculation method (DepthImpl)|
|[DEPTH_IMPL_LINEAR](./Variables%20&%20constants.md#let-depth_impl_linear)|Linear depth (light space distance)|
|[ESM_SHADOW_MAP](./Variables%20&%20constants.md#let-esm_shadow_map)|ESM shadow map (16-shadowmaps exclusive)|
|[PACK_DEPTH_RGBA](./Variables%20&%20constants.md#let-pack_depth_rgba)|Depth packing method (PackDepth)|
|[PACK_DEPTH_VSM](./Variables%20&%20constants.md#let-pack_depth_vsm)|VSM depth packing (depth + depth² → 2× half float)|
|[PCF_SHADOW_MAP](./Variables%20&%20constants.md#let-pcf_shadow_map)|PCF shadow map|
|[PCF_SOFT_SHADOW_MAP](./Variables%20&%20constants.md#let-pcf_soft_shadow_map)|PCF soft shadow map (deprecated, falls back to PCF)|
|[PCSS_SHADOW_MAP](./Variables%20&%20constants.md#let-pcss_shadow_map)|PCSS shadow map (16-shadowmaps exclusive)|
|[SM_TYPE_CASCADE](./Variables%20&%20constants.md#let-sm_type_cascade)|CSM cascade (4-level atlas, directional light far scenes)|
|[SM_TYPE_OMNI](./Variables%20&%20constants.md#let-sm_type_omni)|Cube map distribution (point light) or tetrahedron 4 faces|
|[SM_TYPE_SINGLE](./Variables%20&%20constants.md#let-sm_type_single)|Shadow map distribution type (SmType)|
|[VSM_SHADOW_MAP](./Variables%20&%20constants.md#let-vsm_shadow_map)|VSM shadow map|

