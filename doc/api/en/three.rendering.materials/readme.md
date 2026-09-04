# Package three.rendering.materials 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[DepthVizMaterial](./Class/DepthVizMaterial.md#class-depthvizmaterial)|Depth visualization material, maps linear depth to normalized grayscale|
|[LightDirMaterial](./Class/LightDirMaterial.md#class-lightdirmaterial)|Light direction N·L visualization material, maps N·L to grayscale|
|[LineBasicMaterial](./Class/LineBasicMaterial.md#class-linebasicmaterial)|Basic line material, supporting linewidth, linecap, and linejoin styles|
|[LineDashedMaterial](./Class/LineDashedMaterial.md#class-linedashedmaterial)|Dashed line material, supporting dashSize and gapSize|
|[MaterialOverrideScope](./Class/MaterialOverrideScope.md#class-materialoverridescope)|Per-mesh material override stack (callback injection style)|
|[Material](./Class/Material.md#class-material)|Abstract base class for materials, subclassed by all concrete material types|
|[Materials](./Class/Materials.md#class-materials)|Materials utility class, providing material type query methods|
|[MeshBasicMaterial](./Class/MeshBasicMaterial.md#class-meshbasicmaterial)|Mesh basic material, renders geometry in a simple way (no lighting)|
|[MeshDepthMaterial](./Class/MeshDepthMaterial.md#class-meshdepthmaterial)|Material that renders geometry based on depth|
|[MeshDistanceMaterial](./Class/MeshDistanceMaterial.md#class-meshdistancematerial)|Distance material used for point light shadow mapping|
|[MeshLambertMaterial](./Class/MeshLambertMaterial.md#class-meshlambertmaterial)|Lambert material, supporting emissive, environment map, and flatShading|
|[MeshMatcapMaterial](./Class/MeshMatcapMaterial.md#class-meshmatcapmaterial)|Matcap material, rendered using a material capture texture|
|[MeshNormalMaterial](./Class/MeshNormalMaterial.md#class-meshnormalmaterial)|Normal material, renders normal vectors as RGB colors|
|[MeshPhongMaterial](./Class/MeshPhongMaterial.md#class-meshphongmaterial)|Phong material, supporting specular highlights and shininess|
|[MeshPhysicalMaterial](./Class/MeshPhysicalMaterial.md#class-meshphysicalmaterial)|Physical material, extending Standard material with advanced PBR properties like clearcoat and transmission|
|[MeshStandardMaterial](./Class/MeshStandardMaterial.md#class-meshstandardmaterial)|Standard PBR material, supporting metalness/roughness workflow|
|[MeshToonMaterial](./Class/MeshToonMaterial.md#class-meshtoonmaterial)|Toon material, using gradient map to control light/dark boundaries for cartoon rendering|
|[PcfVizMaterial](./Class/PcfVizMaterial.md#class-pcfvizmaterial)|PCF sampling visualization material, outputs black/white binary shadow detection result|
|[PointsMaterial](./Class/PointsMaterial.md#class-pointsmaterial)|Points material, used for point cloud rendering, supporting point size and distance attenuation|
|[RawShaderMaterial](./Class/RawShaderMaterial.md#class-rawshadermaterial)|Raw shader material, extending ShaderMaterial without injecting built-in uniforms|
|[ReflectorMaterial](./Class/ReflectorMaterial.md#class-reflectormaterial)|Reflector material, dedicated to GroundReflector|
|[ShaderMaterial](./Class/ShaderMaterial.md#class-shadermaterial)|Custom shader material, allowing custom vertex/fragment shader source code|
|[ShadowBlitMaterial](./Class/ShadowBlitMaterial.md#class-shadowblitmaterial)|Shadow map fullscreen blit material, samples shadowMap with fullscreen quad|
|[ShadowFrustumMaterial](./Class/ShadowFrustumMaterial.md#class-shadowfrustummaterial)|Shadow camera frustum visualization material|
|[ShadowMaterial](./Class/ShadowMaterial.md#class-shadowmaterial)|Shadow material, can receive shadows but is itself fully transparent|
|[ShadowProjMaterial](./Class/ShadowProjMaterial.md#class-shadowprojmaterial)|Shadow projection UV visualization material, outputs shadow UV coverage|
|[SpriteMaterial](./Class/SpriteMaterial.md#class-spritematerial)|Sprite material, used for sprite rendering, supporting size attenuation and UV rotation|

