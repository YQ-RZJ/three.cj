# 类
## class ShapePath
```cj
public class ShapePath
```


### func bezierCurveTo\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func bezierCurveTo(cp1x: Float64, cp1y: Float64, cp2x: Float64, cp2y: Float64, x: Float64, y: Float64): Unit
```
从当前点画三次贝塞尔曲线到指定位置

参数: 

|名称|类型|描述|
|---|---|---|
|cp1x|Float64|第一个控制点 X 坐标cp1y 第一个控制点 Y 坐标cp2x 第二个控制点 X 坐标cp2y 第二个控制点 Y 坐标x 目标 X 坐标y 目标 Y 坐标|
|cp1y|Float64||
|cp2x|Float64||
|cp2y|Float64||
|x|Float64||
|y|Float64||

### func init\(\)
```cj
public init()
```


### func lineTo\(Float64,Float64\)
```cj
public func lineTo(x: Float64, y: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64||
|y|Float64||

### func moveTo\(Float64,Float64\)
```cj
public func moveTo(x: Float64, y: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64||
|y|Float64||

### func quadraticCurveTo\(Float64,Float64,Float64,Float64\)
```cj
public func quadraticCurveTo(cpx: Float64, cpy: Float64, x: Float64, y: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|cpx|Float64||
|cpy|Float64||
|x|Float64||
|y|Float64||

### func splineThru\(Array<Vector3>\)
```cj
public func splineThru(points: Array < Vector3 >): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>||

### func toShapes\(\)
```cj
public func toShapes(): Array < Shape >
```
将所有子路径转换为 Shape 对象数组

返回: 

- Shape 对象数组

### var currentPath
```cj
public var currentPath: Option < Path >
```


### var subPaths
```cj
public var subPaths: ArrayList < Path >
```
子路径列表：元素均为 Path（moveTo 创建）。具体化为 ArrayList<Path> 替代原 ArrayList<Any>。

