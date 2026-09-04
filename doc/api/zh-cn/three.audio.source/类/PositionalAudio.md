# 类
## class PositionalAudio
```cj
public open class PositionalAudio <: Audio
```
3D 位置音频，继承 Audio

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Three.cj 使用左手坐标系，OpenAL 使用右手坐标系，同步位置时需要翻转
Z 轴（LH → RH: z' = -z）。</p>

### func getDistanceModel\(\)
```cj
public func getDistanceModel(): Int64
```
获取距离模型

返回: 

- 当前距离模型索引

### func getMaxDistance\(\)
```cj
public func getMaxDistance(): Float64
```
获取最大距离

返回: 

- 当前最大衰减距离

### func getRefDistance\(\)
```cj
public func getRefDistance(): Float64
```
获取参考距离

返回: 

- 当前参考距离

### func getRolloffFactor\(\)
```cj
public func getRolloffFactor(): Float64
```
获取滚降因子

返回: 

- 当前滚降因子

### func getVelocity\(\)
```cj
public func getVelocity(): Vector3
```
获取速度

返回: 

- 当前速度向量

### func init\(AudioListener\)
```cj
public init(listener!: AudioListener)
```
创建 3D 位置音频源

参数: 

|名称|类型|描述|
|---|---|---|
|listener|AudioListener|关联的音频监听器|

### func setDirectionalCone\(Float64,Float64,Float64\)
```cj
public func setDirectionalCone(coneInnerAngle!: Float64, coneOuterAngle!: Float64, coneOuterGain!: Float64): PositionalAudio
```
设置方向性锥体

参数: 

|名称|类型|描述|
|---|---|---|
|coneInnerAngle|Float64|内角（度）coneOuterAngle 外角（度）coneOuterGain 外角增益（0.0 ~ 1.0）|
|coneOuterAngle|Float64||
|coneOuterGain|Float64||

返回: 

- this（便于链式调用）

### func setDistanceModel\(Int64\)
```cj
public func setDistanceModel(model: Int64): PositionalAudio
```
设置距离模型

参数: 

|名称|类型|描述|
|---|---|---|
|model|Int64|距离模型索引：0 = none, 1 = inverse, 2 = inverseClamped, 3 = linear,4 = linearClamped, 5 = exponential, 6 = exponentialClamped|

返回: 

- this（便于链式调用）

### func setMaxDistance\(Float64\)
```cj
public func setMaxDistance(value: Float64): PositionalAudio
```
设置最大距离

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|最大衰减距离|

返回: 

- this（便于链式调用）

### func setRefDistance\(Float64\)
```cj
public func setRefDistance(value: Float64): PositionalAudio
```
设置参考距离

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|参考距离（音量开始衰减的距离）|

返回: 

- this（便于链式调用）

### func setRolloffFactor\(Float64\)
```cj
public func setRolloffFactor(value: Float64): PositionalAudio
```
设置滚降因子

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|滚降因子（衰减速度）|

返回: 

- this（便于链式调用）

### func setVelocity\(Vector3\)
```cj
public func setVelocity(v: Vector3): PositionalAudio
```
设置速度（m/s，世界坐标），启用多普勒效应

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>还需设置全局多普勒因子（AudioContext.setDopplerFactor）才能听到效果；
速度在每次 updateMatrixWorld 时同步到 AL_VELOCITY。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|速度向量（世界坐标，左手系）|

返回: 

- this（便于链式调用）

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
重写 updateMatrixWorld，将世界位置和朝向同步到 OpenAL 源

参数: 

|名称|类型|描述|
|---|---|---|
|force|Bool|是否强制更新|

### var coneInnerAngle
```cj
public var coneInnerAngle: Float64
```
方向性锥体内角（度），默认 360（全方向）

### var coneOuterAngle
```cj
public var coneOuterAngle: Float64
```
方向性锥体外角（度），默认 360

### var coneOuterGain
```cj
public var coneOuterGain: Float64
```
方向性锥体外增益，默认 0

### var distanceModel
```cj
public var distanceModel: Int64
```
距离模型：0=None, 1=inverse, 2=inverseClamped, 3=linear, 4=linearClamped, 5=exponential, 6=exponentialClamped

### var maxDistance
```cj
public var maxDistance: Float64
```
最大衰减距离（仅 linear 模型有效），默认 10000.0

### var refDistance
```cj
public var refDistance: Float64
```
参考距离（音量开始衰减的距离），默认 1.0

### var rolloffFactor
```cj
public var rolloffFactor: Float64
```
滚降因子（衰减速度），默认 1.0

### var velocity
```cj
public var velocity: Vector3
```
速度（m/s，世界坐标，用于多普勒效应；默认 0 = 无多普勒）

