# Class
## class Euler
```cj
public class Euler
```
Euler angles class, describing rotation using three angles (x, y, z) and rotation order

### func clone\(\)
```cj
public func clone(): Euler
```
Clone current Euler angles

Return: 

- New Euler angles instance

### func copy\(Euler\)
```cj
public func copy(e: Euler): Euler
```
Copy values from another Euler angles to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|e|Euler|Source Euler angles|

Return: 

- This instance

### func equals\(Euler\)
```cj
public func equals(e: Euler): Bool
```
Check if current Euler angles equal the given Euler angles

Parameter: 

|Name|Type|Describe|
|---|---|---|
|e|Euler|Euler angles to compare|

Return: 

- Whether equal

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Euler
```
Set Euler angle components from array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Array containing component valuesoffset Starting index, defaults to 0|
|offset|Int64||

Return: 

- This instance

### func init\(\)
```cj
public init()
```


### func init\(Float64,Float64,Float64,EulerOrder\)
```cj
public init(x: Float64, y: Float64, z: Float64, order: EulerOrder)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64||
|y|Float64||
|z|Float64||
|order|EulerOrder||

### func init\(Float64,Float64,Float64\)
```cj
public init(x: Float64, y: Float64, z: Float64)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64||
|y|Float64||
|z|Float64||

### func onChange\(\(\)\->Unit\)
```cj
public func onChange(callback:() -> Unit): Euler
```
Set change callback function, called when Euler angle values are modified

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|Callback function|

Return: 

- This instance

### func reorder\(EulerOrder\)
```cj
public func reorder(newOrder: EulerOrder): Euler
```
Reorder rotation order (via quaternion, loses rotation turn information)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|newOrder|EulerOrder|New rotation order|

Return: 

- This instance

### func setFromQuaternion\(Quaternion\)
```cj
public func setFromQuaternion(q: Quaternion): Euler
```
Set Euler angles from a normalized quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Normalized quaternion|

Return: 

- This instance

### func setFromQuaternion\(Quaternion,EulerOrder\)
```cj
public func setFromQuaternion(q: Quaternion, order: EulerOrder): Euler
```
Set Euler angles from a normalized quaternion with specified order

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Normalized quaternionorder Rotation order|
|order|EulerOrder||

Return: 

- This instance

### func setFromQuaternion\(Quaternion,EulerOrder,Bool\)
```cj
public func setFromQuaternion(q: Quaternion, order: EulerOrder, update: Bool): Euler
```
Set Euler angles from a normalized quaternion with specified order and update flag

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Normalized quaternionorder Rotation orderupdate Whether to trigger change callback|
|order|EulerOrder||
|update|Bool||

Return: 

- This instance

### func setFromRotationMatrix\(Matrix4\)
```cj
public func setFromRotationMatrix(m: Matrix4): Euler
```
Set Euler angles from a pure rotation matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrix|

Return: 

- This instance

### func setFromRotationMatrix\(Matrix4,EulerOrder\)
```cj
public func setFromRotationMatrix(m: Matrix4, order: EulerOrder): Euler
```
Set Euler angles from a pure rotation matrix with specified order

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrixorder Rotation order|
|order|EulerOrder||

Return: 

- This instance

### func setFromRotationMatrix\(Matrix4,EulerOrder,Bool\)
```cj
public func setFromRotationMatrix(m: Matrix4, order: EulerOrder, update: Bool): Euler
```
Set Euler angles from a pure rotation matrix with specified order and update flag

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrixorder Rotation orderupdate Whether to trigger change callback|
|order|EulerOrder||
|update|Bool||

Return: 

- This instance

### func setFromVector3\(Vector3\)
```cj
public func setFromVector3(v: Vector3): Euler
```
Set Euler angles from a vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vector|

Return: 

- This instance

### func setFromVector3\(Vector3,EulerOrder\)
```cj
public func setFromVector3(v: Vector3, order: EulerOrder): Euler
```
Set Euler angles from a vector with specified order

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vectororder Rotation order|
|order|EulerOrder||

Return: 

- This instance

### func set\(Float64,Float64,Float64,EulerOrder\)
```cj
public func set(x: Float64, y: Float64, z: Float64, order: EulerOrder): Euler
```
Set Euler angle components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x-axis rotation angle in radiansy y-axis rotation angle in radiansz z-axis rotation angle in radiansorder Rotation order|
|y|Float64||
|z|Float64||
|order|EulerOrder||

Return: 

- This instance

### func set\(Float64,Float64,Float64\)
```cj
public func set(x: Float64, y: Float64, z: Float64): Euler
```
Set Euler angle components (keeping current rotation order)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x-axis rotation angle in radiansy y-axis rotation angle in radiansz z-axis rotation angle in radians|
|y|Float64||
|z|Float64||

Return: 

- This instance

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
Write Euler angle components to array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Target arrayoffset Starting index, defaults to 0|
|offset|Int64||

Return: 

- Array containing component values

### prop order: EulerOrder
```cj
public mut prop order: EulerOrder
```
Rotation order, triggers onChange callback on assignment

### prop x: Float64
```cj
public mut prop x: Float64
```
x-axis rotation angle in radians, triggers onChange callback on assignment

### prop y: Float64
```cj
public mut prop y: Float64
```
y-axis rotation angle in radians, triggers onChange callback on assignment

### prop z: Float64
```cj
public mut prop z: Float64
```
z-axis rotation angle in radians, triggers onChange callback on assignment

### let DEFAULT\_ORDER
```cj
public static let DEFAULT_ORDER: EulerOrder = EulerOrder.XYZ
```
Default rotation order (static member, not serialized)

