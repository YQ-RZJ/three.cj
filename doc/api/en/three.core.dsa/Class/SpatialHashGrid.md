# Class
## class SpatialHashGrid
```cj
public class SpatialHashGrid
```
Spatial hash grid

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the grid

### func init\(Float64\)
```cj
public init(cellSize: Float64)
```
Constructs a spatial hash grid

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cellSize|Float64|Cell edge length (should be on the order of the query radius; <= 0 is treated as 1.0)|

### func init\(\)
```cj
public init()
```
Constructs a spatial hash grid with the default cell size (1.0)

### func insert\(Int64,Float64,Float64,Float64,Float64\)
```cj
public func insert(index: Int64, x: Float64, y: Float64, z: Float64, radius: Float64): Unit
```
Registers an element (into every cell overlapped by its bounding sphere)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Element index (must be consecutive, 0-based, matching call order)x Center Xy Center Yz Center Zradius Bounding sphere radius|
|x|Float64||
|y|Float64||
|z|Float64||
|radius|Float64||

### func queryAabb\(Float64,Float64,Float64,Float64,Float64,Float64,ArrayList<Int64>\)
```cj
public func queryAabb(minX: Float64, minY: Float64, minZ: Float64, maxX: Float64, maxY: Float64, maxZ: Float64, out: ArrayList < Int64 >): Unit
```
Axis-aligned box neighborhood query

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minX|Float64|Query box min XminY Query box min YminZ Query box min ZmaxX Query box max XmaxY Query box max YmaxZ Query box max Zout Hit element indices|
|minY|Float64||
|minZ|Float64||
|maxX|Float64||
|maxY|Float64||
|maxZ|Float64||
|out|ArrayList<Int64>||

### func querySphere\(Float64,Float64,Float64,Float64,ArrayList<Int64>\)
```cj
public func querySphere(cx: Float64, cy: Float64, cz: Float64, radius: Float64, out: ArrayList < Int64 >): Unit
```
Sphere neighborhood query

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cx|Float64|Query sphere center Xcy Query sphere center Ycz Query sphere center Zradius Query sphere radiusout Hit element indices (the caller supplies the buffer so it can be reused)|
|cy|Float64||
|cz|Float64||
|radius|Float64||
|out|ArrayList<Int64>||

### prop cellCount: Int64
```cj
public prop cellCount: Int64
```
Number of non-empty cells

### prop cellSize: Float64
```cj
public prop cellSize: Float64
```
Cell edge length

### prop elementCount: Int64
```cj
public prop elementCount: Int64
```
Total number of elements

