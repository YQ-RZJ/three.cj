# Class
## class AnimationClip
```cj
public class AnimationClip <: IAnimationClip & ILoadResult
```
An animation clip, containing a group of keyframe tracks

### func CreateClipsFromMorphTargetSequences\(Array<Any>,Float64,Bool\)
```cj
public static func CreateClipsFromMorphTargetSequences(morphTargets: Array < Any >, fps: Float64, noLoop: Bool): Array < AnimationClip >
```
Creates multiple animation clips from a geometry's morph target sequence

Parameter: 

|Name|Type|Describe|
|---|---|---|
|morphTargets|Array<Any>|Morph target sequence|
|fps|Float64|Frames per second|
|noLoop|Bool|Whether not to loop|

Return: 

- Array of new animation clips

### func CreateFromMorphTargetSequence\(String,Array<Any>,Float64,Bool\)
```cj
public static func CreateFromMorphTargetSequence(name: String, morphTargetSequence: Array < Any >, fps: Float64, noLoop: Bool): AnimationClip
```
Creates a new animation clip from an array of morph targets of a geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Animation clip name|
|morphTargetSequence|Array<Any>|Morph target sequence|
|fps|Float64|Frames per second|
|noLoop|Bool|Whether not to loop|

Return: 

- The new animation clip

### func clone\(\)
```cj
public func clone(): AnimationClip
```
Returns a new animation clip with copied values of the current instance

Return: 

- A clone of the current instance

### func findByName\(Any,String\)
```cj
public static func findByName(objectOrClipArray: Any, name: String): Option < AnimationClip >
```
Finds an animation clip by name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|objectOrClipArray|Any|Array of clips or an object containing animations|
|name|String|The name to search for|

Return: 

- The found animation clip, or None if not found

### func init\(String,Float64,Array<IKeyframeTrack>,Int64\)
```cj
public init(name!: String = "", duration!: Float64 = - 1.0, tracks!: Array < IKeyframeTrack >=[], blendMode!: Int64 = NormalAnimationBlendMode)
```
Constructs a new animation clip

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Clip name, defaults to ''|
|duration|Float64|Clip duration in seconds, defaults to -1 (calculated from keyframes)|
|tracks|Array<IKeyframeTrack>|Array of keyframe tracks (referenced via the IKeyframeTrack interface to avoid depending on the blend package)|
|blendMode|Int64|Blend mode, defaults to NormalAnimationBlendMode|

### func optimize\(\)
```cj
public func optimize(): AnimationClip
```
Optimizes each track by removing equivalent successive keyframes

Return: 

- Returns this clip for chaining

### func parseUserData\(String\)
```cj
public static func parseUserData(jsonStr: String): HashMap < String, Any >
```
Parses a userData JSON string into a HashMap<String, Any> using cjfast_json

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonStr|String|The JSON string|

Return: 

- The parsed HashMap<String, Any>

### func parse\(HashMap<String,Any>\)
```cj
public static func parse(json: HashMap < String, Any >): AnimationClip
```
Factory method that creates an animation clip from JSON

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|Serialized animation clip|

Return: 

- The new animation clip

### func resetDuration\(\)
```cj
public func resetDuration(): AnimationClip
```
Sets the duration of the clip to the duration of its longest keyframe track

Return: 

- Returns this clip for chaining

### func stringifyUserData\(HashMap<String,Any>\)
```cj
public static func stringifyUserData(userData: HashMap < String, Any >): String
```
Serializes a HashMap<String, Any> into a JSON string using cjfast_json

Parameter: 

|Name|Type|Describe|
|---|---|---|
|userData|HashMap<String,Any>|The user data HashMap|

Return: 

- The JSON string

### func trim\(\)
```cj
public func trim(): AnimationClip
```
Trims all tracks to the clip duration

Return: 

- Returns this clip for chaining

### func validate\(\)
```cj
public func validate(): Bool
```
Performs minimal validation on each track

Return: 

- Whether the clip's keyframes are valid

### prop blendMode: Int64
```cj
public mut prop blendMode: Int64
```
The blend mode, defining how two or more animations are blended when played simultaneously

### prop duration: Float64
```cj
public mut prop duration: Float64
```
The clip duration in seconds

### prop name: String
```cj
public mut prop name: String
```
The clip name

### prop tracks: Array < IKeyframeTrack >
```cj
public mut prop tracks: Array < IKeyframeTrack >
```
The array of keyframe tracks

### prop userData: HashMap < String, Any >
```cj
public mut prop userData: HashMap < String, Any >
```
An object that can be used to store custom data for the clip; function references should not be stored since they are not copied on clone

### prop uuid: String
```cj
public mut prop uuid: String
```
The UUID of the clip

### var skeletalData
```cj
public var skeletalData: Option < SkeletalAnimationData >= None
```
Compressed skeletal animation data (optional)

