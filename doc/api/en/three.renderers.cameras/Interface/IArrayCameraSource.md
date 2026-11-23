# Interface
## interface IArrayCameraSource
```cj
public interface IArrayCameraSource
```
Read-only interface for array camera: provides sub-camera projection/inverse view matrix data

### func getCameraCount\(\)
```cj
func getCameraCount(): Int64
```
Get the number of sub-cameras

Return: 

- Number of sub-cameras

### func getCameraMatrixWorldInverseElements\(Int64\)
```cj
func getCameraMatrixWorldInverseElements(i: Int64): Array < Float64 >
```
Get the inverse view matrix elements of the i-th sub-camera (16 elements, column-major)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64|Sub-camera index|

Return: 

- Inverse view matrix element array

### func getCameraProjectionElements\(Int64\)
```cj
func getCameraProjectionElements(i: Int64): Array < Float64 >
```
Get the projection matrix elements of the i-th sub-camera (16 elements, column-major)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64|Sub-camera index|

Return: 

- Projection matrix element array

