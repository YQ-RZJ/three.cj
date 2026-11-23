# Struct
## struct GfxCapsSummary
```cj
public struct GfxCapsSummary
```
Device capability summary

### func init\(GfxRendererType,UInt16,UInt16,UInt64,Bool,UInt32,UInt32\)
```cj
public init(rendererType: GfxRendererType, vendorId!: UInt16 = 0u16, deviceId!: UInt16 = 0u16, supported!: UInt64 = 0u64, originBottomLeft!: Bool = false, maxTextureSize!: UInt32 = 0u32, maxViews!: UInt32 = 0u32)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|rendererType|GfxRendererType||
|vendorId|UInt16||
|deviceId|UInt16||
|supported|UInt64||
|originBottomLeft|Bool||
|maxTextureSize|UInt32||
|maxViews|UInt32||

### let deviceId
```cj
public let deviceId: UInt16
```
GPU 设备 ID（0 = 未知）

### let maxTextureSize
```cj
public let maxTextureSize: UInt32
```
最大纹理尺寸

### let maxViews
```cj
public let maxViews: UInt32
```
最大视图数

### let originBottomLeft
```cj
public let originBottomLeft: Bool
```
纹理坐标原点是否在左下角

### let rendererType
```cj
public let rendererType: GfxRendererType
```
当前渲染后端类型

### let supported
```cj
public let supported: UInt64
```
能力位集（后端定义的 capability 位组合）

### let vendorId
```cj
public let vendorId: UInt16
```
GPU 厂商 ID（0 = 未知）

