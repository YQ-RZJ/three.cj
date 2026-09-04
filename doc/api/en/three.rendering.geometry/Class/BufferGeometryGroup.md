# Class
## class BufferGeometryGroup
```cj
public class BufferGeometryGroup
```
Draw group structure, defining geometry draw groups

### func init\(Int64,Int64,Int64\)
```cj
public init(start: Int64, count: Int64, materialIndex!: Int64 = 0)
```
Constructs a draw group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|start|Int64|Start positioncount Element countmaterialIndex Material index, default 0|
|count|Int64||
|materialIndex|Int64||

### var count
```cj
public var count: Int64
```
How many vertices (or indices) this group contains

### var materialIndex
```cj
public var materialIndex: Int64
```
Material array index to use, default 0

### var start
```cj
public var start: Int64
```
First element in this draw call (first vertex for non-indexed geometry, first triangle index otherwise)

