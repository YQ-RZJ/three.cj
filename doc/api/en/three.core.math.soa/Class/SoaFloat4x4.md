# Class
## class SoaFloat4x4
```cj
public class SoaFloat4x4
```
SoA 4x4 matrix struct storing 4 matrices in column-major order

### func fromTransform\(SoaTransform\)
```cj
public static func fromTransform(transform: SoaTransform): SoaFloat4x4
```
Build 4 model-space 4x4 matrices from a SoaTransform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|transform|SoaTransform|SoA-format transform|

Return: 

- SoaFloat4x4 containing the 4 model-space matrices

### func getColumn0\(Int\)
```cj
public func getColumn0(matrix: Int): Vector3F
```
Get column 0 (first 3 elements) of a specific matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Int|Matrix index (0-3)|

Return: 

- (m[0], m[1], m[2])

### func getColumn1\(Int\)
```cj
public func getColumn1(matrix: Int): Vector3F
```
Get column 1 of a specific matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Int|Matrix index (0-3)|

Return: 

- Vector3F

### func getColumn2\(Int\)
```cj
public func getColumn2(matrix: Int): Vector3F
```
Get column 2 of a specific matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Int|Matrix index (0-3)|

Return: 

- Vector3F

### func getTranslation\(Int\)
```cj
public func getTranslation(matrix: Int): Vector3F
```
Get translation from a specific matrix (column 3, first 3 elements)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Int|Matrix index (0-3)|

Return: 

- Vector3F

### func get\(Int,Int\)
```cj
public func get(matrix: Int, element: Int): Float32
```
Get element from a specific matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Int|Matrix index (0-3)|
|element|Int|Element index (0-15, column-major)|

### func init\(\)
```cj
public init()
```
Default constructor, initializes to 4 identity matrices

### func init\(Array<Float32>\)
```cj
public init(data: Array < Float32 >)
```
Construct from raw 64-element array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<Float32>|Array of 64 elements (4 matrices × 16 components)|

### func set\(Int,Int,Float32\)
```cj
public func set(matrix: Int, element: Int, value: Float32): Unit
```
Set element of a specific matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Int|Matrix index (0-3)|
|element|Int|Element index (0-15)|
|value|Float32|Value|

### var m
```cj
public var m: Array < Float32 >
```
Components of 4 matrices, each 16 Float32 (column-major)

