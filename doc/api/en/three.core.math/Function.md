# Function
## func arrayMax\(Array<Float64>\)
```cj
public func arrayMax(array: Array < Float64 >): Float64
```
Find the maximum value in an array, returns -Float64.Infinity for empty arrays

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Input array|

Return: 

- Maximum value

## func arrayMin\(Array<Float64>\)
```cj
public func arrayMin(array: Array < Float64 >): Float64
```
Find the minimum value in an array, returns Float64.Infinity for empty arrays

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Input array|

Return: 

- Minimum value

## func arrayNeedsUint32\(Array<Int64>\)
```cj
public func arrayNeedsUint32(array: Array < Int64 >): Bool
```
Check if array contains values >= 65535 (requires Uint32 representation)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Int64>|Input array|

Return: 

- Whether Uint32 is needed

## func isTypedArray\(Any\)
```cj
public func isTypedArray(array: Any): Bool
```
Check if an object is a TypedArray (in Cangjie, checks if it is an Array type)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Any|Object to check|

Return: 

- Whether the object is a TypedArray

## func toNormalizedProjectionMatrix\(Matrix4\)
```cj
public func toNormalizedProjectionMatrix(projectionMatrix: Matrix4): Unit
```
Convert projection matrix from NDC range [-1, 1] to [0, 1]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|projectionMatrix|Matrix4|Projection matrix (modified in place)|

## func toReversedProjectionMatrix\(Matrix4\)
```cj
public func toReversedProjectionMatrix(projectionMatrix: Matrix4): Unit
```
Reverse the depth range of the projection matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|projectionMatrix|Matrix4|Projection matrix (modified in place)|

