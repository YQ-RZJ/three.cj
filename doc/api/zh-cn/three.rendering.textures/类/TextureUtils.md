# 类
## class TextureUtils
```cj
public class TextureUtils
```
纹理工具类

### func contain\(Texture,Float64\)
```cj
public static func contain(texture: Texture, aspect: Float64): Texture
```
按包含模式缩放纹理：在不裁剪/拉伸的前提下尽可能大地填充表面

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|目标纹理aspect 目标表面的宽高比|
|aspect|Float64||

返回: 

- 被修改的纹理

### func cover\(Texture,Float64\)
```cj
public static func cover(texture: Texture, aspect: Float64): Texture
```
按覆盖模式缩放纹理

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|目标纹理aspect 目标表面的宽高比|
|aspect|Float64||

返回: 

- 被修改的纹理

### func fill\(Texture\)
```cj
public static func fill(texture: Texture): Texture
```
将纹理重置为默认变换

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|目标纹理|

返回: 

- 被修改的纹理

### func getByteLength\(Int64,Int64,Int64,Int64\)
```cj
public static func getByteLength(width: Int64, height: Int64, format: Int64, `type`: Int64): Int64
```
估算给定尺寸、格式、类型下的纹理字节长度

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|纹理宽度height 纹理高度format 纹理格式type 纹理类型|
|height|Int64||
|format|Int64||
|`type`|Int64||

返回: 

- 字节长度

