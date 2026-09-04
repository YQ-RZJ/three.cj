# Class
## class Curve
```cj
public open class Curve
```
Abstract base class for curves

### func clone\(\)
```cj
public func clone(): Curve
```


Return: 

- Clone of this instanceReturn a new curve with values copied from this instance

### func computeFrenetFrames\(Int64,Bool\)
```cj
public func computeFrenetFrames(segments: Int64, closed!: Bool = false):(Array < Vector3 >, Array < Vector3 >, Array < Vector3 >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|segments|Int64|Number of segments|
|closed|Bool|Whether the curve is closed, default false|

Return: 

- Tuple containing three arrays: tangents, normals, and binormalsCompute the Frenet frames (tangent, normal, binormal) arrays of the curveUsed for tubular geometries (TubeGeometry) etc. to generate meshes along the curve.See http://www.cs.indiana.edu/pub/techreports/TR425.pdf

### func copy\(Curve\)
```cj
public open func copy(source: Curve): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Curve|Curve to copy from|

Return: 

- Reference to the current instanceCopy the settings of the given curve to this instance

### func fromJSON\(HashMap<String,Any>\)
```cj
public open func fromJSON(json: HashMap < String, Any >): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|HashMap containing type and arcLengthDivisions|

Return: 

- Reference to the current instanceDeserialize the curve from JSON

### func getLength\(\)
```cj
public open func getLength(): Float64
```


Return: 

- Total length of the curveReturn the total length of the curve

### func getLengths\(Int64\)
```cj
public open func getLengths(divisions: Int64): Array < Float64 >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|divisions|Int64|Number of divisions, default this.arcLengthDivisions|

Return: 

- Cumulative length array of length divisions + 1Return the cumulative segment length array

### func getPointAt\(Float64\)
```cj
public open func getPointAt(u: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|u|Float64|Uniform arc length parameter between 0 and 1|

Return: 

- Point on the curveReturn the curve point at the given u (arc-length uniformized parameter)

### func getPoint\(Float64\)
```cj
public open func getPoint(t: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor, between 0 and 1|

Return: 

- Point on the curve; concrete subclasses override this methodReturn the curve point at the given interpolation factor t

### func getPoints\(Int64\)
```cj
public open func getPoints(divisions: Int64): Array < Vector3 >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|divisions|Int64|Number of divisions, default 5|

Return: 

- Array of points, length is divisions + 1Return an array of evenly distributed points along the curve (uniformly divided by t)

### func getSpacedPoints\(Int64\)
```cj
public open func getSpacedPoints(divisions: Int64): Array < Vector3 >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|divisions|Int64|Number of divisions, default 5|

Return: 

- Array of points, length is divisions + 1Return an array of evenly arc-length distributed points along the curve (uniformly divided by u)

### func getTangentAt\(Float64\)
```cj
public open func getTangentAt(u: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|u|Float64|Uniform arc length parameter between 0 and 1|

Return: 

- Normalized tangent vectorReturn the curve tangent vector at the given u (arc-length uniform parameter)

### func getTangent\(Float64\)
```cj
public open func getTangent(t: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor|

Return: 

- Normalized tangent vectorReturn the curve tangent vector at the given t (normalized)Compute the tangent by finite difference of two points near t.

### func getUtoTmapping\(Float64,?Float64\)
```cj
public func getUtoTmapping(u: Float64, distance!:?Float64 = None): Float64
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|u|Float64|Uniform arc length parameter between 0 and 1|
|distance|?Float64|Optional target distance value; if not provided, uses u * total arc length|

Return: 

- Corresponding curve parameter tMap the arc-length uniform parameter u to the curve parameter t (binary search implementation)

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

