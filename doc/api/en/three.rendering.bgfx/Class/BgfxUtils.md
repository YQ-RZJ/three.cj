# Class
## class BgfxUtils
```cj
public class BgfxUtils
```
bgfx utility class providing format conversion and capability queries

### func convertDrawMode\(Int64\)
```cj
public static func convertDrawMode(mode: Int64): UInt64
```
Convert three.js draw mode to bgfx primitive type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mode|Int64|Draw mode constant|

Return: 

- bgfx primitive type flag

### func convert\(Int64,String\)
```cj
public static func convert(format: Int64, colorSpace: String): Option < UInt32 >
```
Convert three.js pixel format to bgfx TextureFormat

Parameter: 

|Name|Type|Describe|
|---|---|---|
|format|Int64|three.js pixel format constantcolorSpace Color space (used to determine sRGB variant)|
|colorSpace|String||

Return: 

- bgfx TextureFormat value, returns None when unsupported

