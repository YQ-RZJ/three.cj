# Class
## class AudioListenerHelper
```cj
public class AudioListenerHelper <: Object3D
```
Audio listener helper object

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases GPU resources

### func init\(\)
```cj
public init()
```
Constructs an AudioListener helper

### func init\(AudioListener,Float64\)
```cj
public init(listener: AudioListener, size!: Float64 = 1.0)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|listener|AudioListener||
|size|Float64||

### func update\(\)
```cj
public func update(): Unit
```
Syncs the listener state and updates the visualization

### var axes
```cj
public var axes: AxesHelper
```
头部坐标轴

### var forwardArrow
```cj
public var forwardArrow: ArrowHelper
```
前方向箭头（+Z）

### var listener
```cj
public var listener: AudioListener
```
被可视化的音频监听器

### var upArc
```cj
public var upArc: LineSegments
```
上方向标记弧线

