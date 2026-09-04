# 包 three.resource.loader 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[AnimationLoader](./类/AnimationLoader.md#class-animationloader)|动画加载器，加载 JSON 格式的动画剪辑文件|
|[AudioLoader](./类/AudioLoader.md#class-audioloader)|音频文件加载器|
|[BufferGeometryLoader](./类/BufferGeometryLoader.md#class-buffergeometryloader)|几何体加载器，加载 JSON 格式的 BufferGeometry 数据|
|[BytesLoadResult](./类/BytesLoadResult.md#class-bytesloadresult)|BytesLoadResult：字节数组加载结果包装（Array<UInt8>）|
|[ClipsLoadResult](./类/ClipsLoadResult.md#class-clipsloadresult)|ClipsLoadResult：动画剪辑数组加载结果包装（ArrayList<AnimationClip>）|
|[CompressedTextureLoader](./类/CompressedTextureLoader.md#class-compressedtextureloader)|压缩纹理加载器抽象基类，用于加载 S3TC、ASTC、ETC 等压缩纹理格式|
|[CubeTextureLoader](./类/CubeTextureLoader.md#class-cubetextureloader)|立方体贴图加载器，加载 6 张图片组成立方体贴图|
|[DDSLoader](./类/DDSLoader.md#class-ddsloader)|S3TC 压缩纹理加载器|
|[DataTextureLoader](./类/DataTextureLoader.md#class-datatextureloader)|数据纹理加载器抽象基类，加载 RGBE、EXR、TGA 等二进制纹理格式|
|[EXRLoader](./类/EXRLoader.md#class-exrloader)|EXR 加载器，加载 OpenEXR 格式的 HDR 纹理|
|[FileLoader](./类/FileLoader.md#class-fileloader)|文件加载器，用于通过本地文件系统加载文件|
|[FontLoader](./类/FontLoader.md#class-fontloader)|字体加载器，加载 JSON 格式的字体文件|
|[GltfLoader](./类/GltfLoader.md#class-gltfloader)|glTF 加载器，加载 .gltf / .glb 格式的 3D 模型|
|[HDRLoader](./类/HDRLoader.md#class-hdrloader)|Radiance RGBE HDR 加载器|
|[ImageLoader](./类/ImageLoader.md#class-imageloader)|图片加载器，用于加载图片资源|
|[KTXLoader](./类/KTXLoader.md#class-ktxloader)|KTX 压缩纹理加载器|
|[LoaderUtils](./类/LoaderUtils.md#class-loaderutils)|加载器工具类|
|[Loader](./类/Loader.md#class-loader)|加载器抽象基类|
|[LoadingManager](./类/LoadingManager.md#class-loadingmanager)|加载管理器，跟踪已加载项目并提供回调|
|[MTLLoader](./类/MTLLoader.md#class-mtlloader)|MTL 加载器，加载 Wavefront MTL 格式的材质库|
|[MaterialCreator](./类/MaterialCreator.md#class-materialcreator)|材质创建器：持有 MTL 解析出的材质信息，按名称懒创建材质|
|[MaterialLoader](./类/MaterialLoader.md#class-materialloader)|材质加载器，加载 JSON 格式的材质数据|
|[OBJLoader](./类/OBJLoader.md#class-objloader)|OBJ 加载器，加载 Wavefront OBJ 格式的 3D 模型|
|[ObjectLoader](./类/ObjectLoader.md#class-objectloader)|对象加载器，加载 JSON 格式的完整场景层级结构|
|[PLYLoader](./类/PLYLoader.md#class-plyloader)|PLY 加载器，加载 Stanford PLY 格式的点云/网格|
|[PVRLoader](./类/PVRLoader.md#class-pvrloader)|PVR 压缩纹理加载器|
|[RGBELoader](./类/RGBELoader.md#class-rgbeloader)|RGBE 加载器（兼容旧名）|
|[STLLoader](./类/STLLoader.md#class-stlloader)|STL 加载器，加载 STL（STereoLithography）格式的 3D 模型|
|[StringLoadResult](./类/StringLoadResult.md#class-stringloadresult)|StringLoadResult：字符串加载结果包装|
|[TGALoader](./类/TGALoader.md#class-tgaloader)|TGA 加载器，加载 Targa 格式图片为 DataTexture|
|[TextureLoader](./类/TextureLoader.md#class-textureloader)|纹理加载器，用于加载图片并创建 Texture 对象|
|[_ObjParseObject](./类/_ObjParseObject.md#class-_objparseobject)|OBJ 解析对象（对应一个 o/g 声明）|
|[_ObjParserState](./类/_ObjParserState.md#class-_objparserstate)|OBJ 解析状态机|
|[_ObjSourceMaterial](./类/_ObjSourceMaterial.md#class-_objsourcematerial)|OBJ 源材质段（usemtl 切分信息）|

### 变量与常量
|  名称   | 描述  |
|  ----  | ----  |
|[LOADER_DEFAULT_MATERIAL_NAME](./变量与常量.md#let-loader_default_material_name)|加载器创建材质时使用的默认材质名|

