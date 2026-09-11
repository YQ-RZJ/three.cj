# 类
## class AnimationOptimizer
```cj
public class AnimationOptimizer
```
动画优化器

### func init\(Float32,Float32,Float32\)
```cj
public init(translationTolerance!: Float32 = 0.001f32, rotationTolerance!: Float32 = 0.001f32, scaleTolerance!: Float32 = 0.001f32)
```


参数: 

|名称|类型|描述|
|---|---|---|
|translationTolerance|Float32||
|rotationTolerance|Float32||
|scaleTolerance|Float32||

### func optimizeCopy\(RawAnimation\)
```cj
public func optimizeCopy(input: RawAnimation): RawAnimation
```
创建优化后的副本（不修改原始数据）

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawAnimation|原始离线动画数据|

返回: 

- 优化后的副本

### func optimize\(RawAnimation\)
```cj
public func optimize(input: RawAnimation): Unit
```
优化离线动画数据（就地修改）

参数: 

|名称|类型|描述|
|---|---|---|
|input|RawAnimation|输入/输出的离线动画数据|

### var rotationTolerance
```cj
public var rotationTolerance: Float32
```
旋转优化误差容忍度（角度弧度）

### var scaleTolerance
```cj
public var scaleTolerance: Float32
```
缩放优化误差容忍度（向量长度）

### var translationTolerance
```cj
public var translationTolerance: Float32
```
平移优化误差容忍度（向量长度）

