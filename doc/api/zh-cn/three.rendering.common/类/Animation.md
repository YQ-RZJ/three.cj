# 类
## class Animation
```cj
public open class Animation
```
渲染通用动画类，管理动画回调与帧更新

### func init\(\)
```cj
public init()
```
构造默认动画实例

### func setAnimationLoop\(\(Float64\)\->Unit\)
```cj
public func setAnimationLoop(cb:(Float64) -> Unit): Unit
```
设置动画循环回调函数

参数: 

|名称|类型|描述|
|---|---|---|
|cb|(Float64)->Unit|动画回调函数|

### func start\(\)
```cj
public func start(): Unit
```
启动动画

### func stop\(\)
```cj
public func stop(): Unit
```
停止动画

### func update\(Float64\)
```cj
public func update(delta: Float64): Unit
```
每帧更新动画，调用回调函数

参数: 

|名称|类型|描述|
|---|---|---|
|delta|Float64|帧间隔时间（秒）|

### var callback
```cj
public var callback:(Float64) -> Unit
```
动画回调函数，参数为帧间隔时间（秒）

### var id
```cj
public var id: Int64
```
动画标识符

