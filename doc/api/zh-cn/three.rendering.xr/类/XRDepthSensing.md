# 类
## class XRDepthSensing
```cj
public class XRDepthSensing
```
XR 深度感知

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放资源

### func getMesh\(\)
```cj
public func getMesh(): Option < Mesh >
```
获取深度网格

返回: 

- 深度可视化网格（首次调用惰性创建，后续返回缓存）

### func getTexture\(\)
```cj
public func getTexture(): TextureHandle
```
获取深度纹理

返回: 

- 深度纹理句柄

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

### func reset\(\)
```cj
public func reset(): Unit
```
重置深度数据

### func setTexture\(TextureHandle\)
```cj
public func setTexture(texture: TextureHandle): Unit
```
设置深度纹理

参数: 

|名称|类型|描述|
|---|---|---|
|texture|TextureHandle|深度纹理句柄|

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

