# Class
## class PositionalAudio
```cj
public open class PositionalAudio <: Audio
```
3D positional audio extending Audio

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Three.cj uses a left-handed coordinate system while OpenAL is right-handed;
flip the Z axis when syncing positions (LH → RH: z' = -z).</p>

### func getDistanceModel\(\)
```cj
public func getDistanceModel(): Int64
```
Returns the distance model

Return: 

- The current distance model index

### func getMaxDistance\(\)
```cj
public func getMaxDistance(): Float64
```
Returns the maximum distance

Return: 

- The current maximum attenuation distance

### func getRefDistance\(\)
```cj
public func getRefDistance(): Float64
```
Returns the reference distance

Return: 

- The current reference distance

### func getRolloffFactor\(\)
```cj
public func getRolloffFactor(): Float64
```
Returns the rolloff factor

Return: 

- The current rolloff factor

### func getVelocity\(\)
```cj
public func getVelocity(): Vector3
```
Returns the velocity

Return: 

- The current velocity vector

### func init\(AudioListener\)
```cj
public init(listener!: AudioListener)
```
Creates a 3D positional audio source

Parameter: 

|Name|Type|Describe|
|---|---|---|
|listener|AudioListener|The associated audio listener|

### func setDirectionalCone\(Float64,Float64,Float64\)
```cj
public func setDirectionalCone(coneInnerAngle!: Float64, coneOuterAngle!: Float64, coneOuterGain!: Float64): PositionalAudio
```
Sets the directional cone

Parameter: 

|Name|Type|Describe|
|---|---|---|
|coneInnerAngle|Float64|Inner angle (degrees)coneOuterAngle Outer angle (degrees)coneOuterGain Outer angle gain (0.0 ~ 1.0)|
|coneOuterAngle|Float64||
|coneOuterGain|Float64||

Return: 

- this (for chaining)

### func setDistanceModel\(Int64\)
```cj
public func setDistanceModel(model: Int64): PositionalAudio
```
Sets the distance model

Parameter: 

|Name|Type|Describe|
|---|---|---|
|model|Int64|Distance model index:0 = none, 1 = inverse, 2 = inverseClamped, 3 = linear,4 = linearClamped, 5 = exponential, 6 = exponentialClamped|

Return: 

- this (for chaining)

### func setMaxDistance\(Float64\)
```cj
public func setMaxDistance(value: Float64): PositionalAudio
```
Sets the maximum distance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Maximum attenuation distance|

Return: 

- this (for chaining)

### func setRefDistance\(Float64\)
```cj
public func setRefDistance(value: Float64): PositionalAudio
```
Sets the reference distance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Reference distance (distance where attenuation begins)|

Return: 

- this (for chaining)

### func setRolloffFactor\(Float64\)
```cj
public func setRolloffFactor(value: Float64): PositionalAudio
```
Sets the rolloff factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Rolloff factor (attenuation rate)|

Return: 

- this (for chaining)

### func setVelocity\(Vector3\)
```cj
public func setVelocity(v: Vector3): PositionalAudio
```
Sets the velocity (m/s, world space) to enable the Doppler effect

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>You also need to set the global Doppler factor
(AudioContext.setDopplerFactor) to hear the effect; the velocity is
synced to AL_VELOCITY on every updateMatrixWorld.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Velocity vector (world space, left-handed)|

Return: 

- this (for chaining)

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
Overrides updateMatrixWorld to sync the world position and orientation to the OpenAL source

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Bool|Whether to force the update|

### var coneInnerAngle
```cj
public var coneInnerAngle: Float64
```
Directional cone inner angle (degrees), default 360 (omnidirectional)

### var coneOuterAngle
```cj
public var coneOuterAngle: Float64
```
Directional cone outer angle (degrees), default 360

### var coneOuterGain
```cj
public var coneOuterGain: Float64
```
Directional cone outer gain, default 0

### var distanceModel
```cj
public var distanceModel: Int64
```
Distance model: 0=None, 1=inverse, 2=inverseClamped, 3=linear, 4=linearClamped, 5=exponential, 6=exponentialClamped

### var maxDistance
```cj
public var maxDistance: Float64
```
Maximum attenuation distance (only effective for the linear model), default 10000.0

### var refDistance
```cj
public var refDistance: Float64
```
Reference distance (distance where attenuation begins), default 1.0

### var rolloffFactor
```cj
public var rolloffFactor: Float64
```
Rolloff factor (attenuation rate), default 1.0

### var velocity
```cj
public var velocity: Vector3
```
Velocity (m/s, world space, used for the Doppler effect; default 0 = no Doppler)

