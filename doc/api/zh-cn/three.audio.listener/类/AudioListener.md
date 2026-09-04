# 类
## class AudioListener
```cj
public open class AudioListener <: Object3D
```
音频监听器，代表场景中的"耳朵"

### func getMasterVolume\(\)
```cj
public func getMasterVolume(): Float64
```
获取主音量

返回: 

- 当前主音量（0.0 ~ 1.0+）

### func init\(AudioContext\)
```cj
public init(context!: AudioContext = AudioContext.context)
```
创建音频监听器

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）|

### func setMasterVolume\(Float64\)
```cj
public func setMasterVolume(value: Float64): Unit
```
设置主音量

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>上下文已初始化时同步通过 execAudio 下发 AL_GAIN 到 OpenAL 监听器。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|目标音量（0.0 = 静音，1.0 = 原始音量）|

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
重写 updateMatrixWorld，将世界变换同步到 OpenAL 监听器

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>从 matrixWorld 分解位置和朝向，转换到 OpenAL 右手坐标系后设置到监听器。
左手系 → 右手系转换：
- 位置: (x, y, z) → (x, y, -z)
- 前方向(at): (x, y, z) → (x, y, -z)
- 上方向(up): (upX, upY, upZ) → (upX, upY, -upZ)</p>

参数: 

|名称|类型|描述|
|---|---|---|
|force|Bool|是否强制更新世界矩阵|

### var context
```cj
public var context: AudioContext
```
音频上下文引用

### var gain
```cj
public var gain: Float64
```
主音量（0.0 ~ 1.0+）

### var timeDelta
```cj
public var timeDelta: Float64
```
时间增量（用于平滑插值；当前实现为简化版，不使用 linearRampToValueAtTime）

