# 类
## class SpotLightShadow
```cj
public class SpotLightShadow <: LightShadow
```
专用于SpotLight的阴影配置，根据光源角度动态调整相机视锥

### func copy\(LightShadow\)
```cj
public func copy(source: LightShadow): LightShadow
```
将给定SpotLightShadow实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|LightShadow|源光源阴影实例|

返回: 

- 本实例

### func init\(\)
```cj
public init()
```
构造一个新的聚光源阴影配置

### func updateMatrices\(Light\)
```cj
public func updateMatrices(light: Light): Unit
```
更新阴影相机的投影矩阵及阴影矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|light|Light|正在渲染阴影的SpotLight实例|

### var aspect
```cj
public var aspect: Float64
```
纹理宽高比修正因子，最终aspect=(mapSize.width/mapSize.height)×this.aspect，默认1

### var focus
```cj
public var focus: Float64
```
聚焦系数，相机视场角=光源角度×focus×RAD2DEG，值域[0,1]，默认1

