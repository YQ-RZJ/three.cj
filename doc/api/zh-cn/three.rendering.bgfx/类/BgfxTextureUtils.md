# 类
## class BgfxTextureUtils
```cj
public class BgfxTextureUtils
```
bgfx 纹理工具

### func convertFormat\(Int64\)
```cj
public func convertFormat(format: Int64): UInt32
```
将 three.js 像素格式转换为 bgfx TextureFormat

参数: 

|名称|类型|描述|
|---|---|---|
|format|Int64|three.js 像素格式常量|

返回: 

- bgfx TextureFormat 值

### func estimateMemory\(Int64,Int64,Int64,Bool\)
```cj
public func estimateMemory(width: Int64, height: Int64, format: Int64, hasMipmaps: Bool): Int64
```
获取纹理的内存大小估算

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|纹理宽度height 纹理高度format 像素格式hasMipmaps 是否有 mipmap|
|height|Int64||
|format|Int64||
|hasMipmaps|Bool||

返回: 

- 估算的内存大小（字节）

### func init\(BgfxUtils\)
```cj
public init(bgfxUtils!: BgfxUtils = BgfxUtils())
```


参数: 

|名称|类型|描述|
|---|---|---|
|bgfxUtils|BgfxUtils||

### func isPowerOfTwo\(Int64\)
```cj
public func isPowerOfTwo(value: Int64): Bool
```
检查尺寸是否为 2 的幂

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|待检查的值|

返回: 

- 是否为 2 的幂

### func needsMipmaps\(Int64,Int64,Int64,Bool\)
```cj
public func needsMipmaps(minFilter: Int64, width: Int64, height: Int64, isPowerOfTwo: Bool): Bool
```
检查纹理是否需要生成 mipmap

参数: 

|名称|类型|描述|
|---|---|---|
|minFilter|Int64|缩小过滤模式width 纹理宽度height 纹理高度isPowerOfTwo 尺寸是否为 2 的幂|
|width|Int64||
|height|Int64||
|isPowerOfTwo|Bool||

返回: 

- 是否需要 mipmap

