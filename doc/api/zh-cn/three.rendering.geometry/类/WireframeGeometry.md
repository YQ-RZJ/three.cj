# 类
## class WireframeGeometry
```cj
public class WireframeGeometry <: BufferGeometry
```
线框几何体类，从 BufferGeometry 提取所有边线（去重）

### func init\(BufferGeometry\)
```cj
public init(geometry: BufferGeometry)
```
构造线框几何体

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|源 BufferGeometry|

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
构造参数

