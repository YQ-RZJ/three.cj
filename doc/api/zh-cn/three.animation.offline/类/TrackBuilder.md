# 类
## class TrackBuilder
```cj
public class TrackBuilder
```
通道构建器

### func invokeFloat3\(RawFloat3Track\)
```cj
public func invokeFloat3(input: RawFloat3Track): Option < SkeletalTrackData >
```
构建三分量向量通道

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawFloat3Track|离线三分量向量通道数据|

返回: 

- Some(SkeletalTrackData) 或 None

### func invokeQuaternion\(RawQuaternionTrack\)
```cj
public func invokeQuaternion(input: RawQuaternionTrack): Option < SkeletalTrackData >
```
构建四元数通道

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawQuaternionTrack|离线四元数通道数据|

返回: 

- Some(SkeletalTrackData) 或 None

### func invoke\(RawFloatTrack\)
```cj
public func invoke(input: RawFloatTrack): Option < SkeletalTrackData >
```
构建浮点通道

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawFloatTrack|离线浮点通道数据|

返回: 

- Some(SkeletalTrackData) 或 None

