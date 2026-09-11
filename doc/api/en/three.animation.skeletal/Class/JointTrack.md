# Class
## class JointTrack
```cj
public class JointTrack
```
Runtime keyframe data for a single joint track

### func init\(\)
```cj
public init()
```
Default constructor (empty channels)

### func init\(Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(transTimes: Array < Float32 >, transValues: Array < Float32 >, rotTimes: Array < Float32 >, rotValues: Array < Float32 >, scaleTimes: Array < Float32 >, scaleValues: Array < Float32 >)
```
Constructs from channel arrays

Parameter: 

|Name|Type|Describe|
|---|---|---|
|transTimes|Array<Float32>||
|transValues|Array<Float32>||
|rotTimes|Array<Float32>||
|rotValues|Array<Float32>||
|scaleTimes|Array<Float32>||
|scaleValues|Array<Float32>||

### func numRotKeyframes\(\)
```cj
public func numRotKeyframes(): Int
```
Number of rotation channel keyframes

### func numScaleKeyframes\(\)
```cj
public func numScaleKeyframes(): Int
```
Number of scale channel keyframes

### func numTransKeyframes\(\)
```cj
public func numTransKeyframes(): Int
```
Number of translation channel keyframes

### var rotTimes
```cj
public var rotTimes: Array < Float32 >
```
Rotation channel time points (ascending, seconds)

### var rotValues
```cj
public var rotValues: Array < Float32 >
```
Rotation channel values (4 components per keyframe, length = rotTimes.size * 4)

### var scaleTimes
```cj
public var scaleTimes: Array < Float32 >
```
Scale channel time points (ascending, seconds)

### var scaleValues
```cj
public var scaleValues: Array < Float32 >
```
Scale channel values (3 components per keyframe, length = scaleTimes.size * 3)

### var transTimes
```cj
public var transTimes: Array < Float32 >
```
Translation channel time points (ascending, seconds)

### var transValues
```cj
public var transValues: Array < Float32 >
```
Translation channel values (3 components per keyframe, length = transTimes.size * 3)

