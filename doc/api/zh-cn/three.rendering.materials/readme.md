# 包 three.rendering.materials 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[DepthVizMaterial](./类/DepthVizMaterial.md#class-depthvizmaterial)|深度图灰度可视化材质，将线性深度归一化映射为灰度|
|[LightDirMaterial](./类/LightDirMaterial.md#class-lightdirmaterial)|光源方向N·L可视化材质，将N·L映射为灰度|
|[LineBasicMaterial](./类/LineBasicMaterial.md#class-linebasicmaterial)|线段基础材质，支持线宽、线帽和线连接样式|
|[LineDashedMaterial](./类/LineDashedMaterial.md#class-linedashedmaterial)|虚线材质，支持dashSize和gapSize|
|[MaterialOverrideScope](./类/MaterialOverrideScope.md#class-materialoverridescope)|per-mesh材质替换器栈（回调注入式）|
|[Material](./类/Material.md#class-material)|材质抽象基类，所有具体材质类型继承本类|
|[Materials](./类/Materials.md#class-materials)|材质工具类，提供材质类型查询方法|
|[MeshBasicMaterial](./类/MeshBasicMaterial.md#class-meshbasicmaterial)|网格基础材质，以简单方式（无光照）渲染几何体|
|[MeshDepthMaterial](./类/MeshDepthMaterial.md#class-meshdepthmaterial)|基于深度绘制几何体的材质|
|[MeshDistanceMaterial](./类/MeshDistanceMaterial.md#class-meshdistancematerial)|用于实现点光源阴影映射的距离材质|
|[MeshLambertMaterial](./类/MeshLambertMaterial.md#class-meshlambertmaterial)|Lambert材质，支持自发光、环境贴图和flatShading|
|[MeshMatcapMaterial](./类/MeshMatcapMaterial.md#class-meshmatcapmaterial)|Matcap材质，使用材质捕获贴图进行渲染|
|[MeshNormalMaterial](./类/MeshNormalMaterial.md#class-meshnormalmaterial)|法线材质，将法线向量映射为RGB颜色进行渲染|
|[MeshPhongMaterial](./类/MeshPhongMaterial.md#class-meshphongmaterial)|Phong材质，支持镜面高光和光泽度|
|[MeshPhysicalMaterial](./类/MeshPhysicalMaterial.md#class-meshphysicalmaterial)|物理材质，在Standard材质基础上增加清漆、透射等高级PBR属性|
|[MeshStandardMaterial](./类/MeshStandardMaterial.md#class-meshstandardmaterial)|基于PBR的标准材质，支持金属度/粗糙度工作流|
|[MeshToonMaterial](./类/MeshToonMaterial.md#class-meshtoonmaterial)|卡通材质，使用渐变贴图控制明暗分界实现卡通渲染效果|
|[PcfVizMaterial](./类/PcfVizMaterial.md#class-pcfvizmaterial)|PCF采样结果可视化材质，输出黑白二值阴影检测结果|
|[PointsMaterial](./类/PointsMaterial.md#class-pointsmaterial)|点材质，用于点云渲染，支持点大小和距离衰减|
|[RawShaderMaterial](./类/RawShaderMaterial.md#class-rawshadermaterial)|原始着色器材质，继承ShaderMaterial但不注入内置uniform|
|[ReflectorMaterial](./类/ReflectorMaterial.md#class-reflectormaterial)|反射面材质，GroundReflector专用|
|[ShaderMaterial](./类/ShaderMaterial.md#class-shadermaterial)|自定义着色器材质，允许传入自定义vertex/fragment shader源码|
|[ShadowBlitMaterial](./类/ShadowBlitMaterial.md#class-shadowblitmaterial)|阴影贴图全屏blit材质，用全屏四边形采样shadowMap铺满屏幕|
|[ShadowFrustumMaterial](./类/ShadowFrustumMaterial.md#class-shadowfrustummaterial)|阴影相机视锥可视化材质|
|[ShadowMaterial](./类/ShadowMaterial.md#class-shadowmaterial)|阴影材质，可以接收阴影但本身完全透明|
|[ShadowProjMaterial](./类/ShadowProjMaterial.md#class-shadowprojmaterial)|阴影投影UV可视化材质，输出阴影UV覆盖范围|
|[SpriteMaterial](./类/SpriteMaterial.md#class-spritematerial)|Sprite材质，用于精灵图渲染，支持尺寸衰减和UV旋转|

