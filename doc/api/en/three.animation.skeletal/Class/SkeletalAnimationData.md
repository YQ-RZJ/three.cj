# Class
## class SkeletalAnimationData
```cj
public class SkeletalAnimationData
```
Runtime skeletal animation data

### func init\(\)
```cj
public init()
```
Default constructor (empty data)

### func init\(Float32,Int,Array<JointTrack>\)
```cj
public init(duration: Float32, numTracks: Int, tracks: Array < JointTrack >)
```
Constructs from build data (used by AnimationBuilder)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|duration|Float32||
|numTracks|Int||
|tracks|Array<JointTrack>||

### func numSoaJoints\(\)
```cj
public func numSoaJoints(): Int
```
Returns the number of SoA elements (one SoaTransform per 4 joints)

### func track\(Int\)
```cj
public func track(track: Int): JointTrack
```
Returns the specified track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|track|Int||

### var duration
```cj
public var duration: Float32
```
Animation duration in seconds

### var numTracks
```cj
public var numTracks: Int
```
Number of tracks (equal to the number of skeleton joints)

### var tracks
```cj
public var tracks: Array < JointTrack >
```
Per-joint track data (length = numTracks)

