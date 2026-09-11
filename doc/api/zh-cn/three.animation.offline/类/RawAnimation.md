# 类
## class RawAnimation
```cj
public class RawAnimation
```
离线动画数据

### func addRotationKeyframe\(Int,Float32,Float32,Float32,Float32,Float32\)
```cj
public func addRotationKeyframe(track: Int, time: Float32, x: Float32, y: Float32, z: Float32, w: Float32): Unit
```
为指定轨道添加旋转关键帧

参数: 

|名称|类型|描述|
|---|---|---|
|track|Int|轨道索引|
|time|Float32|时间（秒）|
|x|Float32|四元数 x|
|y|Float32|四元数 y|
|z|Float32|四元数 z|
|w|Float32|四元数 w|

### func addScaleKeyframe\(Int,Float32,Vector3F\)
```cj
public func addScaleKeyframe(track: Int, time: Float32, value: Vector3F): Unit
```
为指定轨道添加缩放关键帧

参数: 

|名称|类型|描述|
|---|---|---|
|track|Int|轨道索引|
|time|Float32|时间（秒）|
|value|Vector3F|缩放值|

### func addTranslationKeyframe\(Int,Float32,Vector3F\)
```cj
public func addTranslationKeyframe(track: Int, time: Float32, value: Vector3F): Unit
```
为指定轨道添加平移关键帧

参数: 

|名称|类型|描述|
|---|---|---|
|track|Int|轨道索引|
|time|Float32|时间（秒）|
|value|Vector3F|平移值|

### func initTracks\(Int\)
```cj
public func initTracks(numTracks: Int): Unit
```
初始化指定轨道数的空关键帧列表

参数: 

|名称|类型|描述|
|---|---|---|
|numTracks|Int|轨道数|

### func init\(\)
```cj
public init()
```


### func numRotationKeyframes\(Int\)
```cj
public func numRotationKeyframes(track: Int): Int
```
获取指定轨道的旋转关键帧数量

参数: 

|名称|类型|描述|
|---|---|---|
|track|Int||

### func numScaleKeyframes\(Int\)
```cj
public func numScaleKeyframes(track: Int): Int
```
获取指定轨道的缩放关键帧数量

参数: 

|名称|类型|描述|
|---|---|---|
|track|Int||

### func numTranslationKeyframes\(Int\)
```cj
public func numTranslationKeyframes(track: Int): Int
```
获取指定轨道的平移关键帧数量

参数: 

|名称|类型|描述|
|---|---|---|
|track|Int||

### func recalcDuration\(\)
```cj
public func recalcDuration(): Unit
```
重新计算动画时长（取所有关键帧的最大时间）

### func sortKeyframes\(\)
```cj
public func sortKeyframes(): Unit
```
排序所有轨道的关键帧（按时间升序）

### func validate\(\)
```cj
public func validate(): Bool
```
验证动画数据合法性

返回: 

- true 表示数据合法

### var duration
```cj
public var duration: Float32
```
动画时长（秒）

### var name
```cj
public var name: String
```
动画名称

### var rotations
```cj
public var rotations: ArrayList < ArrayList < QuaternionKeyframe >>
```
每个轨道的旋转关键帧

### var scales
```cj
public var scales: ArrayList < ArrayList < Float3Keyframe >>
```
每个轨道的缩放关键帧

### var trackCount
```cj
public var trackCount: Int
```
轨道数（应等于骨骼关节数）

### var translations
```cj
public var translations: ArrayList < ArrayList < Float3Keyframe >>
```
每个轨道的平移关键帧

