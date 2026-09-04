# 类
## class VideoFrameTexture
```cj
public open class VideoFrameTexture <: VideoTexture
```
VideoFrame 纹理类

### func clone\(\)
```cj
public override func clone(): Texture
```
返回一个与本实例值相同的新 VideoFrame 纹理实例

返回: 

- 克隆的 VideoFrame 纹理实例

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
构造一个新的 VideoFrame 纹理

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|纹理宽度（像素）height 纹理高度（像素）|
|height|Int64||

### func setFrame\(Array<UInt8>\)
```cj
public func setFrame(frame: Array < UInt8 >): Unit
```
设置当前帧的像素数据

参数: 

|名称|类型|描述|
|---|---|---|
|frame|Array<UInt8>|当前帧像素数据|

