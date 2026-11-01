# Class
## class AudioTransformSlot
```cj
public class AudioTransformSlot
```
An audio transform slot

### func invalidate\(\)
```cj
public func invalidate(): Unit
```
Invalidates the slot (target source released): zeroes the source id and advances the version

### var gain
```cj
public var gain: Float32 = 1.0f32
```
Master gain (listener slots only, used to submit AL_GAIN)

### var isListener
```cj
public var isListener: Bool = false
```
Whether this is a listener slot (alListenerfv) or a source slot (alSourcefv)

### var ox
```cj
public var ox: Float32 = 0.0f32
```
Orientation X (listener forward axis / source direction)

### var oy
```cj
public var oy: Float32 = 0.0f32
```
Orientation Y (listener forward axis / source direction)

### var oz
```cj
public var oz: Float32 = 0.0f32
```
Orientation Z (listener forward axis / source direction)

### var px
```cj
public var px: Float32 = 0.0f32
```
Position X (OpenAL right-handed system)

### var py
```cj
public var py: Float32 = 0.0f32
```
Position Y (OpenAL right-handed system)

### var pz
```cj
public var pz: Float32 = 0.0f32
```
Position Z (OpenAL right-handed system)

### var sourceId
```cj
public var sourceId: UInt32 = 0u32
```
The target OpenAL source id

### var ux
```cj
public var ux: Float32 = 0.0f32
```
Up axis X (listener) / velocity X (source)

### var uy
```cj
public var uy: Float32 = 0.0f32
```
Up axis Y (listener) / velocity Y (source)

### var uz
```cj
public var uz: Float32 = 0.0f32
```
Up axis Z (listener) / velocity Z (source)

