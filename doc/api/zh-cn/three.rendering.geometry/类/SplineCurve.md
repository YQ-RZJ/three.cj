# 类
## class SplineCurve
```cj
public class SplineCurve <: Curve
```
2D 样条曲线类

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|source|Curve||

### func fromJSON\(HashMap<String,Any>\)
```cj
public override func fromJSON(json: HashMap < String, Any >): Curve
```


参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>||

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|插值因子，0 到 1 之间|

返回: 

- 曲线上的点（z=0）返回样条曲线上给定插值因子 t 处的点使用 CatmullRom 基函数插值 x、y 分量。

### func init\(Array<Vector3>\)
```cj
public init(points!: Array < Vector3 >= Array < Vector3 >(0, { _ =>
    Vector3()
}))
```
构造新的 2D 样条曲线

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|定义曲线的 2D 点数组，默认为空|

### var points
```cj
public var points: Array < Vector3 >
```
定义曲线的 2D 点数组（仓颉侧用 Vector3，z=0）

