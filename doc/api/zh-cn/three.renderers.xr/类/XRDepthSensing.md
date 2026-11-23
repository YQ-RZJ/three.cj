# 类
## class XRDepthSensing
```cj
public class XRDepthSensing <: IReleasable
```
XR 深度感知

### func bindRenderer\(ThreeRenderer\)
```cj
public func bindRenderer(renderer: ThreeRenderer): XRDepthSensing
```
绑定渲染器（深度纹理销毁经其下发到后端）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器实例|

返回: 

- 自身（链式调用）

### func getMesh\(\)
```cj
public func getMesh(): Option < Mesh >
```
获取深度网格

返回: 

- 深度可视化网格（首次调用惰性创建，后续返回缓存）

### func getTextureIdx\(\)
```cj
public func getTextureIdx(): UInt16
```
深度纹理句柄索引（只读裸值；画面内调试打印用途）

### func init\(\)
```cj
public init()
```


### func isAvailable\(\)
```cj
public func isAvailable(): Bool
```
深度感知是否可用

返回: 

- 是否可用

### func release\(\)
```cj
public func release(): Bool
```
释放资源

### func reset\(\)
```cj
public func reset(): Unit
```
重置深度数据

### func update\(Float64,Float64,Int64,Int64\)
```cj
public func update(depthNear: Float64, depthFar: Float64, width: Int64, height: Int64): Unit
```
更新深度数据

参数: 

|名称|类型|描述|
|---|---|---|
|depthNear|Float64|深度近值depthFar 深度远值width 深度宽度height 深度高度|
|depthFar|Float64||
|width|Int64||
|height|Int64||

### prop releasable: Bool
```cj
public prop releasable: Bool
```
资源有效性：句柄有效且标记可用时为 true

