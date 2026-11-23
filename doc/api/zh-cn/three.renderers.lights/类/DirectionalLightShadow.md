# 类
## class DirectionalLightShadow
```cj
public class DirectionalLightShadow <: LightShadow
```
平行光阴影配置，专用于 DirectionalLight

### func enableCSM\(Camera\)
```cj
public func enableCSM(mainCamera: Camera): Unit
```
启用 CSM 级联阴影

参数: 

|名称|类型|描述|
|---|---|---|
|mainCamera|Camera|主相机（提供 near/far 用于切分）|

### func getCascadeCamera\(Int64\)
```cj
public func getCascadeCamera(cascadeIndex: Int64): OrthographicCamera
```
获取指定级联索引的阴影相机

参数: 

|名称|类型|描述|
|---|---|---|
|cascadeIndex|Int64|级联索引|

返回: 

- 阴影相机

### func getCascadeFrustum\(Int64\)
```cj
public func getCascadeFrustum(cascadeIndex: Int64): Frustum
```
获取指定级联索引的视锥体

参数: 

|名称|类型|描述|
|---|---|---|
|cascadeIndex|Int64|级联索引|

返回: 

- 视锥体

### func getCascadeMatrix\(Int64\)
```cj
public func getCascadeMatrix(cascadeIndex: Int64): Matrix4
```
获取指定级联索引的阴影矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|cascadeIndex|Int64|级联索引|

返回: 

- 阴影矩阵

### func init\(\)
```cj
public init()
```
构造一个新的平行光阴影配置

### func updateCSMMatrices\(Light,Camera\)
```cj
public func updateCSMMatrices(light: Light, mainCamera: Camera): Unit
```
更新 CSM 级联阴影相机矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|light|Light|正在渲染阴影的 DirectionalLightmainCamera 主相机mainCameraNear 主相机 nearmainCameraFar 主相机 far|
|mainCamera|Camera||

### var cascadeFrustums
```cj
public var cascadeFrustums: ArrayList < Frustum >
```
CSM 各级视锥体（用于裁剪物体）

### var cascadeMatrices
```cj
public var cascadeMatrices: ArrayList < Matrix4 >
```
CSM 各级阴影矩阵数组（长度 = cascadeCount）

