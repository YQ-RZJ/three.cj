# 类
## class TrackOptimizer
```cj
public class TrackOptimizer
```
通道优化器

### func init\(Float32,Float32,Float32\)
```cj
public init(floatTolerance!: Float32 = 0.001f32, float3Tolerance!: Float32 = 0.001f32, rotationTolerance!: Float32 = 0.001f32)
```


参数: 

|名称|类型|描述|
|---|---|---|
|floatTolerance|Float32||
|float3Tolerance|Float32||
|rotationTolerance|Float32||

### func optimizeFloat3Copy\(RawFloat3Track\)
```cj
public func optimizeFloat3Copy(input: RawFloat3Track): RawFloat3Track
```
创建优化后的三分量向量通道副本

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawFloat3Track||

### func optimizeFloat3\(RawFloat3Track\)
```cj
public func optimizeFloat3(input: RawFloat3Track): Unit
```
优化三分量向量通道

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawFloat3Track|离线三分量向量通道数据（就地修改）|

### func optimizeFloatCopy\(RawFloatTrack\)
```cj
public func optimizeFloatCopy(input: RawFloatTrack): RawFloatTrack
```
创建优化后的浮点通道副本

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawFloatTrack||

### func optimizeFloat\(RawFloatTrack\)
```cj
public func optimizeFloat(input: RawFloatTrack): Unit
```
优化浮点通道

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawFloatTrack|离线浮点通道数据（就地修改）|

### func optimizeQuaternionCopy\(RawQuaternionTrack\)
```cj
public func optimizeQuaternionCopy(input: RawQuaternionTrack): RawQuaternionTrack
```
创建优化后的四元数通道副本

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawQuaternionTrack||

### func optimizeQuaternion\(RawQuaternionTrack\)
```cj
public func optimizeQuaternion(input: RawQuaternionTrack): Unit
```
优化四元数通道

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawQuaternionTrack|离线四元数通道数据（就地修改）|

### var float3Tolerance
```cj
public var float3Tolerance: Float32
```
三分量向量优化误差容忍度

### var floatTolerance
```cj
public var floatTolerance: Float32
```
浮点值优化误差容忍度

### var rotationTolerance
```cj
public var rotationTolerance: Float32
```
旋转优化误差容忍度（弧度）

