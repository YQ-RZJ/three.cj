# 类
## class SkeletalAnimationData
```cj
public class SkeletalAnimationData
```
骨骼动画运行时数据

### func init\(\)
```cj
public init()
```
默认构造函数（空数据）

### func init\(Float32,Int,Array<JointTrack>\)
```cj
public init(duration: Float32, numTracks: Int, tracks: Array < JointTrack >)
```
从构建数据构造（供 AnimationBuilder 使用）

参数: 

|名称|类型|描述|
|---|---|---|
|duration|Float32||
|numTracks|Int||
|tracks|Array<JointTrack>||

### func numSoaJoints\(\)
```cj
public func numSoaJoints(): Int
```
获取 SoA 元素数量（每 4 个关节一个 SoaTransform）

### func track\(Int\)
```cj
public func track(track: Int): JointTrack
```
获取指定轨道

参数: 

|名称|类型|描述|
|---|---|---|
|track|Int||

### var duration
```cj
public var duration: Float32
```
动画时长（秒）

### var numTracks
```cj
public var numTracks: Int
```
轨道数（等于骨骼关节数）

### var tracks
```cj
public var tracks: Array < JointTrack >
```
每关节轨道数据（长度 = numTracks）

