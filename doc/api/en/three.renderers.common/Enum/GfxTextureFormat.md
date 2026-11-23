# Enum
## enum GfxTextureFormat
```cj
public enum GfxTextureFormat
```
Texture pixel format

### A8
```cj
A8
```
---- 未压缩格式 ----

### ASTC10X10
```cj
ASTC10X10
```


### ASTC10X5
```cj
ASTC10X5
```


### ASTC10X6
```cj
ASTC10X6
```


### ASTC10X8
```cj
ASTC10X8
```


### ASTC12X10
```cj
ASTC12X10
```


### ASTC12X12
```cj
ASTC12X12
```


### ASTC4X4
```cj
ASTC4X4
```
ETC2A，RGBA，8bpp

### ASTC5X4
```cj
ASTC5X4
```


### ASTC5X5
```cj
ASTC5X5
```


### ASTC6X5
```cj
ASTC6X5
```


### ASTC6X6
```cj
ASTC6X6
```


### ASTC8X5
```cj
ASTC8X5
```


### ASTC8X6
```cj
ASTC8X6
```


### ASTC8X8
```cj
ASTC8X8
```


### BC1
```cj
BC1
```
---- 压缩格式 ----

### BC2
```cj
BC2
```
BC1 (DXT1)，RGB，4bpp

### BC3
```cj
BC3
```
BC2 (DXT3)，RGBA，8bpp

### BC4
```cj
BC4
```
BC3 (DXT5)，RGBA，8bpp

### BC5
```cj
BC5
```
BC4，单通道，4bpp

### BC6H
```cj
BC6H
```
BC5，双通道，8bpp

### BC7
```cj
BC7
```
BC6H，HDR RGB，8bpp

### D24S8
```cj
D24S8
```
24 位深度

### D24
```cj
D24
```
---- 深度格式 ----

### D32F
```cj
D32F
```
32 位深度

### D32
```cj
D32
```
24 位深度 + 8 位模板

### ETC1
```cj
ETC1
```
BC7，高质量 RGBA，8bpp

### ETC2A
```cj
ETC2A
```
ETC2，RGB，4bpp

### ETC2
```cj
ETC2
```
ETC1，RGB，4bpp

### R16F
```cj
R16F
```
16 位红通道（有符号整数）

### R16I
```cj
R16I
```
16 位红通道（无符号归一化）

### R16
```cj
R16
```
8 位红通道（无符号归一化）

### R8
```cj
R8
```
8 位 alpha 通道

### RG11B10F
```cj
RG11B10F
```
32 位 x4 RGBA（单精度浮点）

### RG16F
```cj
RG16F
```
8+8 位 RG（无符号归一化）

### RG32I
```cj
RG32I
```
16+16 位 RG（半精度浮点）

### RG8
```cj
RG8
```
16 位红通道（半精度浮点）

### RGB9E5F
```cj
RGB9E5F
```
32+32 位 RG（有符号整数）

### RGBA16F
```cj
RGBA16F
```
8+8+8+8 位 RGBA（无符号归一化）

### RGBA32F
```cj
RGBA32F
```
32 位 x4 RGBA（有符号整数）

### RGBA32I
```cj
RGBA32I
```
16 位 x4 RGBA（半精度浮点）

### RGBA8
```cj
RGBA8
```
9+9+9+5 位 RGB（共享指数浮点）

### func value\(\)
```cj
public func value(): UInt32
```
32 位浮点深度

