# 类
## class RawAnimationUtils
```cj
public class RawAnimationUtils
```
离线动画工具函数集

### func concatenate\(RawAnimation,RawAnimation\)
```cj
public static func concatenate(first: RawAnimation, second: RawAnimation): Option < RawAnimation >
```
合并两个动画（串联）

参数: 

|名称|类型|描述|
|---|---|---|
|first|RawAnimation|第一段动画|
|second|RawAnimation|第二段动画|

返回: 

- 合并后的动画（first 紧接 second）

### func makeAdditiveDelta\(RawAnimation,RawAnimation\)
```cj
public static func makeAdditiveDelta(base: RawAnimation, target: RawAnimation): Option < RawAnimation >
```
创建叠加差值动画

参数: 

|名称|类型|描述|
|---|---|---|
|base|RawAnimation|基础动画|
|target|RawAnimation|目标动画|

返回: 

- 叠加动画（delta = target 相对 base 的差量）

### func resample\(RawAnimation,Float32\)
```cj
public static func resample(source: RawAnimation, newFps: Float32): RawAnimation
```
重采样动画到新的帧率

参数: 

|名称|类型|描述|
|---|---|---|
|source|RawAnimation|源动画|
|newFps|Float32|新帧率（每秒帧数）|

返回: 

- 重采样后的动画（每个轨道每帧一个关键帧）

### func retarget\(RawAnimation,Array<String>,Array<String>\)
```cj
public static func retarget(source: RawAnimation, sourceJointNames: Array < String >, targetJointNames: Array < String >): RawAnimation
```
重定向动画到不同的骨骼结构

参数: 

|名称|类型|描述|
|---|---|---|
|source|RawAnimation|源动画|
|sourceJointNames|Array<String>|源骨骼关节名称列表|
|targetJointNames|Array<String>|目标骨骼关节名称列表|

返回: 

- 重定向后的动画（只保留目标骨骼中存在的轨道）

