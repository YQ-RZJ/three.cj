# 类
## class CatmullRomCurve3
```cj
public open class CatmullRomCurve3 <: Curve
```
3D Catmull-Rom 样条曲线类

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|source|Curve|要复制的源曲线|

返回: 

- 当前实例的引用将给定 CatmullRomCurve3 的设置复制到此实例

### func fromJSON\(HashMap<String,Any>\)
```cj
public func fromJSON(json: HashMap < String, Any >): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>||

返回: 

- 包含 points、closed、curveType、tension 的 HashMap将 CatmullRomCurve3 序列化为 JSON

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|插值因子，0 到 1 之间|

返回: 

- 曲线上的点返回曲线上给定插值因子 t 处的点根据 curveType 选择不同的插值方式：- centripetal/chordal：使用非均匀 Catmull-Rom 参数化- catmullrom：使用经典 Catmull-Rom（带 tension 参数）

### func init\(Array<Vector3>,Bool,String,Float64\)
```cj
public init(points!: Array < Vector3 >= Array < Vector3 >(0, { _ =>
    Vector3()
}), closed!: Bool = false, curveType!: String = "centripetal", tension!: Float64 = 0.5)
```


参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|定义曲线的 3D 点数组，默认为空|
|closed|Bool|曲线是否闭合，默认为 false|
|curveType|String|曲线类型，默认为 'centripetal'|
|tension|Float64|张力参数，默认为 0.5构造新的 Catmull-Rom 样条曲线|

### var closed
```cj
public var closed: Bool
```
曲线是否闭合

### var curveType
```cj
public var curveType: String
```
曲线类型：centripetal | chordal | catmullrom

### var points
```cj
public var points: Array < Vector3 >
```
定义曲线的 3D 点数组

### var tension
```cj
public var tension: Float64
```
曲线张力（仅在 curveType 为 catmullrom 时使用）

