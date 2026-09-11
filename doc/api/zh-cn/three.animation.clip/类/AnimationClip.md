# 类
## class AnimationClip
```cj
public class AnimationClip <: IAnimationClip & ILoadResult
```
动画剪辑，包含一组关键帧轨道

### func CreateClipsFromMorphTargetSequences\(Array<Any>,Float64,Bool\)
```cj
public static func CreateClipsFromMorphTargetSequences(morphTargets: Array < Any >, fps: Float64, noLoop: Bool): Array < AnimationClip >
```
从几何体的变形目标序列创建多个动画剪辑

参数: 

|名称|类型|描述|
|---|---|---|
|morphTargets|Array<Any>|变形目标序列|
|fps|Float64|每秒帧数|
|noLoop|Bool|是否不循环|

返回: 

- 新的动画剪辑数组

### func CreateFromMorphTargetSequence\(String,Array<Any>,Float64,Bool\)
```cj
public static func CreateFromMorphTargetSequence(name: String, morphTargetSequence: Array < Any >, fps: Float64, noLoop: Bool): AnimationClip
```
从几何体的变形目标数组创建新的动画剪辑

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|动画剪辑名称|
|morphTargetSequence|Array<Any>|变形目标序列|
|fps|Float64|每秒帧数|
|noLoop|Bool|是否不循环|

返回: 

- 新的动画剪辑

### func clone\(\)
```cj
public func clone(): AnimationClip
```
返回具有当前实例复制值的新动画剪辑

返回: 

- 当前实例的克隆

### func findByName\(Any,String\)
```cj
public static func findByName(objectOrClipArray: Any, name: String): Option < AnimationClip >
```
按名称查找动画剪辑

参数: 

|名称|类型|描述|
|---|---|---|
|objectOrClipArray|Any|剪辑数组或包含动画的对象|
|name|String|要查找的名称|

返回: 

- 找到的动画剪辑，未找到返回 None

### func init\(String,Float64,Array<IKeyframeTrack>,Int64\)
```cj
public init(name!: String = "", duration!: Float64 = - 1.0, tracks!: Array < IKeyframeTrack >=[], blendMode!: Int64 = NormalAnimationBlendMode)
```
构造一个新的动画剪辑

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|剪辑名称，默认 ''|
|duration|Float64|剪辑持续时间（秒），默认 -1（从关键帧计算）|
|tracks|Array<IKeyframeTrack>|关键帧轨道数组（通过 IKeyframeTrack 接口引用，避免依赖 blend 包）|
|blendMode|Int64|混合模式，默认 NormalAnimationBlendMode|

### func optimize\(\)
```cj
public func optimize(): AnimationClip
```
通过移除等效的连续关键帧来优化每个轨道

返回: 

- 返回当前剪辑以支持链式调用

### func parseUserData\(String\)
```cj
public static func parseUserData(jsonStr: String): HashMap < String, Any >
```
使用 cjfast_json 解析 userData JSON 字符串为 HashMap<String, Any>

参数: 

|名称|类型|描述|
|---|---|---|
|jsonStr|String|JSON 字符串|

返回: 

- 解析后的 HashMap<String, Any>

### func parse\(HashMap<String,Any>\)
```cj
public static func parse(json: HashMap < String, Any >): AnimationClip
```
从 JSON 创建动画剪辑的工厂方法

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|序列化的动画剪辑|

返回: 

- 新的动画剪辑

### func resetDuration\(\)
```cj
public func resetDuration(): AnimationClip
```
将剪辑的持续时间设置为最长的关键帧轨道的持续时间

返回: 

- 返回当前剪辑以支持链式调用

### func stringifyUserData\(HashMap<String,Any>\)
```cj
public static func stringifyUserData(userData: HashMap < String, Any >): String
```
使用 cjfast_json 序列化 HashMap<String, Any> 为 JSON 字符串

参数: 

|名称|类型|描述|
|---|---|---|
|userData|HashMap<String,Any>|用户数据 HashMap|

返回: 

- JSON 字符串

### func trim\(\)
```cj
public func trim(): AnimationClip
```
将所有轨道裁剪到剪辑的持续时间

返回: 

- 返回当前剪辑以支持链式调用

### func validate\(\)
```cj
public func validate(): Bool
```
对每个轨道执行最小验证

返回: 

- 剪辑的关键帧是否有效

### prop blendMode: Int64
```cj
public mut prop blendMode: Int64
```
混合模式，定义两个或多个动画同时播放时的混合方式

### prop duration: Float64
```cj
public mut prop duration: Float64
```
剪辑持续时间（秒）

### prop name: String
```cj
public mut prop name: String
```
剪辑名称

### prop tracks: Array < IKeyframeTrack >
```cj
public mut prop tracks: Array < IKeyframeTrack >
```
关键帧轨道数组

### prop userData: HashMap < String, Any >
```cj
public mut prop userData: HashMap < String, Any >
```
可用于存储剪辑自定义数据的对象，不应保存函数引用（克隆时不会复制函数）

### prop uuid: String
```cj
public mut prop uuid: String
```
剪辑的 UUID

### var skeletalData
```cj
public var skeletalData: Option < SkeletalAnimationData >= None
```
骨骼动画压缩数据（可选）

