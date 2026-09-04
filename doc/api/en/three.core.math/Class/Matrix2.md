# Class
## class Matrix2
```cj
public class Matrix2
```
2x2 matrix class, stored in column-major order

### func clone\(\)
```cj
public func clone(): Matrix2
```
Create a copy of this matrix

Return: 

- A new Matrix2 instance

### func copyTo\(Matrix2\)
```cj
public func copyTo(m: Matrix2): Matrix2
```
Copy values from this matrix to a target matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix2|Target matrix|

Return: 

- Current matrix instance (supports chaining)

### func copy\(Matrix2\)
```cj
public func copy(m: Matrix2): Matrix2
```
Copy values from another matrix to this matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix2|Source matrix|

Return: 

- Current matrix instance (supports chaining)

### func determinant\(\)
```cj
public func determinant(): Float64
```
Calculate the determinant of the matrix

Return: 

- The determinant value

### func equals\(Matrix2\)
```cj
public func equals(m: Matrix2): Bool
```
Check if this matrix equals another matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix2|The matrix to compare with|

Return: 

- Returns true if all elements are equal

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Matrix2
```
Read matrix elements from an array (column-major order)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Source array|
|offset|Int64|Starting offset in the array, defaults to 0|

Return: 

- Current matrix instance (supports chaining)

### func identity\(\)
```cj
public func identity(): Matrix2
```
Set the matrix to the identity matrix

Return: 

- Current matrix instance (supports chaining)

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(n11!: Float64 = 1.0, n12!: Float64 = 0.0, n21!: Float64 = 0.0, n22!: Float64 = 1.0)
```
Construct a new 2x2 matrix, set elements in row-major order if parameters are provided

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n11|Float64|Element at row 1, column 1|
|n12|Float64|Element at row 1, column 2|
|n21|Float64|Element at row 2, column 1|
|n22|Float64|Element at row 2, column 2|

### func inverse\(\)
```cj
public func inverse(): Matrix2
```
Calculate the inverse of the matrix, reset to identity if determinant is 0

Return: 

- Current matrix instance (supports chaining)

### func makeRotation\(Float64\)
```cj
public func makeRotation(theta: Float64): Matrix2
```
Create a rotation matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|theta|Float64|Rotation angle in radians|

Return: 

- Current matrix instance (supports chaining)

### func makeScale\(Float64,Float64\)
```cj
public func makeScale(sx: Float64, sy: Float64): Matrix2
```
Create a scaling matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sx|Float64|X-axis scale factor|
|sy|Float64|Y-axis scale factor|

Return: 

- Current matrix instance (supports chaining)

### func makeTranslation\(Float64,Float64\)
```cj
public func makeTranslation(tx: Float64, ty: Float64): Matrix2
```
Create a translation matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tx|Float64|X-axis translation amount|
|ty|Float64|Y-axis translation amount|

Return: 

- Current matrix instance (supports chaining)

### func multiplyMatrices\(Matrix2,Matrix2\)
```cj
public func multiplyMatrices(a: Matrix2, b: Matrix2): Matrix2
```
Calculate the product of two matrices and store in this matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Matrix2|Left-hand side matrix|
|b|Matrix2|Right-hand side matrix|

Return: 

- Current matrix instance (supports chaining)

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Matrix2
```
Multiply each element of the matrix by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- Current matrix instance (supports chaining)

### func multiply\(Matrix2\)
```cj
public func multiply(m: Matrix2): Matrix2
```
Multiply this matrix by another matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix2|Right-hand side matrix|

Return: 

- Current matrix instance (supports chaining)

### func setFromMatrix3\(Matrix3\)
```cj
public func setFromMatrix3(m: Matrix3): Matrix2
```
Extract a 2x2 sub-matrix from a 3x3 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|Source 3x3 matrix|

Return: 

- Current matrix instance (supports chaining)

### func set\(Float64,Float64,Float64,Float64\)
```cj
public func set(n11: Float64, n12: Float64, n21: Float64, n22: Float64): Matrix2
```
Set matrix elements in row-major order

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n11|Float64|Element at row 1, column 1|
|n12|Float64|Element at row 1, column 2|
|n21|Float64|Element at row 2, column 1|
|n22|Float64|Element at row 2, column 2|

Return: 

- Current matrix instance (supports chaining)

### func toArray\(Option<Array<Float64>>,Int64\)
```cj
public func toArray(array!: Option < Array < Float64 >>= None, offset!: Int64 = 0): Array < Float64 >
```
Write matrix elements to an array (column-major order)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Option<Array<Float64>>|Target array, creates a new array if None|
|offset|Int64|Starting offset in the array, defaults to 0|

Return: 

- Array containing the matrix elements

### func transpose\(\)
```cj
public func transpose(): Matrix2
```
Transpose the matrix

Return: 

- Current matrix instance (supports chaining)

### var elements
```cj
public var elements: Array < Float64 >
```
Matrix elements, stored in column-major order

