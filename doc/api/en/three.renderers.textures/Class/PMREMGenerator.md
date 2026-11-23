# Class
## class PMREMGenerator
```cj
public class PMREMGenerator <: IReleasable
```
PMREM generator class

### func fromColor\(Color\)
```cj
public func fromColor(c: Color): Texture
```
Generate a constant PMREM environment map from a solid color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color|Environment color|

Return: 

- CubeUV environment map (every level/face is that color)

### func fromCubemap\(CubeTexture,Float64\)
```cj
public func fromCubemap(cubeTex: CubeTexture, sigma: Float64): Texture
```
Generate a PMREM environment map from a cube texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cubeTex|CubeTexture|Source cube texture (6 RGBA8 faces, order +X/-X/+Y/-Y/+Z/-Z)sigma Extra blur strength|
|sigma|Float64||

Return: 

- CubeUV environment map

### func fromEquirectangular\(Texture,Float64\)
```cj
public func fromEquirectangular(tex: Texture, sigma: Float64): Texture
```
Generate a PMREM environment map from an equirectangular texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tex|Texture|Source equirectangular texture (RGBA8)sigma Extra blur strength|
|sigma|Float64||

Return: 

- CubeUV environment map

### func fromScene\(IScene,Float64,Float64,Float64\)
```cj
public func fromScene(scene: IScene, sigma: Float64, near: Float64, far: Float64): Texture
```
Generate pre-filtered mipmap environment map from scene

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|IScene|Scene interfacesigma Extra blur strength (added on top of each level's roughness)near Near clipping plane (unused by the CPU path; kept to match the common engine signature)far Far clipping plane (same as above)|
|sigma|Float64||
|near|Float64||
|far|Float64||

Return: 

- Generated CubeUV environment map

### func init\(\)
```cj
public init()
```
Construct PMREM generator

### func release\(\)
```cj
public func release(): Bool
```
Release resources held by the generator

### let LEVEL\_FACE\_SIZES
```cj
public static let LEVEL_FACE_SIZES: Array < Int64 >=[256, 128, 64, 32, 16]
```
Cube face size per roughness level in pixels (level 0 is the sharpest)

### let NUM\_LEVELS
```cj
public static let NUM_LEVELS: Int64 = 5
```
Number of roughness levels

### let TEX\_HEIGHT
```cj
public static let TEX_HEIGHT: Int64 = 992
```
CubeUV atlas height (2 x (256+128+64+32+16))

### let TEX\_WIDTH
```cj
public static let TEX_WIDTH: Int64 = 768
```
CubeUV atlas width (3 x 256)

### var kind
```cj
public var kind: String
```
Type tag

