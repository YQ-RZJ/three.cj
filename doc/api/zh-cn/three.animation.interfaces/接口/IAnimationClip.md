# 接口
## interface IAnimationClip
```cj
public interface IAnimationClip
```
动画剪辑接口：blend 包引用 AnimationClip 的契约类型

### prop blendMode: Int64
```cj
mut prop blendMode: Int64
```
混合模式（NormalAnimationBlendMode / AdditiveAnimationBlendMode）

### prop duration: Float64
```cj
mut prop duration: Float64
```
剪辑持续时间（秒）

### prop name: String
```cj
mut prop name: String
```
剪辑名称

### prop tracks: Array < IKeyframeTrack >
```cj
mut prop tracks: Array < IKeyframeTrack >
```
关键帧轨道数组（通过 IKeyframeTrack 接口引用，避免依赖 blend 包 KeyframeTrack 具体类）

### prop userData: HashMap < String, Any >
```cj
mut prop userData: HashMap < String, Any >
```
用户自定义数据

### prop uuid: String
```cj
mut prop uuid: String
```
唯一标识

