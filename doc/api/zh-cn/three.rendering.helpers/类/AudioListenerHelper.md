# 类
## class AudioListenerHelper
```cj
public class AudioListenerHelper <: Object3D
```
音频监听器辅助对象

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(AudioListener,Float64\)
```cj
public init(listener: AudioListener, size!: Float64 = 1.0)
```
构造 AudioListener 辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|listener|AudioListener|要可视化的 AudioListenersize 头部坐标轴尺寸，默认 1.0|
|size|Float64||

### func update\(\)
```cj
public func update(): Unit
```
同步监听器状态并更新可视化

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

