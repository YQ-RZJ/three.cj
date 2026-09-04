# Class
## class ShapePath
```cj
public class ShapePath
```


### func bezierCurveTo\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func bezierCurveTo(cp1x: Float64, cp1y: Float64, cp2x: Float64, cp2y: Float64, x: Float64, y: Float64): Unit
```
Draws a cubic Bezier curve from the current point to the specified position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cp1x|Float64|First control point X coordinatecp1y First control point Y coordinatecp2x Second control point X coordinatecp2y Second control point Y coordinatex Target X coordinatey Target Y coordinate|
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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64||
|y|Float64||

### func moveTo\(Float64,Float64\)
```cj
public func moveTo(x: Float64, y: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64||
|y|Float64||

### func quadraticCurveTo\(Float64,Float64,Float64,Float64\)
```cj
public func quadraticCurveTo(cpx: Float64, cpy: Float64, x: Float64, y: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|cpx|Float64||
|cpy|Float64||
|x|Float64||
|y|Float64||

### func splineThru\(Array<Vector3>\)
```cj
public func splineThru(points: Array < Vector3 >): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>||

### func toShapes\(\)
```cj
public func toShapes(): Array < Shape >
```
Converts all sub-paths to an array of Shape objects

Return: 

- Array of Shape objects

### var currentPath
```cj
public var currentPath: Option < Path >
```


### var subPaths
```cj
public var subPaths: ArrayList < Path >
```
子路径列表：元素均为 Path（moveTo 创建）。具体化为 ArrayList<Path> 替代原 ArrayList<Any>。

