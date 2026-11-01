# 类
## class PMREMGenerator
```cj
public class PMREMGenerator
```
PMREM 生成器类

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放生成器占用的资源

### func fromColor\(Color\)
```cj
public func fromColor(c: Color): Texture
```
从纯色生成常量 PMREM 环境贴图

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color|环境颜色|

返回: 

- CubeUV 环境贴图（所有层级/面均为该颜色）

### func fromCubemap\(CubeTexture,Float64\)
```cj
public func fromCubemap(cubeTex: CubeTexture, sigma: Float64): Texture
```
从立方体贴图生成 PMREM 环境贴图

参数: 

|名称|类型|描述|
|---|---|---|
|cubeTex|CubeTexture|源立方体贴图（6 面 RGBA8 数据，顺序 ±X/±Y/±Z）sigma 附加模糊强度|
|sigma|Float64||

返回: 

- CubeUV 环境贴图

### func fromEquirectangular\(Texture,Float64\)
```cj
public func fromEquirectangular(tex: Texture, sigma: Float64): Texture
```
从等距柱状投影贴图生成 PMREM 环境贴图

参数: 

|名称|类型|描述|
|---|---|---|
|tex|Texture|源等距柱状贴图（RGBA8）sigma 附加模糊强度|
|sigma|Float64||

返回: 

- CubeUV 环境贴图

### func fromScene\(IScene,Float64,Float64,Float64\)
```cj
public func fromScene(scene: IScene, sigma: Float64, near: Float64, far: Float64): Texture
```
从场景生成预过滤 Mipmap 环境贴图

参数: 

|名称|类型|描述|
|---|---|---|
|scene|IScene|场景接口sigma 附加模糊强度（叠加到各层 roughness 上）near 近裁剪面（CPU 生成路径未使用，保留以对齐通用引擎签名）far 远裁剪面（同上）|
|sigma|Float64||
|near|Float64||
|far|Float64||

返回: 

- 生成的 CubeUV 环境贴图

### func init\(\)
```cj
public init()
```
构造 PMREM 生成器

### let LEVEL\_FACE\_SIZES
```cj
public static let LEVEL_FACE_SIZES: Array < Int64 >=[256, 128, 64, 32, 16]
```
各 roughness 层级的立方体面尺寸（像素，level 0 最清晰）

### let NUM\_LEVELS
```cj
public static let NUM_LEVELS: Int64 = 5
```
roughness 层级数量

### let TEX\_HEIGHT
```cj
public static let TEX_HEIGHT: Int64 = 992
```
CubeUV 图集高度（2 × (256+128+64+32+16)）

### let TEX\_WIDTH
```cj
public static let TEX_WIDTH: Int64 = 768
```
CubeUV 图集宽度（3 × 256）

### var kind
```cj
public var kind: String
```
类型标签

