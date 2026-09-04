# Class
## class BufferAttribute
```cj
public open class BufferAttribute <: AttributeReader
```
Buffer attribute class, stores vertex attribute data

### func addUpdateRange\(Int64,Int64\)
```cj
public func addUpdateRange(start: Int64, count: Int64): Unit
```
Add data range that needs to be updated to GPU

Parameter: 

|Name|Type|Describe|
|---|---|---|
|start|Int64|Start positioncount Number of components to update|
|count|Int64||

### func applyMatrix3\(Matrix3\)
```cj
public func applyMatrix3(m: Matrix3): BufferAttribute
```
Apply the given 3x3 matrix to this attribute, only applicable when itemSize is 2 or 3

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|3x3 matrix to apply|

Return: 

- Reference to this instance

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(m: Matrix4): BufferAttribute
```
Apply the given 4x4 matrix to this attribute, only applicable when itemSize is 3

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrix to apply|

Return: 

- Reference to this instance

### func applyNormalMatrix\(Matrix3\)
```cj
public func applyNormalMatrix(m: Matrix3): BufferAttribute
```
Apply the given 3x3 normal matrix to this attribute, only applicable when itemSize is 3

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|3x3 normal matrix to apply|

Return: 

- Reference to this instance

### func clearUpdateRanges\(\)
```cj
public func clearUpdateRanges(): Unit
```
清除所有更新范围

### func clone\(\)
```cj
public func clone(): BufferAttribute
```
Create a copy of this buffer attribute

Return: 

- New BufferAttribute instance

### func copyArray\(Array<Float64>\)
```cj
public func copyArray(arr: Array < Float64 >): BufferAttribute
```
Copy given array data to this buffer attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|arr|Array<Float64>|Array to copy|

Return: 

- Reference to this instance

### func copyAt\(Int64,BufferAttribute,Int64\)
```cj
public func copyAt(index1: Int64, attribute: BufferAttribute, index2: Int64): BufferAttribute
```
Copy a vector from another buffer attribute to this attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index1|Int64|Target index in this attributeattribute Source buffer attributeindex2 Source index in source attribute|
|attribute|BufferAttribute||
|index2|Int64||

Return: 

- Reference to this instance

### func copy\(BufferAttribute\)
```cj
public func copy(source: BufferAttribute): BufferAttribute
```
Copy data from another buffer attribute to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|BufferAttribute|Source buffer attribute|

Return: 

- Reference to this instance

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose resources occupied by this buffer attribute

### func getArrayType\(\)
```cj
public open func getArrayType(): String
```
Return the JS TypedArray name corresponding to this attribute for JSON serialization

Return: 

- JS TypedArray subclass name, e.g. `"Float32Array"`, `"Uint16Array"`

### func getComponent\(Int64,Int64\)
```cj
public func getComponent(index: Int64, component: Int64): Float64
```
Return the specified component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributecomponent Component index|
|component|Int64||

Return: 

- Value of the component

### func getW\(Int64\)
```cj
public func getW(index: Int64): Float64
```
Return the w component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attribute|

Return: 

- Value of the w component

### func getX\(Int64\)
```cj
public func getX(index: Int64): Float64
```
Return the x component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attribute|

Return: 

- Value of the x component

### func getY\(Int64\)
```cj
public func getY(index: Int64): Float64
```
Return the y component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attribute|

Return: 

- Value of the y component

### func getZ\(Int64\)
```cj
public func getZ(index: Int64): Float64
```
Return the z component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attribute|

Return: 

- Value of the z component

### func init\(\)
```cj
public init()
```
No-arg constructor (for fastjson deserialization)

### func init\(Array<Float64>,Int64,Bool\)
```cj
public init(array: Array < Float64 >, itemSize: Int64, normalized!: Bool = false)
```
Construct a new buffer attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Array storing attribute dataitemSize Number of data items per vertexnormalized Whether to normalize, default false|
|itemSize|Int64||
|normalized|Bool||

### func markNeedsUpdate\(\)
```cj
public func markNeedsUpdate(): Unit
```
Mark attribute as needing update to GPU

### func onUpload\(\(\)\->Unit\)
```cj
public func onUpload(callback:() -> Unit): BufferAttribute
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|Callback function|

Return: 

- Reference to this instance

### func setComponent\(Int64,Int64,Float64\)
```cj
public func setComponent(index: Int64, component: Int64, value: Float64): BufferAttribute
```
Set the value of the specified component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributecomponent Component indexvalue Value to set|
|component|Int64||
|value|Float64||

Return: 

- Reference to this instance

### func setUsage\(Int64\)
```cj
public func setUsage(value: Int64): BufferAttribute
```
Set the usage pattern of this buffer attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|Usage pattern (e.g. StaticDrawUsage, DynamicDrawUsage)|

Return: 

- Reference to this instance

### func setW\(Int64,Float64\)
```cj
public func setW(index: Int64, w: Float64): BufferAttribute
```
Set the w component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributew w value to set|
|w|Float64||

Return: 

- Reference to this instance

### func setXYZW\(Int64,Float64,Float64,Float64,Float64\)
```cj
public func setXYZW(index: Int64, x: Float64, y: Float64, z: Float64, w: Float64): BufferAttribute
```
Set the x, y, z, w components of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributex Value of the x componenty Value of the y componentz Value of the z componentw Value of the w component|
|x|Float64||
|y|Float64||
|z|Float64||
|w|Float64||

Return: 

- Reference to this instance

### func setXYZ\(Int64,Float64,Float64,Float64\)
```cj
public func setXYZ(index: Int64, x: Float64, y: Float64, z: Float64): BufferAttribute
```
Set the x, y, z components of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributex Value of the x componenty Value of the y componentz Value of the z component|
|x|Float64||
|y|Float64||
|z|Float64||

Return: 

- Reference to this instance

### func setXY\(Int64,Float64,Float64\)
```cj
public func setXY(index: Int64, x: Float64, y: Float64): BufferAttribute
```
Set the x and y components of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributex Value of the x componenty Value of the y component|
|x|Float64||
|y|Float64||

Return: 

- Reference to this instance

### func setX\(Int64,Float64\)
```cj
public func setX(index: Int64, x: Float64): BufferAttribute
```
Set the x component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributex x value to set|
|x|Float64||

Return: 

- Reference to this instance

### func setY\(Int64,Float64\)
```cj
public func setY(index: Int64, y: Float64): BufferAttribute
```
Set the y component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributey y value to set|
|y|Float64||

Return: 

- Reference to this instance

### func setZ\(Int64,Float64\)
```cj
public func setZ(index: Int64, z: Float64): BufferAttribute
```
Set the z component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributez z value to set|
|z|Float64||

Return: 

- Reference to this instance

### func set\(Array<Float64>,Int64\)
```cj
public func set(value: Array < Float64 >, offset!: Int64 = 0): BufferAttribute
```
Set array data in this buffer attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Array<Float64>|Data array to setoffset Offset, default 0|
|offset|Int64||

Return: 

- Reference to this instance

### func transformDirection\(Matrix4\)
```cj
public func transformDirection(m: Matrix4): BufferAttribute
```
Apply the given 4x4 matrix to this attribute (only for direction vectors), only applicable when itemSize is 3

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrix to apply|

Return: 

- Reference to this instance

### prop count: Int64
```cj
public mut prop count: Int64
```


### var array
```cj
public var array: Array < Float64 >
```
Data array storing vertex attribute data, should have itemSize * count elements

### var gpuType
```cj
public var gpuType: Int64
```
Configure GPU data type used in shaders

### var itemSize
```cj
public var itemSize: Int64
```
Data group size: number of array elements per vertex

### var kind
```cj
public var kind: String
```
Type string for polymorphic dispatch

### var name
```cj
public var name: String
```
Attribute name

### var normalized
```cj
public var normalized: Bool
```
Whether to normalize integer data

### var onUploadCallback
```cj
public var onUploadCallback:() -> Unit
```
Upload callback, executed after renderer transfers data to GPU

### var updateRanges
```cj
public var updateRanges: ArrayList <(Int64, Int64) >
```
Update range list, for updating only part of stored vector components

### var usage
```cj
public var usage: Int64
```
Expected usage pattern for data storage, for GPU optimization

### var version
```cj
public var version: Int64
```
Version number, incremented each time needsUpdate is set to true

