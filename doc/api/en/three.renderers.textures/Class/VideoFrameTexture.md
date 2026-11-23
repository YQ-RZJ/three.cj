# Class
## class VideoFrameTexture
```cj
public open class VideoFrameTexture <: VideoTexture
```
VideoFrame texture class

### func clone\(\)
```cj
public override func clone(): Texture
```
Return a new VideoFrame texture instance with the same values as this instance

Return: 

- Cloned VideoFrame texture instance

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
Construct a new VideoFrame texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Texture width in pixelsheight Texture height in pixels|
|height|Int64||

### func setFrame\(Array<UInt8>\)
```cj
public func setFrame(frame: Array < UInt8 >): Unit
```
Set current frame pixel data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frame|Array<UInt8>|Current frame pixel data|

