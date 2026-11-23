# 类
## class OctahedronGeometry
```cj
public class OctahedronGeometry <: PolyhedronGeometry
```
八面体几何体（多面体特例）

### func fromJSON\(HashMap<String,Any>\)
```cj
public static func fromJSON(data: HashMap < String, Any >): OctahedronGeometry
```
从 JSON 数据创建实例的工厂方法

参数: 

|名称|类型|描述|
|---|---|---|
|data|HashMap<String,Any>|包含序列化几何体数据的 JSON 对象|

返回: 

- 新的 OctahedronGeometry 实例

### func init\(Float64,Int64\)
```cj
public init(radius!: Float64 = 1.0, detail!: Int64 = 0)
```
构造八面体几何体

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|八面体外接球半径，默认 1.0detail 细分级别，默认 0|
|detail|Int64||

