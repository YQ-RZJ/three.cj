# Class
## class BloomMipLevel
```cj
public class BloomMipLevel
```
单级金字塔 RT 资源（水平 + 垂直各一个 RT）。

### func init\(\)
```cj
public init()
```


### var height
```cj
public var height: Int64 = 0
```
该级高度

### var horizontalFB
```cj
public var horizontalFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
```
水平模糊输出 RT（width × height）

### var horizontalTex
```cj
public var horizontalTex: TextureHandle = INVALID_TEXTURE_HANDLE
```
水平模糊输出纹理

### var kernelRadius
```cj
public var kernelRadius: Int64 = 0
```
高斯核半径（6/10/14/18/22）

### var verticalFB
```cj
public var verticalFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
```
垂直模糊输出 RT

### var verticalTex
```cj
public var verticalTex: TextureHandle = INVALID_TEXTURE_HANDLE
```
垂直模糊输出纹理

### var width
```cj
public var width: Int64 = 0
```
该级宽度

