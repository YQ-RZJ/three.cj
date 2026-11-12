# 类
## class AudioTransformSlot
```cj
public class AudioTransformSlot
```
音频变换槽

### var gain
```cj
public var gain: Float32 = 1.0f32
```
主音量（仅监听器槽使用，用于下发 AL_GAIN）

### var isListener
```cj
public var isListener: Bool = false
```
是否为监听器槽（true 用 alListenerfv，false 用 alSourcefv）

### var ox
```cj
public var ox: Float32 = 0.0f32
```
朝向 X（监听器的前方向 / 音源的方向）

### var oy
```cj
public var oy: Float32 = 0.0f32
```
朝向 Y（监听器的前方向 / 音源的方向）

### var oz
```cj
public var oz: Float32 = 0.0f32
```
朝向 Z（监听器的前方向 / 音源的方向）

### var px
```cj
public var px: Float32 = 0.0f32
```
位置 X（OpenAL 右手系）

### var py
```cj
public var py: Float32 = 0.0f32
```
位置 Y（OpenAL 右手系）

### var pz
```cj
public var pz: Float32 = 0.0f32
```
位置 Z（OpenAL 右手系）

### var sourceId
```cj
public var sourceId: UInt32 = 0u32
```
目标 OpenAL 源 ID

### var ux
```cj
public var ux: Float32 = 0.0f32
```
上方向 X（监听器）/ 速度 X（音源）

### var uy
```cj
public var uy: Float32 = 0.0f32
```
上方向 Y（监听器）/ 速度 Y（音源）

### var uz
```cj
public var uz: Float32 = 0.0f32
```
上方向 Z（监听器）/ 速度 Z（音源）

