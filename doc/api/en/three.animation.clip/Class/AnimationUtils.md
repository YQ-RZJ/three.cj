# Class
## class AnimationUtils
```cj
public class AnimationUtils
```
Animation utility class, providing static method wrappers

### func flattenJSON\(Array<HashMap<String,Any>>,ArrayList<Float64>,ArrayList<Float64>,String\)
```cj
public static func flattenJSON(jsonKeys: Array < HashMap < String, Any >>, times: ArrayList < Float64 >, values: ArrayList < Float64 >, valuePropertyName: String): Unit
```
Flattens JSON keyframe data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonKeys|Array<HashMap<String,Any>>|JSON keyframe arraytimes Array to fill with keyframe timesvalues Array to fill with keyframe valuesvaluePropertyName Property name to use|
|times|ArrayList<Float64>||
|values|ArrayList<Float64>||
|valuePropertyName|String||

### func getKeyframeOrder\(Array<Float64>\)
```cj
public static func getKeyframeOrder(times: Array < Float64 >): Array < Int64 >
```
Returns the sort order array of keyframe times

Parameter: 

|Name|Type|Describe|
|---|---|---|
|times|Array<Float64>|Keyframe time array|

Return: 

- Sorted index array in ascending time order

### func makeClipAdditive\(AnimationClip,Int64,AnimationClip,Float64\)
```cj
public static func makeClipAdditive(targetClip: AnimationClip, referenceFrame!: Int64 = 0, referenceClip!: AnimationClip = targetClip, fps!: Float64 = 30.0): AnimationClip
```
Converts an animation clip to additive blending format

Parameter: 

|Name|Type|Describe|
|---|---|---|
|targetClip|AnimationClip|The target clip (will be modified to additive format)referenceFrame Reference frame, defaults to 0referenceClip Reference clip, defaults to targetClipfps Frame rate, defaults to 30|
|referenceFrame|Int64||
|referenceClip|AnimationClip||
|fps|Float64||

Return: 

- The modified target clip (now in additive format)

### func sortedArray\(Array<Float64>,Int64,Array<Int64>\)
```cj
public static func sortedArray(values: Array < Float64 >, stride: Int64, order: Array < Int64 >): Array < Float64 >
```
Reorders the array according to the sort order

Parameter: 

|Name|Type|Describe|
|---|---|---|
|values|Array<Float64>|Original value arraystride Stride (number of values per keyframe)order Sort order (returned by getKeyframeOrder)|
|stride|Int64||
|order|Array<Int64>||

Return: 

- Sorted array

### func subclip\(AnimationClip,String,Int64,Int64,Float64\)
```cj
public static func subclip(sourceClip: AnimationClip, name: String, startFrame: Int64, endFrame: Int64, fps!: Float64 = 30.0): AnimationClip
```
Creates a subclip — a new clip extracted from the source clip over the given frame range

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sourceClip|AnimationClip|The source clipname The new clip namestartFrame Start frameendFrame End framefps Frame rate, defaults to 30|
|name|String||
|startFrame|Int64||
|endFrame|Int64||
|fps|Float64||

Return: 

- The new subclip

