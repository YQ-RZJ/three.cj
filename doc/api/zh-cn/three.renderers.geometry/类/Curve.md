# 类
## class Curve
```cj
public open class Curve
```
曲线抽象基类

### func clone\(\)
```cj
public func clone(): Curve
```


返回: 

- 此实例的克隆返回从此实例复制值的新曲线

### func computeFrenetFrames\(Int64,Bool\)
```cj
public func computeFrenetFrames(segments: Int64, closed!: Bool = false):(Array < Vector3 >, Array < Vector3 >, Array < Vector3 >)
```


参数: 

|名称|类型|描述|
|---|---|---|
|segments|Int64|分段数|
|closed|Bool|曲线是否闭合，默认为 false|

返回: 

- 包含 tangents/normals/binormals 三个数组的元组计算曲线的 Frenet 标架（切线、法线、副法线）数组用于管状几何体（TubeGeometry）等沿曲线生成网格。详见 http://www.cs.indiana.edu/pub/techreports/TR425.pdf

### func copy\(Curve\)
```cj
public open func copy(source: Curve): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|source|Curve|要复制的曲线|

返回: 

- 当前实例的引用将给定曲线的设置复制到此实例

### func fromJSON\(HashMap<String,Any>\)
```cj
public open func fromJSON(json: HashMap < String, Any >): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|包含 type、arcLengthDivisions 的 HashMap|

返回: 

- 当前实例的引用从 JSON 反序列化曲线

### func getLength\(\)
```cj
public open func getLength(): Float64
```


返回: 

- 曲线总长度返回曲线总长度

### func getLengths\(Int64\)
```cj
public open func getLengths(divisions: Int64): Array < Float64 >
```


参数: 

|名称|类型|描述|
|---|---|---|
|divisions|Int64|分段数，默认为 this.arcLengthDivisions|

返回: 

- 长度为 divisions + 1 的累积长度数组返回累积段长度数组

### func getPointAt\(Float64\)
```cj
public open func getPointAt(u: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|u|Float64|0 到 1 之间的均匀弧长参数|

返回: 

- 曲线上的点返回给定 u（沿曲线弧长均匀化参数）处的曲线点

### func getPoint\(Float64\)
```cj
public open func getPoint(t: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|插值因子，0 到 1 之间|

返回: 

- 曲线上的点；具体子类重写此方法返回给定插值因子 t 处的曲线点

### func getPoints\(Int64\)
```cj
public open func getPoints(divisions: Int64): Array < Vector3 >
```


参数: 

|名称|类型|描述|
|---|---|---|
|divisions|Int64|分段数，默认为 5|

返回: 

- 点数组，长度为 divisions + 1返回沿曲线均匀分布的点数组（按 t 均匀划分）

### func getSpacedPoints\(Int64\)
```cj
public open func getSpacedPoints(divisions: Int64): Array < Vector3 >
```


参数: 

|名称|类型|描述|
|---|---|---|
|divisions|Int64|分段数，默认为 5|

返回: 

- 点数组，长度为 divisions + 1返回沿曲线均匀弧长分布的点数组（按 u 均匀划分）

### func getTangentAt\(Float64\)
```cj
public open func getTangentAt(u: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|u|Float64|0 到 1 之间的均匀弧长参数|

返回: 

- 归一化切线向量返回给定 u（弧长均匀参数）处的曲线切线向量

### func getTangent\(Float64\)
```cj
public open func getTangent(t: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|插值因子|

返回: 

- 归一化切线向量返回给定 t 处的曲线切线向量（已归一化）通过求 t 附近两点差分计算切线。

### func getUtoTmapping\(Float64,?Float64\)
```cj
public func getUtoTmapping(u: Float64, distance!:?Float64 = None): Float64
```


参数: 

|名称|类型|描述|
|---|---|---|
|u|Float64|0 到 1 之间的均匀弧长参数|
|distance|?Float64|可选的目标距离值；不传则用 u * 总弧长|

返回: 

- 对应的曲线参数 t将弧长均匀参数 u 映射到曲线参数 t（二分搜索精确实现）

### func init\(\)
```cj
public init()
```
构造新的曲线实例

### func updateArcLengths\(\)
```cj
public open func updateArcLengths(): Unit
```
标记 cacheArcLengths 失效并立即重新计算

### var arcLengthDivisions
```cj
public var arcLengthDivisions: Int64
```
计算累积段长度时的分段数
曲线很大时建议增大此值以确保精度（getSpacedPoints 等）

### var kind
```cj
public var kind: String
```
几何体类型字符串，用于序列化/反序列化多态判断

### var needsUpdate
```cj
public var needsUpdate: Bool
```
若曲线参数已变，必须设为 true（用于失效 cacheArcLengths）

