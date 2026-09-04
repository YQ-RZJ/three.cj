# 类
## class BgfxUtils
```cj
public class BgfxUtils
```
bgfx 工具类，提供格式转换和能力查询

### func convertDrawMode\(Int64\)
```cj
public static func convertDrawMode(mode: Int64): UInt64
```
将 three.js 绘制模式转换为 bgfx 图元类型

参数: 

|名称|类型|描述|
|---|---|---|
|mode|Int64|绘制模式常量|

返回: 

- bgfx 图元类型标志位

### func convert\(Int64,String\)
```cj
public static func convert(format: Int64, colorSpace: String): Option < UInt32 >
```
将 three.js 像素格式转换为 bgfx TextureFormat

参数: 

|名称|类型|描述|
|---|---|---|
|format|Int64|three.js 像素格式常量colorSpace 颜色空间（用于确定 sRGB 变体）|
|colorSpace|String||

返回: 

- bgfx TextureFormat 值，不支持时返回 None

