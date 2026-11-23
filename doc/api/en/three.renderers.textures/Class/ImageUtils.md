# Class
## class ImageUtils
```cj
public class ImageUtils
```
Image utilities class

### func getDataURL\(Array<UInt8>,String\)
```cj
public static func getDataURL(image: Array < UInt8 >, `type`: String): String
```
Return the data URI string of the image

Parameter: 

|Name|Type|Describe|
|---|---|---|
|image|Array<UInt8>|Image byte data (Cangjie side replacement for HTMLImageElement)type MIME type, defaults to "image/png"|
|`type`|String||

Return: 

- Data URI string (Cangjie side returns empty string as placeholder)

### func getDataURL\(Array<UInt8>\)
```cj
public static func getDataURL(image: Array < UInt8 >): String
```
Convenience overload with default type image/png

Parameter: 

|Name|Type|Describe|
|---|---|---|
|image|Array<UInt8>|Image byte data|

Return: 

- Data URI string

### func sRGBToLinear\(Array<UInt8>\)
```cj
public static func sRGBToLinear(image: Array < UInt8 >): Array < UInt8 >
```
Convert image data from sRGB color space to Linear color space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|image|Array<UInt8>|RGBA byte sequence (length = width*height*4)|

Return: 

- New byte array after conversion (does not modify input)

