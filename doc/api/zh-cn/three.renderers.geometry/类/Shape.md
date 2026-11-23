# 类
## class Shape
```cj
public class Shape <: Path
```
形状类，定义带可选洞的 2D 形状平面

### func copy\(Curve\)
```cj
public open override func copy(source: Curve): Curve
```
复制源形状的设置到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Curve|源曲线|

返回: 

- 当前实例的引用

### func extractPoints\(Int64\)
```cj
public func extractPoints(divisions: Int64): HashMap < String, Any >
```
返回形状与其洞的轮廓数据

参数: 

|名称|类型|描述|
|---|---|---|
|divisions|Int64|结果精度|

返回: 

- 包含 shape（外形点数组）与 holes（各洞点数组）的 HashMap

### func fromJSON\(HashMap<String,Any>\)
```cj
public override func fromJSON(json: HashMap < String, Any >): Curve
```
从 JSON 反序列化形状

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|包含形状数据的 HashMap|

返回: 

- 当前实例的引用

### func getPointsHoles\(Int64\)
```cj
public func getPointsHoles(divisions: Int64): Array < Array < Vector3 >>
```
返回各洞轮廓的 2D 点数组

参数: 

|名称|类型|描述|
|---|---|---|
|divisions|Int64|结果精度|

返回: 

- 各洞的 2D 点数组的数组

### func init\(\)
```cj
public init()
```
构造新的空形状

### func init\(Array<Vector3>\)
```cj
public init(points: Array < Vector3 >)
```
从点数组构造形状

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|定义形状的 2D 点数组|

### var holes
```cj
public var holes: ArrayList < Path >
```
定义形状中的洞，洞定义必须使用与外形相反的缠绕顺序

### var uuid
```cj
public var uuid: String
```
形状的 UUID

