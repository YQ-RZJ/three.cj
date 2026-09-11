# Class
## class RawQuaternionTrack
```cj
public class RawQuaternionTrack
```
Offline quaternion channel data

### func addKeyframe\(Float32,Float32,Float32,Float32,Float32\)
```cj
public func addKeyframe(time: Float32, x: Float32, y: Float32, z: Float32, w: Float32): Unit
```
Adds a keyframe

Parameter: 

|Name|Type|Describe|
|---|---|---|
|time|Float32||
|x|Float32||
|y|Float32||
|z|Float32||
|w|Float32||

### func init\(String\)
```cj
public init(name: String)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func numKeyframes\(\)
```cj
public func numKeyframes(): Int
```
Returns the number of keyframes

### func sortKeyframes\(\)
```cj
public func sortKeyframes(): Unit
```
Sorts the keyframes by ascending time

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the data

Return: 

- true if the data is valid

### var keyframes
```cj
public var keyframes: ArrayList < RawQuaternionKeyframe >
```


### var name
```cj
public var name: String
```


