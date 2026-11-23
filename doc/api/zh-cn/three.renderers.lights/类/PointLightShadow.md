# 类
## class PointLightShadow
```cj
public class PointLightShadow <: LightShadow
```
专用于PointLight的阴影配置，内部相机为透视投影

### func computeFaceViewMatrix\(Vector3,Int64\)
```cj
public func computeFaceViewMatrix(lightPos: Vector3, faceIndex: Int64): Matrix4
```
计算6面立方体阴影相机的view矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|lightPos|Vector3|光源世界坐标faceIndex 面索引（0..5）|
|faceIndex|Int64||

返回: 

- 该面的view矩阵

### func getCubeDirection\(Int64\)
```cj
public func getCubeDirection(faceIndex: Int64): Vector3
```
获取指定面的方向向量

参数: 

|名称|类型|描述|
|---|---|---|
|faceIndex|Int64|面索引（0..5）|

返回: 

- 该面的方向向量

### func getCubeUp\(Int64\)
```cj
public func getCubeUp(faceIndex: Int64): Vector3
```
获取指定面的up向量

参数: 

|名称|类型|描述|
|---|---|---|
|faceIndex|Int64|面索引（0..5）|

返回: 

- 该面的up向量

### func init\(\)
```cj
public init()
```
构造一个新的点光源阴影配置

### func updateMatrices\(Light\)
```cj
public override func updateMatrices(light: Light): Unit
```
覆写updateMatrices：点光源阴影矩阵为单位矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|light|Light|正在渲染阴影的光源|

### var cubeDirections
```cj
public var cubeDirections: ArrayList < Vector3 >
```
6面立方体阴影相机的方向向量（+X, -X, +Y, -Y, +Z, -Z）

### var cubeUps
```cj
public var cubeUps: ArrayList < Vector3 >
```
6面立方体阴影相机的up向量

