# 类
## class QuadraticBezierCurve
```cj
public class QuadraticBezierCurve <: Curve
```
2D 二次贝塞尔曲线类

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|source|Curve|要复制的源曲线|

返回: 

- 当前实例的引用将给定二次贝塞尔曲线的设置复制到此实例

### func fromJSON\(HashMap<String,Any>\)
```cj
public override func fromJSON(json: HashMap < String, Any >): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|包含 v0、v1、v2 数组的 HashMap|

返回: 

- 当前实例的引用从 JSON 反序列化二次贝塞尔曲线

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|插值因子，0 到 1 之间|

返回: 

- 曲线上的点（z=0）返回曲线上给定插值因子 t 处的点用二次贝塞尔基函数分别插值 x、y 分量。

### func init\(Vector3,Vector3,Vector3\)
```cj
public init(v0!: Vector3 = Vector3(), v1!: Vector3 = Vector3(), v2!: Vector3 = Vector3())
```


参数: 

|名称|类型|描述|
|---|---|---|
|v0|Vector3|起始点，默认为空向量|
|v1|Vector3|控制点，默认为空向量|
|v2|Vector3|终止点，默认为空向量构造新的 2D 二次贝塞尔曲线|

### var v0
```cj
public var v0: Vector3
```
起始点

### var v1
```cj
public var v1: Vector3
```
控制点

### var v2
```cj
public var v2: Vector3
```
终止点

