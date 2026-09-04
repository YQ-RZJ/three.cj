# 类
## class AudioRecorder
```cj
public class AudioRecorder
```
麦克风音频捕获器，封装 ALC capture 扩展

### func close\(\)
```cj
public func close(): Unit
```
关闭捕获设备并释放资源

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 alcCaptureCloseDevice(device)。</p>

### func getAvailableSamples\(\)
```cj
public func getAvailableSamples(): Int32
```
获取当前可读取的采样帧数

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 alcGetIntegerv(device, ALC_CAPTURE_SAMPLES, 1, &n)。</p>

返回: 

- 可用帧数（0 = 暂无数据）

### func getCaptureDevice\(\)
```cj
public func getCaptureDevice(): CPointer < Unit >
```
获取捕获设备句柄

返回: 

- ALC 捕获设备句柄

### func init\(\)
```cj
public init()
```


### func open\(UInt32,UInt32,Int32\)
```cj
public func open(frequency: UInt32, channels: UInt32, bufferSize!: Int32 = 8192): Bool
```
打开默认捕获设备（麦克风）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 alcCaptureOpenDevice(NULL, frequency, format, buffersize)，在音频线程内执行。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|frequency|UInt32|采样率（Hz，如 44100 / 48000）channels 声道数（1 = 单声道 / 2 = 立体声）bufferSize 内部缓冲大小（帧数，建议 4096 以上）|
|channels|UInt32||
|bufferSize|Int32||

返回: 

- 是否成功打开

### func readSamples\(CPointer<UInt8>,Int32\)
```cj
public func readSamples(buffer: CPointer < UInt8 >, samples: Int32): Int32
```
读取捕获的 PCM 数据

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 alcCaptureSamples(device, buffer, samples)；数据为 16-bit 交错 PCM。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|buffer|CPointer<UInt8>|目标缓冲（调用方分配，大小须 ≥ samples × 声道数 × 2 字节）samples 要读取的采样帧数（≤ getAvailableSamples()）|
|samples|Int32||

返回: 

- 实际读取的字节数（samples × 声道数 × 2）

### func start\(\)
```cj
public func start(): Bool
```
开始捕获

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 alcCaptureStart(device)。</p>

返回: 

- 是否已开始（设备已打开）

### func stop\(\)
```cj
public func stop(): Unit
```
停止捕获（保留已捕获数据，可继续读取）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 alcCaptureStop(device)。</p>

### prop channels: UInt32
```cj
public prop channels: UInt32
```
声道数

### prop format: UInt32
```cj
public prop format: UInt32
```
采样格式（AL_FORMAT_MONO16 / AL_FORMAT_STEREO16）

### prop frequency: UInt32
```cj
public prop frequency: UInt32
```
采样率（Hz）

### prop opened: Bool
```cj
public prop opened: Bool
```
是否已打开捕获设备

### prop recording: Bool
```cj
public prop recording: Bool
```
是否捕获中

