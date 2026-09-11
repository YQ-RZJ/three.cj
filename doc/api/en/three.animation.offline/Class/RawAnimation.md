# Class
## class RawAnimation
```cj
public class RawAnimation
```
Offline animation data with per-joint keyframe lists

### func addRotationKeyframe\(Int,Float32,Float32,Float32,Float32,Float32\)
```cj
public func addRotationKeyframe(track: Int, time: Float32, x: Float32, y: Float32, z: Float32, w: Float32): Unit
```
Adds a rotation keyframe to the given track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|track|Int|The track index|
|time|Float32|The time in seconds|
|x|Float32|Quaternion x|
|y|Float32|Quaternion y|
|z|Float32|Quaternion z|
|w|Float32|Quaternion w|

### func addScaleKeyframe\(Int,Float32,Vector3F\)
```cj
public func addScaleKeyframe(track: Int, time: Float32, value: Vector3F): Unit
```
Adds a scale keyframe to the given track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|track|Int|The track index|
|time|Float32|The time in seconds|
|value|Vector3F|The scale value|

### func addTranslationKeyframe\(Int,Float32,Vector3F\)
```cj
public func addTranslationKeyframe(track: Int, time: Float32, value: Vector3F): Unit
```
Adds a translation keyframe to the given track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|track|Int|The track index|
|time|Float32|The time in seconds|
|value|Vector3F|The translation value|

### func initTracks\(Int\)
```cj
public func initTracks(numTracks: Int): Unit
```
Initializes empty keyframe lists for the given number of tracks

Parameter: 

|Name|Type|Describe|
|---|---|---|
|numTracks|Int|The number of tracks|

### func init\(\)
```cj
public init()
```


### func numRotationKeyframes\(Int\)
```cj
public func numRotationKeyframes(track: Int): Int
```
Returns the number of rotation keyframes of the given track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|track|Int||

### func numScaleKeyframes\(Int\)
```cj
public func numScaleKeyframes(track: Int): Int
```
Returns the number of scale keyframes of the given track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|track|Int||

### func numTranslationKeyframes\(Int\)
```cj
public func numTranslationKeyframes(track: Int): Int
```
Returns the number of translation keyframes of the given track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|track|Int||

### func recalcDuration\(\)
```cj
public func recalcDuration(): Unit
```
Recalculates the animation duration (the maximum time of all keyframes)

### func sortKeyframes\(\)
```cj
public func sortKeyframes(): Unit
```
Sorts the keyframes of all tracks by ascending time

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the animation data

Return: 

- true if the data is valid

### var duration
```cj
public var duration: Float32
```
Animation duration in seconds

### var name
```cj
public var name: String
```
Animation name

### var rotations
```cj
public var rotations: ArrayList < ArrayList < QuaternionKeyframe >>
```
Rotation keyframes per track

### var scales
```cj
public var scales: ArrayList < ArrayList < Float3Keyframe >>
```
Scale keyframes per track

### var trackCount
```cj
public var trackCount: Int
```
Track count (should equal the skeleton joint count)

### var translations
```cj
public var translations: ArrayList < ArrayList < Float3Keyframe >>
```
Translation keyframes per track

