# 类
## class AnimationUtils
```cj
public class AnimationUtils
```
动画工具类，提供静态方法包装

### func flattenJSON\(Array<HashMap<String,Any>>,ArrayList<Float64>,ArrayList<Float64>,String\)
```cj
public static func flattenJSON(jsonKeys: Array < HashMap < String, Any >>, times: ArrayList < Float64 >, values: ArrayList < Float64 >, valuePropertyName: String): Unit
```
展平 JSON 关键帧数据

参数: 

|名称|类型|描述|
|---|---|---|
|jsonKeys|Array<HashMap<String,Any>>|JSON 关键帧数组times 填充关键帧时间的数组values 填充关键帧值的数组valuePropertyName 要使用的属性名|
|times|ArrayList<Float64>||
|values|ArrayList<Float64>||
|valuePropertyName|String||

### func getKeyframeOrder\(Array<Float64>\)
```cj
public static func getKeyframeOrder(times: Array < Float64 >): Array < Int64 >
```
返回关键帧时间的排序顺序数组

参数: 

|名称|类型|描述|
|---|---|---|
|times|Array<Float64>|关键帧时间数组|

返回: 

- 排序后的索引数组，按时间升序排列

### func makeClipAdditive\(AnimationClip,Int64,AnimationClip,Float64\)
```cj
public static func makeClipAdditive(targetClip: AnimationClip, referenceFrame!: Int64 = 0, referenceClip!: AnimationClip = targetClip, fps!: Float64 = 30.0): AnimationClip
```
将动画剪辑转换为加法混合格式

参数: 

|名称|类型|描述|
|---|---|---|
|targetClip|AnimationClip|目标剪辑（将被修改为加法格式）referenceFrame 参考帧，默认 0referenceClip 参考剪辑，默认为 targetClipfps 帧率，默认 30|
|referenceFrame|Int64||
|referenceClip|AnimationClip||
|fps|Float64||

返回: 

- 修改后的目标剪辑（现在是加法格式）

### func sortedArray\(Array<Float64>,Int64,Array<Int64>\)
```cj
public static func sortedArray(values: Array < Float64 >, stride: Int64, order: Array < Int64 >): Array < Float64 >
```
根据排序顺序重排数组

参数: 

|名称|类型|描述|
|---|---|---|
|values|Array<Float64>|原始值数组stride 步长（每个关键帧的值数量）order 排序顺序（由 getKeyframeOrder 返回）|
|stride|Int64||
|order|Array<Int64>||

返回: 

- 排序后的数组

### func subclip\(AnimationClip,String,Int64,Int64,Float64\)
```cj
public static func subclip(sourceClip: AnimationClip, name: String, startFrame: Int64, endFrame: Int64, fps!: Float64 = 30.0): AnimationClip
```
创建子剪辑 — 从原始剪辑中提取指定帧范围的新剪辑

参数: 

|名称|类型|描述|
|---|---|---|
|sourceClip|AnimationClip|源剪辑name 新剪辑名称startFrame 起始帧endFrame 结束帧fps 帧率，默认 30|
|name|String||
|startFrame|Int64||
|endFrame|Int64||
|fps|Float64||

返回: 

- 新的子剪辑

