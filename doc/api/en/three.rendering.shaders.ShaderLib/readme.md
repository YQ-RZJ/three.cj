# Package three.rendering.shaders.ShaderLib 

## API List

### Variables & constants
|  Name   | Describe  |
|  ----  | ----  |
|[backgroundCube_fragment](./Variables%20&%20constants.md#const-backgroundcube_fragment)|backgroundCube fragment shader source|
|[backgroundCube_vertex](./Variables%20&%20constants.md#const-backgroundcube_vertex)|backgroundCube vertex shader source|
|[background_fragment](./Variables%20&%20constants.md#const-background_fragment)|background fragment shader source|
|[background_vertex](./Variables%20&%20constants.md#const-background_vertex)|background vertex shader source|
|[cube_fragment](./Variables%20&%20constants.md#const-cube_fragment)|cube fragment shader source|
|[cube_vertex](./Variables%20&%20constants.md#const-cube_vertex)|cube vertex shader source|
|[depth_fragment](./Variables%20&%20constants.md#const-depth_fragment)|depth fragment shader source|
|[depth_vertex](./Variables%20&%20constants.md#const-depth_vertex)|depth vertex shader source|
|[distance_fragment](./Variables%20&%20constants.md#const-distance_fragment)|distance fragment shader source|
|[distance_vertex](./Variables%20&%20constants.md#const-distance_vertex)|distance vertex shader source|
|[equirect_fragment](./Variables%20&%20constants.md#const-equirect_fragment)|equirect fragment shader source|
|[equirect_vertex](./Variables%20&%20constants.md#const-equirect_vertex)|equirect vertex shader source|
|[linedashed_fragment](./Variables%20&%20constants.md#const-linedashed_fragment)|linedashed fragment shader source|
|[linedashed_vertex](./Variables%20&%20constants.md#const-linedashed_vertex)|linedashed vertex shader source|
|[meshbasic_fragment](./Variables%20&%20constants.md#const-meshbasic_fragment)|meshbasic fragment shader source|
|[meshbasic_vertex](./Variables%20&%20constants.md#const-meshbasic_vertex)|meshbasic vertex shader source|
|[meshlambert_fragment](./Variables%20&%20constants.md#const-meshlambert_fragment)|meshlambert fragment shader source|
|[meshlambert_vertex](./Variables%20&%20constants.md#const-meshlambert_vertex)|meshlambert vertex shader source|
|[meshmatcap_fragment](./Variables%20&%20constants.md#const-meshmatcap_fragment)|meshmatcap fragment shader source|
|[meshmatcap_vertex](./Variables%20&%20constants.md#const-meshmatcap_vertex)|meshmatcap vertex shader source|
|[meshnormal_fragment](./Variables%20&%20constants.md#const-meshnormal_fragment)|meshnormal fragment shader source|
|[meshnormal_vertex](./Variables%20&%20constants.md#const-meshnormal_vertex)|meshnormal vertex shader source|
|[meshphong_fragment](./Variables%20&%20constants.md#const-meshphong_fragment)|meshphong fragment shader source|
|[meshphong_vertex](./Variables%20&%20constants.md#const-meshphong_vertex)|meshphong vertex shader source|
|[meshphysical_fragment](./Variables%20&%20constants.md#const-meshphysical_fragment)|meshphysical fragment shader source|
|[meshphysical_vertex](./Variables%20&%20constants.md#const-meshphysical_vertex)|meshphysical vertex shader source|
|[meshtoon_fragment](./Variables%20&%20constants.md#const-meshtoon_fragment)|meshtoon fragment shader source|
|[meshtoon_vertex](./Variables%20&%20constants.md#const-meshtoon_vertex)|meshtoon vertex shader source|
|[points_fragment](./Variables%20&%20constants.md#const-points_fragment)|points fragment shader source|
|[points_vertex](./Variables%20&%20constants.md#const-points_vertex)|points vertex shader source|
|[shadow_color_lighting_header](./Variables%20&%20constants.md#const-shadow_color_lighting_header)|color_lighting shared header chunk (fs_shadowmaps_color_lighting.sh) 定义 Shader struct、evalShader、computeVisibility 函数。 computeVisibility 通过 #if SM_HARD/PCF/PCSS/VSM/ESM 分派到对应阴影实现。|
|[shadow_color_lighting_main](./Variables%20&%20constants.md#const-shadow_color_lighting_main)|color_lighting main body chunk (fs_shadowmaps_color_lighting_main.sh) 通过 #if SM_CSM / SM_OMNI / else 分派到 Single/Omni/Cascade 路径。 每条路径计算 visibility 后，执行 BRDF (lit) + fog + 最终颜色合成。|
|[shadow_color_lighting_vertex_csm](./Variables%20&%20constants.md#const-shadow_color_lighting_vertex_csm)|color_lighting vertex shader chunk (CSM mode, InvZ) 计算 4 级 v_texcoord1..4 = u_shadowMapMtx{0..3} × wpos|
|[shadow_color_lighting_vertex_csm_linear](./Variables%20&%20constants.md#const-shadow_color_lighting_vertex_csm_linear)|color_lighting vertex shader chunk (CSM mode, Linear) Linear 模式：4 级 v_texcoord1..4.z += 0.5|
|[shadow_color_lighting_vertex_omni](./Variables%20&%20constants.md#const-shadow_color_lighting_vertex_omni)|color_lighting vertex shader chunk (Omni mode) 计算 4 面 tetrahedron 的 v_texcoord1..4 = u_shadowMapMtx{0..3} × v_position|
|[shadow_color_lighting_vertex_omni_linear](./Variables%20&%20constants.md#const-shadow_color_lighting_vertex_omni_linear)|color_lighting vertex shader chunk (Omni mode, Linear)|
|[shadow_color_lighting_vertex_single](./Variables%20&%20constants.md#const-shadow_color_lighting_vertex_single)|color_lighting vertex shader chunk (Single mode, InvZ) 计算 v_shadowcoord = u_lightMtx × (pos + normal × offset)|
|[shadow_color_lighting_vertex_single_linear](./Variables%20&%20constants.md#const-shadow_color_lighting_vertex_single_linear)|color_lighting vertex shader chunk (Single mode, Linear) Linear 模式：v_shadowcoord.z += 0.5（光空间线性距离补偿）|
|[shadow_fragment](./Variables%20&%20constants.md#const-shadow_fragment)|shadow fragment shader source|
|[shadow_vertex](./Variables%20&%20constants.md#const-shadow_vertex)|shadow vertex shader source|
|[sprite_fragment](./Variables%20&%20constants.md#const-sprite_fragment)|sprite fragment shader source|
|[sprite_vertex](./Variables%20&%20constants.md#const-sprite_vertex)|sprite vertex shader source|
|[vsm_fragment](./Variables%20&%20constants.md#const-vsm_fragment)|vsm fragment shader source|
|[vsm_vertex](./Variables%20&%20constants.md#const-vsm_vertex)|vsm vertex shader source|

