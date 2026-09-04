# Function
## func CatmullRom\(Float64,Float64,Float64,Float64,Float64\)
```cj
public func CatmullRom(t: Float64, p0: Float64, p1: Float64, p2: Float64, p3: Float64): Float64
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor|
|p0|Float64|First control point|
|p1|Float64|Second control point|
|p2|Float64|Third control point|
|p3|Float64|Fourth control point|

Return: 

- Computed point on the Catmull-Rom splineCompute a point on the Catmull-Rom spline

## func CubicBezier\(Float64,Float64,Float64,Float64,Float64\)
```cj
public func CubicBezier(t: Float64, p0: Float64, p1: Float64, p2: Float64, p3: Float64): Float64
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor|
|p0|Float64|First control point|
|p1|Float64|Second control point|
|p2|Float64|Third control point|
|p3|Float64|Fourth control point|

Return: 

- Computed point on the cubic Bezier curveCompute a point on the cubic Bezier curve

## func QuadraticBezier\(Float64,Float64,Float64,Float64\)
```cj
public func QuadraticBezier(t: Float64, p0: Float64, p1: Float64, p2: Float64): Float64
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor|
|p0|Float64|First control point|
|p1|Float64|Second control point|
|p2|Float64|Third control point|

Return: 

- Computed point on the quadratic Bezier curveCompute a point on the quadratic Bezier curve

## func deviation\(Array<Float64>,Array<Int64>,Int64,Array<UInt32>\)
```cj
public func deviation(data: Array < Float64 >, holeIndices: Array < Int64 >, dim: Int64, triangles: Array < UInt32 >): Float64
```
返回三角剖分面积与多边形面积之间的百分比差异

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<Float64>||
|holeIndices|Array<Int64>||
|dim|Int64||
|triangles|Array<UInt32>||

## func earcut\(Array<Float64>,Array<Int64>,Int64\)
```cj
public func earcut(data: Array < Float64 >, holeIndices: Array < Int64 >, dim: Int64): Array < UInt32 >
```
主入口：对多边形进行 earcut 三角剖分

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<Float64>||
|holeIndices|Array<Int64>||
|dim|Int64||

## func fromHalfFloat\(UInt16\)
```cj
public func fromHalfFloat(`val`: UInt16): Float64
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|`val`|UInt16||

Return: 

- Converted double-precision floating-point numberConvert a half-precision float (FP16) to a double-precision floating-point number

## func toHalfFloat\(Float64\)
```cj
public func toHalfFloat(`val`: Float64): UInt16
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|`val`|Float64||

Return: 

- 16-bit unsigned integer representation of the half-precision floatConvert a single/double-precision floating-point number to half-precision float (FP16)Half-precision floats use 16-bit storage, range approximately [-65504, 65504],with approximately 3 decimal digits of precision.

