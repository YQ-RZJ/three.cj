# 类
## class BgfxTextures
```cj
public class BgfxTextures
```
bgfx 纹理管理

### func convertTextureFlags\(Bool,Bool,Int64\)
```cj
public static func convertTextureFlags(sRGB: Bool, renderTarget: Bool, msaa: Int64): UInt64
```
将 three.js 纹理参数转换为 bgfx 纹理标志

参数: 

|名称|类型|描述|
|---|---|---|
|sRGB|Bool|是否使用 sRGBrenderTarget 是否为渲染目标msaa MSAA 采样数|
|renderTarget|Bool||
|msaa|Int64||

返回: 

- bgfx 纹理标志

### func createTexture2D\(Int64,Int64,Int64,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTexture2D(textureId: Int64, width: Int64, height: Int64, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
创建 2D 纹理

参数: 

|名称|类型|描述|
|---|---|---|
|textureId|Int64|纹理对象 IDwidth 纹理宽度height 纹理高度format bgfx 纹理格式flags 纹理标志（TEXTURE_RT、TEXTURE_SRGB 等）mem 纹理数据内存（Some=有数据；None=空 RT）|
|width|Int64||
|height|Int64||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

返回: 

- 纹理句柄

### func destroyTexture\(Int64\)
```cj
public func destroyTexture(textureId: Int64): Unit
```
销毁纹理

参数: 

|名称|类型|描述|
|---|---|---|
|textureId|Int64|纹理 ID|

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有纹理

### func get\(Int64\)
```cj
public func get(textureId: Int64): Option < TextureInfo >
```
获取纹理信息

参数: 

|名称|类型|描述|
|---|---|---|
|textureId|Int64|纹理 ID|

返回: 

- 纹理信息

### func init\(BgfxCapabilities,BgfxUtils,BgfxInfo,BgfxProperties\)
```cj
public init(capabilities!: BgfxCapabilities, utils!: BgfxUtils, info!: BgfxInfo, properties!: BgfxProperties)
```


参数: 

|名称|类型|描述|
|---|---|---|
|capabilities|BgfxCapabilities||
|utils|BgfxUtils||
|info|BgfxInfo||
|properties|BgfxProperties||

### func updateTexture2D\(Int64,UInt16,UInt16,UInt16,UInt16,BgfxMemory,UInt16\)
```cj
public func updateTexture2D(textureId: Int64, x: UInt16, y: UInt16, width: UInt16, height: UInt16, mem: BgfxMemory, pitch: UInt16): Unit
```
更新 2D 纹理数据

参数: 

|名称|类型|描述|
|---|---|---|
|textureId|Int64|纹理 IDx 更新区域 X 偏移y 更新区域 Y 偏移width 更新区域宽度height 更新区域高度mem 纹理数据内存pitch 行间距|
|x|UInt16||
|y|UInt16||
|width|UInt16||
|height|UInt16||
|mem|BgfxMemory||
|pitch|UInt16||

