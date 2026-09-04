# Class
## class Matrix3
```cj
public class Matrix3
```
3x3 matrix class, stored in column-major order

### func clone\(\)
```cj
public func clone(): Matrix3
```
Creates a copy of this matrix

Return: 

- New Matrix3 instance

### func copy\(Matrix3\)
```cj
public func copy(m: Matrix3): Matrix3
```
Copies another matrix's values to this matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|Source matrix|

Return: 

- This instance

### func determinant\(\)
```cj
public func determinant(): Float64
```
Computes the determinant of the matrix

Return: 

- Determinant value

### func equals\(Matrix3\)
```cj
public func equals(m: Matrix3): Bool
```
Checks if this matrix equals another matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|Matrix to compare|

Return: 

- True if all elements are equal

### func extractBasis\(Vector3,Vector3,Vector3\)
```cj
public func extractBasis(xAxis: Vector3, yAxis: Vector3, zAxis: Vector3): Matrix3
```
Extracts the basis vectors from the matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|xAxis|Vector3|X-axis basis vectoryAxis Y-axis basis vectorzAxis Z-axis basis vector|
|yAxis|Vector3||
|zAxis|Vector3||

Return: 

- This instance

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Matrix3
```
Reads matrix elements from an array (column-major order)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Source arrayoffset Starting offset in the array, defaults to 0|
|offset|Int64||

Return: 

- This instance

### func getInverse\(Matrix4\)
```cj
public func getInverse(m: Matrix4): Matrix3
```
Extracts the 3x3 inverse from a 4x4 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|Source 4x4 matrix|

Return: 

- This instance

### func getNormalMatrix\(Matrix4\)
```cj
public func getNormalMatrix(m: Matrix4): Matrix3
```
Computes the normal matrix from a 4x4 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|Source 4x4 matrix|

Return: 

- This instance

### func identity\(\)
```cj
public func identity(): Matrix3
```
Sets the matrix to the identity matrix

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Default constructor, initializes to identity matrix

### func init\(Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(n11: Float64, n12: Float64, n13: Float64, n21: Float64, n22: Float64, n23: Float64, n31: Float64, n32: Float64, n33: Float64)
```
Constructs a 3x3 matrix with specified elements (row-major parameters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n11|Float64|Row 1, Column 1 elementn12 Row 1, Column 2 elementn13 Row 1, Column 3 elementn21 Row 2, Column 1 elementn22 Row 2, Column 2 elementn23 Row 2, Column 3 elementn31 Row 3, Column 1 elementn32 Row 3, Column 2 elementn33 Row 3, Column 3 element|
|n12|Float64||
|n13|Float64||
|n21|Float64||
|n22|Float64||
|n23|Float64||
|n31|Float64||
|n32|Float64||
|n33|Float64||

### func invert\(\)
```cj
public func invert(): Matrix3
```
Computes the inverse matrix (using analytical method)

Return: 

- This instance

### func makeRotation\(Float64\)
```cj
public func makeRotation(theta: Float64): Matrix3
```
Sets as a 2D rotation matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|theta|Float64|Rotation angle in radians, counterclockwise|

Return: 

- This instance

### func makeScale\(Float64,Float64\)
```cj
public func makeScale(x: Float64, y: Float64): Matrix3
```
Sets as a 2D scale matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|X-axis scaley Y-axis scale|
|y|Float64||

Return: 

- This instance

### func makeTranslation\(Float64,Float64\)
```cj
public func makeTranslation(x: Float64, y: Float64): Matrix3
```
Sets as a 2D translation matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|X-axis translationy Y-axis translation|
|y|Float64||

Return: 

- This instance

### func multiplyMatrices\(Matrix3,Matrix3\)
```cj
public func multiplyMatrices(a: Matrix3, b: Matrix3): Matrix3
```
Computes the product of two matrices and stores it in this matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Matrix3|Left-hand side matrixb Right-hand side matrix|
|b|Matrix3||

Return: 

- This instance

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Matrix3
```
Multiplies each element of the matrix by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func multiply\(Matrix3\)
```cj
public func multiply(m: Matrix3): Matrix3
```
Multiplies this matrix by another matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|Right-hand side matrix|

Return: 

- This instance

### func premultiply\(Matrix3\)
```cj
public func premultiply(m: Matrix3): Matrix3
```
Pre-multiplies by the given matrix: m * this

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|Matrix|

Return: 

- This instance

### func rotate\(Float64\)
```cj
public func rotate(theta: Float64): Matrix3
```
Rotates the matrix (cf. JS: Matrix3.rotate, deprecated - use makeRotation instead)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|theta|Float64|Rotation angle in radians|

Return: 

- This instance

### func scale\(Float64\)
```cj
public func scale(v: Float64): Matrix3
```
Scales the first two columns of the matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float64|Scale value|

Return: 

- This instance

### func setFromMatrix4\(Matrix4\)
```cj
public func setFromMatrix4(m: Matrix4): Matrix3
```
Extracts a 3x3 submatrix from a 4x4 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|Source 4x4 matrix|

Return: 

- This instance

### func setUvTransform\(Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func setUvTransform(tx: Float64, ty: Float64, sx: Float64, sy: Float64, rotation: Float64, cx: Float64, cy: Float64): Matrix3
```
Sets the UV transform matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tx|Float64|X-axis translationty Y-axis translationsx X-axis scale factorsy Y-axis scale factorrotation Rotation angle in radianscx Rotation center X coordinatecy Rotation center Y coordinate|
|ty|Float64||
|sx|Float64||
|sy|Float64||
|rotation|Float64||
|cx|Float64||
|cy|Float64||

Return: 

- This instance

### func set\(Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func set(n11: Float64, n12: Float64, n13: Float64, n21: Float64, n22: Float64, n23: Float64, n31: Float64, n32: Float64, n33: Float64): Matrix3
```
Sets matrix elements in row-major order

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n11|Float64|Row 1, Column 1 elementn12 Row 1, Column 2 elementn13 Row 1, Column 3 elementn21 Row 2, Column 1 elementn22 Row 2, Column 2 elementn23 Row 2, Column 3 elementn31 Row 3, Column 1 elementn32 Row 3, Column 2 elementn33 Row 3, Column 3 element|
|n12|Float64||
|n13|Float64||
|n21|Float64||
|n22|Float64||
|n23|Float64||
|n31|Float64||
|n32|Float64||
|n33|Float64||

Return: 

- This instance

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
Writes matrix elements into an array (column-major order)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Target arrayoffset Starting offset, defaults to 0|
|offset|Int64||

Return: 

- Array containing matrix elements

### func translate\(Float64,Float64\)
```cj
public func translate(tx: Float64, ty: Float64): Matrix3
```
Translates the matrix (cf. JS: Matrix3.translate, deprecated - use makeTranslation instead)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tx|Float64|X-axis translationty Y-axis translation|
|ty|Float64||

Return: 

- This instance

### func transposeIntoArray\(Array<Float64>\)
```cj
public func transposeIntoArray(r: Array < Float64 >): Matrix3
```
Writes transposed matrix elements into an array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Array<Float64>|Target array|

Return: 

- This instance

### func transpose\(\)
```cj
public func transpose(): Matrix3
```
Transposes the matrix

Return: 

- This instance

### var elements
```cj
public var elements: Array < Float64 >
```
Matrix elements, stored in column-major order

