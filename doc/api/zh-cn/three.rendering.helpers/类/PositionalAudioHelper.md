# 类
## class PositionalAudioHelper
```cj
public class PositionalAudioHelper <: Object3D
```
3D 位置音频辅助对象

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(\)
```cj
public init()
```
构造 PositionalAudio 辅助对象

### func init\(PositionalAudio,UInt32\)
```cj
public init(audio: PositionalAudio, color!: UInt32 = 0xffff00)
```


参数: 

|名称|类型|描述|
|---|---|---|
|audio|PositionalAudio||
|color|UInt32||

### func update\(\)
```cj
public func update(): Unit
```
同步音频源状态并更新可视化

### var audio
```cj
public var audio: PositionalAudio
```
被可视化的 3D 位置音频源

### var color
```cj
public var color: UInt32
```
自定义颜色（默认黄色）

### var innerCone
```cj
public var innerCone: LineSegments
```
内锥线框

### var maxSphere
```cj
public var maxSphere: Mesh
```
最大距离球

### var outerCone
```cj
public var outerCone: LineSegments
```
外锥线框

### var refSphere
```cj
public var refSphere: Mesh
```
参考距离球

### var velocityArrow
```cj
public var velocityArrow: ArrowHelper
```
速度箭头

