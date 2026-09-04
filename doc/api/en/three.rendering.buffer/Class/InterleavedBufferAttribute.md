# Class
## class InterleavedBufferAttribute
```cj
public class InterleavedBufferAttribute
```
Interleaved buffer attribute

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(m: Matrix4): InterleavedBufferAttribute
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
public func applyNormalMatrix(m: Matrix3): InterleavedBufferAttribute
```
Apply the given 3x3 normal matrix to this attribute, only applicable when itemSize is 3

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|3x3 normal matrix to apply|

Return: 

- Reference to this instance

### func array\(\)
```cj
public func array(): Array < Float64 >
```
Get the array holding interleaved data

Return: 

- Underlying data array

### func clone\(\)
```cj
public func clone(): InterleavedBufferAttribute
```
Clone this interleaved buffer attribute

Return: 

- New InterleavedBufferAttribute instance

### func count\(\)
```cj
public func count(): Int64
```
Number of data items in this buffer attribute

Return: 

- Number of data items

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

### func init\(InterleavedBuffer,Int64,Int64\)
```cj
public init(interleavedBuffer: InterleavedBuffer, itemSize: Int64, offset: Int64)
```
Compatible overload: 3-parameter form (normalized defaults to false)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|interleavedBuffer|InterleavedBuffer|Buffer holding interleaved dataitemSize Data item sizeoffset Attribute offset in the buffer|
|itemSize|Int64||
|offset|Int64||

### func init\(\)
```cj
public init()
```
No-arg constructor (for fastjson deserialization)

### func init\(InterleavedBuffer,Int64,Int64,Bool\)
```cj
public init(interleavedBuffer: InterleavedBuffer, itemSize: Int64, offset: Int64, normalized!: Bool = false)
```
Construct a new interleaved buffer attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|interleavedBuffer|InterleavedBuffer|Buffer holding interleaved dataitemSize Data item sizeoffset Attribute offset in the buffernormalized Whether to normalize, default false|
|itemSize|Int64||
|offset|Int64||
|normalized|Bool||

### func setComponent\(Int64,Int64,Float64\)
```cj
public func setComponent(index: Int64, component: Int64, value: Float64): InterleavedBufferAttribute
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

### func setNeedsUpdate\(Bool\)
```cj
public func setNeedsUpdate(value: Bool): Unit
```
Mark attribute as needing update to GPU

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Bool|Whether needs update|

### func setW\(Int64,Float64\)
```cj
public func setW(index: Int64, w: Float64): InterleavedBufferAttribute
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
public func setXYZW(index: Int64, x: Float64, y: Float64, z: Float64, w: Float64): InterleavedBufferAttribute
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
public func setXYZ(index: Int64, x: Float64, y: Float64, z: Float64): InterleavedBufferAttribute
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
public func setXY(index: Int64, x: Float64, y: Float64): InterleavedBufferAttribute
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
public func setX(index: Int64, x: Float64): InterleavedBufferAttribute
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
public func setY(index: Int64, y: Float64): InterleavedBufferAttribute
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
public func setZ(index: Int64, z: Float64): InterleavedBufferAttribute
```
Set the z component of the vector at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index in the buffer attributez z value to set|
|z|Float64||

Return: 

- Reference to this instance

### func transformDirection\(Matrix4\)
```cj
public func transformDirection(m: Matrix4): InterleavedBufferAttribute
```
Apply the given 4x4 matrix to this attribute (only for direction vectors), only applicable when itemSize is 3

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrix to apply|

Return: 

- Reference to this instance

### var data
```cj
public var data: InterleavedBuffer
```
Buffer holding interleaved data

### var itemSize
```cj
public var itemSize: Int64
```
Data item size, see BufferAttribute.itemSize

### var name
```cj
public var name: String
```
Buffer attribute name

### var normalized
```cj
public var normalized: Bool
```
Whether to normalize integer data, see BufferAttribute.normalized

### var offset
```cj
public var offset: Int64
```
Attribute offset in the buffer

