# 类
## class LineCurve3
```cj
public class LineCurve3 <: Curve
```
3D 直线段曲线类

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|source|Curve|要复制的源曲线|

返回: 

- 当前实例的引用将给定 3D 直线段的设置复制到此实例

### func fromJSON\(HashMap<String,Any>\)
```cj
public override func fromJSON(json: HashMap < String, Any >): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|包含 v1、v2 数组的 HashMap|

返回: 

- 当前实例的引用从 JSON 反序列化 3D 直线段

### func getPointAt\(Float64\)
```cj
public override func getPointAt(u: Float64): Vector3
```
直线是线性的，可直接重写 getPointAt

参数: 

|名称|类型|描述|
|---|---|---|
|u|Float64||

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|插值因子，0 到 1 之间|

返回: 

- 直线上的点返回直线上给定插值因子 t 处的点

### func getTangentAt\(Float64\)
```cj
public override func getTangentAt(u: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|u|Float64|0 到 1 之间的均匀弧长参数|

返回: 

- 归一化切线直线切线与 u 无关，可直接重写 getTangentAt

### func getTangent\(Float64\)
```cj
public override func getTangent(t: Float64): Vector3
```
返回直线方向上的归一化切线

参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64||

### func init\(Vector3,Vector3\)
```cj
public init(v1!: Vector3 = Vector3(), v2!: Vector3 = Vector3())
```


参数: 

|名称|类型|描述|
|---|---|---|
|v1|Vector3|起始点，默认为空向量|
|v2|Vector3|终止点，默认为空向量构造新的 3D 直线段|

### var v1
```cj
public var v1: Vector3
```
起始点

### var v2
```cj
public var v2: Vector3
```
末点

