# 类
## class ImageUtils
```cj
public class ImageUtils
```
图像工具类

### func getDataURL\(Array<UInt8>,String\)
```cj
public static func getDataURL(image: Array < UInt8 >, `type`: String): String
```
返回图像的 data URI 字符串

参数: 

|名称|类型|描述|
|---|---|---|
|image|Array<UInt8>|图像的字节数据（仓颉侧替代 HTMLImageElement）type MIME 类型，默认 "image/png"|
|`type`|String||

返回: 

- data URI 字符串（仓颉侧返回空字符串占位）

### func getDataURL\(Array<UInt8>\)
```cj
public static func getDataURL(image: Array < UInt8 >): String
```
缺省类型为 image/png 的便捷重载

参数: 

|名称|类型|描述|
|---|---|---|
|image|Array<UInt8>|图像的字节数据|

返回: 

- data URI 字符串

### func sRGBToLinear\(Array<UInt8>\)
```cj
public static func sRGBToLinear(image: Array < UInt8 >): Array < UInt8 >
```
将 sRGB 颜色空间的图像数据转换为 Linear 颜色空间

参数: 

|名称|类型|描述|
|---|---|---|
|image|Array<UInt8>|RGBA 字节序列（length = width*height*4）|

返回: 

- 转换后的新字节数组（不修改入参）

