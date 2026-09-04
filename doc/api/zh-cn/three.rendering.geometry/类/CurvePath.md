# 类
## class CurvePath
```cj
public open class CurvePath <: Curve
```
曲线路径类，由多条曲线串联而成的复合路径

### func add\(Curve\)
```cj
public func add(curve: Curve): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|curve|Curve|要添加的子曲线向此曲线路径添加一条子曲线|

### func closePath\(\)
```cj
public func closePath(): CurvePath
```


返回: 

- 当前实例的引用添加一条 LineCurve 闭合此路径仅当首末点不重合时才添加。

### func copy\(Curve\)
```cj
public open override func copy(source: Curve): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|source|Curve|要复制的曲线路径|

返回: 

- 当前实例的引用将给定曲线路径的设置复制到此实例

### func fromJSON\(HashMap<String,Any>\)
```cj
public open override func fromJSON(json: HashMap < String, Any >): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>||

返回: 

- 包含 autoClose 与 curves 数组的 HashMap将曲线路径序列化为 JSON

### func getCurveLengths\(\)
```cj
public func getCurveLengths(): Array < Float64 >
```


返回: 

- 子曲线累积长度数组返回所有子曲线的累积长度数组不能重写 getLengths()：UtoT 映射使用它。此处用 cacheLengths 缓存。

### func getLength\(\)
```cj
public override func getLength(): Float64
```


返回: 

- 曲线路径总长度返回曲线路径总长度重写 Curve.getLength：因 Curve.getLength 依赖 getPoint，而 CurvePath.getPoint 又依赖 getLength，故改用 getCurveLengths 的末值。

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|插值因子，0 到 1 之间|

返回: 

- 曲线路径上的点；超出范围返回空向量返回给定插值因子 t 处的曲线点（沿整条路径）算法：t * 总长 → 子曲线累积长度定位 → 子曲线参数 u → 子曲线 getPointAt(u)

### func getPoints\(Int64\)
```cj
public override func getPoints(divisions: Int64): Array < Vector3 >
```


参数: 

|名称|类型|描述|
|---|---|---|
|divisions|Int64|分段数，默认为 12|

返回: 

- 点数组返回沿曲线路径均匀 t 划分的点数组（去重相邻重复点）子曲线类型决定其 resolution：EllipseCurve 用 divisions*2，LineCurve/LineCurve3 用 1，SplineCurve 用 divisions*点数，其他用 divisions。

### func getSpacedPoints\(Int64\)
```cj
public override func getSpacedPoints(divisions: Int64): Array < Vector3 >
```


参数: 

|名称|类型|描述|
|---|---|---|
|divisions|Int64|分段数，默认为 40|

返回: 

- 点数组，长度为 divisions + 1（autoClose 为真时末尾重复首点）返回沿曲线路径均匀弧长分布的点数组

### func init\(\)
```cj
public init()
```
构造新的曲线路径

### func updateArcLengths\(\)
```cj
public func updateArcLengths(): Unit
```
标记 cacheLengths 失效并立即重新计算

### var autoClose
```cj
public var autoClose: Bool
```
是否自动用一条 LineCurve 闭合此路径

### var curves
```cj
public var curves: ArrayList < Curve >
```
持有此路径的所有子曲线

