# Package three.resource.loader 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[AnimationLoader](./Class/AnimationLoader.md#class-animationloader)|Animation loader, loads JSON-format animation clip files|
|[AudioLoader](./Class/AudioLoader.md#class-audioloader)|Audio file loader|
|[BufferGeometryLoader](./Class/BufferGeometryLoader.md#class-buffergeometryloader)|Buffer geometry loader, loads JSON-format BufferGeometry data|
|[BytesLoadResult](./Class/BytesLoadResult.md#class-bytesloadresult)|BytesLoadResult: Byte array load result wrapper (Array<UInt8>)|
|[ClipsLoadResult](./Class/ClipsLoadResult.md#class-clipsloadresult)|ClipsLoadResult: Animation clip array load result wrapper (ArrayList<AnimationClip>)|
|[CompressedTextureLoader](./Class/CompressedTextureLoader.md#class-compressedtextureloader)|Abstract base class for compressed texture loaders, for loading S3TC, ASTC, ETC compressed texture formats|
|[CubeTextureLoader](./Class/CubeTextureLoader.md#class-cubetextureloader)|Cube texture loader, loads 6 images to form a cube texture|
|[DDSLoader](./Class/DDSLoader.md#class-ddsloader)|S3TC compressed texture loader|
|[DataTextureLoader](./Class/DataTextureLoader.md#class-datatextureloader)|Abstract base class for data texture loaders, loading RGBE, EXR, TGA binary texture formats|
|[EXRLoader](./Class/EXRLoader.md#class-exrloader)|EXR loader, loads OpenEXR format HDR textures|
|[FileLoader](./Class/FileLoader.md#class-fileloader)|File loader for loading files via the local file system|
|[FontLoader](./Class/FontLoader.md#class-fontloader)|Font loader, loads JSON-format font files|
|[GltfAnimationChannel](./Class/GltfAnimationChannel.md#class-gltfanimationchannel)|Parsed glTF Animation Channel|
|[GltfAnimationData](./Class/GltfAnimationData.md#class-gltfanimationdata)|Parsed glTF Animation|
|[GltfAnimationSampler](./Class/GltfAnimationSampler.md#class-gltfanimationsampler)|Parsed glTF Animation Sampler|
|[GltfLoader](./Class/GltfLoader.md#class-gltfloader)|glTF loader, loads .gltf / .glb format 3D models|
|[GltfSkinData](./Class/GltfSkinData.md#class-gltfskindata)|Parsed glTF Skin|
|[HDRLoader](./Class/HDRLoader.md#class-hdrloader)|Radiance RGBE HDR loader|
|[ImageLoader](./Class/ImageLoader.md#class-imageloader)|Image loader, for loading image resources|
|[KTXLoader](./Class/KTXLoader.md#class-ktxloader)|KTX compressed texture loader|
|[LoaderUtils](./Class/LoaderUtils.md#class-loaderutils)|Loader utility class|
|[Loader](./Class/Loader.md#class-loader)|Abstract base class for loaders|
|[LoadingManager](./Class/LoadingManager.md#class-loadingmanager)|Loading manager that tracks loaded items and provides callbacks|
|[MTLLoader](./Class/MTLLoader.md#class-mtlloader)|MTL material definition loader|
|[MaterialCreator](./Class/MaterialCreator.md#class-materialcreator)|Material creator: holds material info parsed from MTL, lazily creates materials by name|
|[MaterialLoader](./Class/MaterialLoader.md#class-materialloader)|Material loader, loads JSON format materials|
|[OBJLoader](./Class/OBJLoader.md#class-objloader)|OBJ model loader|
|[ObjectLoader](./Class/ObjectLoader.md#class-objectloader)|Object loader, loads JSON format complete scene hierarchy|
|[PLYLoader](./Class/PLYLoader.md#class-plyloader)|PLY loader, loads Stanford PLY format point clouds/meshes|
|[PVRLoader](./Class/PVRLoader.md#class-pvrloader)|PVR compressed texture loader|
|[RGBELoader](./Class/RGBELoader.md#class-rgbeloader)|RGBE loader (legacy compatible name)|
|[STLLoader](./Class/STLLoader.md#class-stlloader)|STL loader, loads STL (STereoLithography) format 3D models|
|[StringLoadResult](./Class/StringLoadResult.md#class-stringloadresult)|StringLoadResult: String load result wrapper|
|[TGALoader](./Class/TGALoader.md#class-tgaloader)|TGA loader, loads Targa format images as DataTexture|
|[TextureLoader](./Class/TextureLoader.md#class-textureloader)|Texture loader, loads images and creates Texture objects|
|[_ObjParseObject](./Class/_ObjParseObject.md#class-_objparseobject)|OBJ parse object (corresponding to an o/g declaration)|
|[_ObjParserState](./Class/_ObjParserState.md#class-_objparserstate)|OBJ parser state machine|
|[_ObjSourceMaterial](./Class/_ObjSourceMaterial.md#class-_objsourcematerial)|OBJ source material segment (usemtl split info)|

### Variables & constants
|  Name   | Describe  |
|  ----  | ----  |
|[LOADER_DEFAULT_MATERIAL_NAME](./Variables%20&%20constants.md#let-loader_default_material_name)|加载器创建材质时使用的默认材质名|

