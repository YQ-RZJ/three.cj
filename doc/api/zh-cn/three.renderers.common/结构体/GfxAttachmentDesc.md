# 结构体
## struct GfxAttachmentDesc
```cj
public struct GfxAttachmentDesc
```
帧缓冲附着描述

### func init\(GfxTextureHandle,GfxAccess,UInt16,UInt16,UInt8,UInt8\)
```cj
public init(texture: GfxTextureHandle, access!: GfxAccess = GfxAccess.Write, layer!: UInt16 = 0u16, numLayers!: UInt16 = 1u16, mip!: UInt8 = 0u8, resolve!: UInt8 = 0u8)
```


参数: 

|名称|类型|描述|
|---|---|---|
|texture|GfxTextureHandle||
|access|GfxAccess||
|layer|UInt16||
|numLayers|UInt16||
|mip|UInt8||
|resolve|UInt8||

### let access
```cj
public let access: GfxAccess
```
访问模式

### let layer
```cj
public let layer: UInt16
```
数组层起始索引

### let mip
```cj
public let mip: UInt8
```
mip 级

### let numLayers
```cj
public let numLayers: UInt16
```
数组层数

### let resolve
```cj
public let resolve: UInt8
```
resolve 目标 mip

### let texture
```cj
public let texture: GfxTextureHandle
```
附着纹理

