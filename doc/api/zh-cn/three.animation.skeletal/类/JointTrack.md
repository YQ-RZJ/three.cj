# 类
## class JointTrack
```cj
public class JointTrack
```
单关节轨道的运行时关键帧数据

### func init\(\)
```cj
public init()
```
默认构造（空通道）

### func init\(Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(transTimes: Array < Float32 >, transValues: Array < Float32 >, rotTimes: Array < Float32 >, rotValues: Array < Float32 >, scaleTimes: Array < Float32 >, scaleValues: Array < Float32 >)
```
从通道数组构造

参数: 

|名称|类型|描述|
|---|---|---|
|transTimes|Array<Float32>||
|transValues|Array<Float32>||
|rotTimes|Array<Float32>||
|rotValues|Array<Float32>||
|scaleTimes|Array<Float32>||
|scaleValues|Array<Float32>||

### func numRotKeyframes\(\)
```cj
public func numRotKeyframes(): Int
```
旋转通道关键帧数量

### func numScaleKeyframes\(\)
```cj
public func numScaleKeyframes(): Int
```
缩放通道关键帧数量

### func numTransKeyframes\(\)
```cj
public func numTransKeyframes(): Int
```
平移通道关键帧数量

### var rotTimes
```cj
public var rotTimes: Array < Float32 >
```
旋转通道时间点（升序，秒）

### var rotValues
```cj
public var rotValues: Array < Float32 >
```
旋转通道值（每帧 4 分量，长度 = rotTimes.size * 4）

### var scaleTimes
```cj
public var scaleTimes: Array < Float32 >
```
缩放通道时间点（升序，秒）

### var scaleValues
```cj
public var scaleValues: Array < Float32 >
```
缩放通道值（每帧 3 分量，长度 = scaleTimes.size * 3）

### var transTimes
```cj
public var transTimes: Array < Float32 >
```
平移通道时间点（升序，秒）

### var transValues
```cj
public var transValues: Array < Float32 >
```
平移通道值（每帧 3 分量，长度 = transTimes.size * 3）

