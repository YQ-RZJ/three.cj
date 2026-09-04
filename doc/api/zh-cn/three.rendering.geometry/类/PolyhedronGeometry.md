# 类
## class PolyhedronGeometry
```cj
public open class PolyhedronGeometry <: BufferGeometry
```
多面体几何体类，将顶点数组投影到球面并细分到指定细节级别

### func fromJSON\(HashMap<String,Any>\)
```cj
public static func fromJSON(data: HashMap < String, Any >): PolyhedronGeometry
```


参数: 

|名称|类型|描述|
|---|---|---|
|data|HashMap<String,Any>|包含序列化几何体数据的 JSON 对象|

返回: 

- 新的 PolyhedronGeometry 实例从 JSON 数据创建实例的工厂方法

### func init\(Array<Float64>,Array<Int64>,Float64,Int64\)
```cj
public init(vertices!: Array < Float64 >= Array < Float64 >(), indices!: Array < Int64 >= Array < Int64 >(), radius!: Float64 = 1.0, detail!: Int64 = 0)
```
构造多面体几何体

参数: 

|名称|类型|描述|
|---|---|---|
|vertices|Array<Float64>|描述基础形状的平铺顶点数组indices 描述基础形状的平铺索引数组radius 形状的半径，默认为 1.0detail 细分级别，默认为 0|
|indices|Array<Int64>||
|radius|Float64||
|detail|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
保存构造参数，实例化后修改不影响几何体

