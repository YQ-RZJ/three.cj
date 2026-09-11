# Class
## class TrackBuilder
```cj
public class TrackBuilder
```
Track builder

### func invokeFloat3\(RawFloat3Track\)
```cj
public func invokeFloat3(input: RawFloat3Track): Option < SkeletalTrackData >
```
Builds a 3-component vector track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawFloat3Track|The offline 3-component vector track data|

Return: 

- Some(SkeletalTrackData) or None

### func invokeQuaternion\(RawQuaternionTrack\)
```cj
public func invokeQuaternion(input: RawQuaternionTrack): Option < SkeletalTrackData >
```
Builds a quaternion track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawQuaternionTrack|The offline quaternion track data|

Return: 

- Some(SkeletalTrackData) or None

### func invoke\(RawFloatTrack\)
```cj
public func invoke(input: RawFloatTrack): Option < SkeletalTrackData >
```
Builds a float track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|RawFloatTrack|The offline float track data|

Return: 

- Some(SkeletalTrackData) or None

