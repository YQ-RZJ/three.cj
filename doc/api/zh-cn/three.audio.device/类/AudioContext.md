# 类
## class AudioContext
```cj
public class AudioContext
```
音频上下文单例，管理 OpenAL 设备和上下文 + 专用音频线程

### func execAudio\(\(\)\->Unit\)
```cj
public func execAudio(cmd:() -> Unit): Unit
```
公开线程序列化入口，将 OpenAL API 调用提交到音频线程同步执行

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>外部模块（如 AudioLoader/StreamingAudio/EffectComposer）的 OpenAL 调用必须经
此方法排队到音频线程，避免数据竞争；闭包按提交顺序在音频线程执行，
内部若再调用其它走 _execAudio 的方法（如 initialize）会自我等待死锁。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|cmd|()->Unit|待执行的闭包（仅包含原始 OpenAL 调用）|

### func getError\(\)
```cj
public func getError(): UInt32
```
获取当前上下文的 OpenAL 错误码

返回: 

- AL 错误码（AL_NO_ERROR = 0 表示无错误）

### func getHrtfCount\(\)
```cj
public func getHrtfCount(): Int32
```
获取可用 HRTF 数量

返回: 

- HRTF 数量（0 = 设备不支持 HRTF）

### func getHrtfList\(\)
```cj
public func getHrtfList(): ArrayList < String >
```
枚举全部可用 HRTF 名称列表

返回: 

- HRTF 名称列表（可能为空 = 设备不支持）

### func getHrtfName\(Int32\)
```cj
public func getHrtfName(index: Int32): String
```
获取指定索引的 HRTF 名称

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int32|HRTF 索引（0 ~ getHrtfCount()-1）|

返回: 

- HRTF 名称字符串；索引无效返回空串

### func getHrtfStatus\(\)
```cj
public func getHrtfStatus(): Int32
```
查询当前 HRTF 状态

返回: 

- ALC_HRTF_DISABLED_SOFT(0) / ALC_HRTF_ENABLED_SOFT(1) /ALC_HRTF_DENIED_SOFT(2) / ALC_HRTF_REQUIRED_SOFT(3) /ALC_HRTF_HEADPHONES_DETECTED_SOFT(4) / ALC_HRTF_UNSUPPORTED_FORMAT_SOFT(5)

### func initialize\(\)
```cj
public func initialize(): Bool
```
初始化音频上下文（打开设备 + 创建上下文 + 在音频线程激活上下文）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>alcMakeContextCurrent 必须在后续发出 OpenAL 调用的同一线程（音频线程）
上调用，故整个初始化流程在 _execAudio 闭包内完成。</p>

返回: 

- 是否初始化成功

### func selectHrtf\(Int32\)
```cj
public func selectHrtf(id: Int32): Unit
```
选择指定 HRTF

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>需先调用 setHrtfEnabled(true) 后生效；对应 ALC_SOFT_HRTF 的
ALC_HRTF_ID_SOFT 设置。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int32|HRTF ID（0 ~ getHrtfCount()-1），-1 = 恢复自动选择|

### func setDopplerFactor\(Float32\)
```cj
public func setDopplerFactor(factor: Float32): Unit
```
设置全局多普勒因子

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>OpenAL 默认值为 1.0；配合 PositionalAudio.setVelocity 使用。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|factor|Float32|多普勒因子（0.0 = 关闭多普勒，1.0 = 物理正确，越大越夸张）|

### func setDopplerVelocity\(Float32\)
```cj
public func setDopplerVelocity(velocity: Float32): Unit
```
设置多普勒速度因子

参数: 

|名称|类型|描述|
|---|---|---|
|velocity|Float32|多普勒速度因子|

### func setHrtfEnabled\(Bool\)
```cj
public func setHrtfEnabled(enabled: Bool): Unit
```
启用/禁用 HRTF（耳机空间化渲染）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 ALC_SOFT_HRTF：alcGetIntegerv(device, ALC_HRTF_SOFT, 1, &hrtf)，
其中 hrtf = ALC_HRTF_ENABLED_SOFT / ALC_HRTF_DISABLED_SOFT。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|enabled|Bool|true = 启用，false = 禁用|

### func setSpeedOfSound\(Float32\)
```cj
public func setSpeedOfSound(speed: Float32): Unit
```
设置参考声速

参数: 

|名称|类型|描述|
|---|---|---|
|speed|Float32|声速（米/秒，默认 343.3），多普勒计算的参考值；越大 → 多普勒效应越弱|

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
关闭音频上下文并释放资源

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>清理在音频线程执行，确保 OpenAL 调用在 context 所属线程上发出。</p>

### prop alcContext: CPointer < Unit >
```cj
public prop alcContext: CPointer < Unit >
```
获取 OpenAL 上下文句柄

### prop context: AudioContext
```cj
public static prop context: AudioContext
```
获取单例实例（懒初始化）

### prop device: CPointer < Unit >
```cj
public prop device: CPointer < Unit >
```
获取 OpenAL 设备句柄

### prop initialized: Bool
```cj
public prop initialized: Bool
```
是否已初始化

