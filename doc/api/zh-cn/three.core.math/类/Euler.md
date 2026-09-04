# 类
## class Euler
```cj
public class Euler
```
欧拉角类，用三个角度 (x, y, z) 和旋转顺序 (order) 描述旋转

### func clone\(\)
```cj
public func clone(): Euler
```
克隆当前欧拉角

返回: 

- 新的欧拉角实例

### func copy\(Euler\)
```cj
public func copy(e: Euler): Euler
```
复制另一个欧拉角的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|e|Euler|源欧拉角|

返回: 

- 当前实例

### func equals\(Euler\)
```cj
public func equals(e: Euler): Bool
```
判断当前欧拉角是否与给定的欧拉角相等

参数: 

|名称|类型|描述|
|---|---|---|
|e|Euler|比较的欧拉角|

返回: 

- 是否相等

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Euler
```
从数组设置欧拉角分量

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|包含分量值的数组offset 起始索引，默认为 0|
|offset|Int64||

返回: 

- 当前实例

### func init\(\)
```cj
public init()
```


### func init\(Float64,Float64,Float64,EulerOrder\)
```cj
public init(x: Float64, y: Float64, z: Float64, order: EulerOrder)
```


参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64||
|y|Float64||
|z|Float64||
|order|EulerOrder||

### func init\(Float64,Float64,Float64\)
```cj
public init(x: Float64, y: Float64, z: Float64)
```


参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64||
|y|Float64||
|z|Float64||

### func onChange\(\(\)\->Unit\)
```cj
public func onChange(callback:() -> Unit): Euler
```
设置变更回调函数，当欧拉角的值被修改时调用

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit|回调函数|

返回: 

- 当前实例

### func reorder\(EulerOrder\)
```cj
public func reorder(newOrder: EulerOrder): Euler
```
重置旋转顺序（通过四元数中转，会丢失旋转圈数信息）

参数: 

|名称|类型|描述|
|---|---|---|
|newOrder|EulerOrder|新的旋转顺序|

返回: 

- 当前实例

### func setFromQuaternion\(Quaternion\)
```cj
public func setFromQuaternion(q: Quaternion): Euler
```
从归一化四元数设置欧拉角

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|归一化的四元数|

返回: 

- 当前实例

### func setFromQuaternion\(Quaternion,EulerOrder\)
```cj
public func setFromQuaternion(q: Quaternion, order: EulerOrder): Euler
```
从归一化四元数设置欧拉角（指定旋转顺序）

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|归一化的四元数order 旋转顺序|
|order|EulerOrder||

返回: 

- 当前实例

### func setFromQuaternion\(Quaternion,EulerOrder,Bool\)
```cj
public func setFromQuaternion(q: Quaternion, order: EulerOrder, update: Bool): Euler
```
从归一化四元数设置欧拉角（指定旋转顺序和是否更新回调）

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|归一化的四元数order 旋转顺序update 是否触发变更回调|
|order|EulerOrder||
|update|Bool||

返回: 

- 当前实例

### func setFromRotationMatrix\(Matrix4\)
```cj
public func setFromRotationMatrix(m: Matrix4): Euler
```
从纯旋转矩阵设置欧拉角

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|4x4 矩阵|

返回: 

- 当前实例

### func setFromRotationMatrix\(Matrix4,EulerOrder\)
```cj
public func setFromRotationMatrix(m: Matrix4, order: EulerOrder): Euler
```
从纯旋转矩阵设置欧拉角（指定旋转顺序）

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|4x4 矩阵order 旋转顺序|
|order|EulerOrder||

返回: 

- 当前实例

### func setFromRotationMatrix\(Matrix4,EulerOrder,Bool\)
```cj
public func setFromRotationMatrix(m: Matrix4, order: EulerOrder, update: Bool): Euler
```
从纯旋转矩阵设置欧拉角（指定旋转顺序和是否更新回调）

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|4x4 矩阵order 旋转顺序update 是否触发变更回调|
|order|EulerOrder||
|update|Bool||

返回: 

- 当前实例

### func setFromVector3\(Vector3\)
```cj
public func setFromVector3(v: Vector3): Euler
```
从向量设置欧拉角

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|向量|

返回: 

- 当前实例

### func setFromVector3\(Vector3,EulerOrder\)
```cj
public func setFromVector3(v: Vector3, order: EulerOrder): Euler
```
从向量设置欧拉角（指定旋转顺序）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|向量order 旋转顺序|
|order|EulerOrder||

返回: 

- 当前实例

### func set\(Float64,Float64,Float64,EulerOrder\)
```cj
public func set(x: Float64, y: Float64, z: Float64, order: EulerOrder): Euler
```
设置欧拉角分量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 轴旋转角度（弧度）y y 轴旋转角度（弧度）z z 轴旋转角度（弧度）order 旋转顺序|
|y|Float64||
|z|Float64||
|order|EulerOrder||

返回: 

- 当前实例

### func set\(Float64,Float64,Float64\)
```cj
public func set(x: Float64, y: Float64, z: Float64): Euler
```
设置欧拉角分量（保持当前旋转顺序）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 轴旋转角度（弧度）y y 轴旋转角度（弧度）z z 轴旋转角度（弧度）|
|y|Float64||
|z|Float64||

返回: 

- 当前实例

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
将欧拉角分量写入数组

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|目标数组offset 起始索引，默认为 0|
|offset|Int64||

返回: 

- 包含分量值的数组

### prop order: EulerOrder
```cj
public mut prop order: EulerOrder
```
旋转顺序，赋值时触发 onChange 回调

### prop x: Float64
```cj
public mut prop x: Float64
```
x 轴旋转角度（弧度），赋值时触发 onChange 回调

### prop y: Float64
```cj
public mut prop y: Float64
```
y 轴旋转角度（弧度），赋值时触发 onChange 回调

### prop z: Float64
```cj
public mut prop z: Float64
```
z 轴旋转角度（弧度），赋值时触发 onChange 回调

### let DEFAULT\_ORDER
```cj
public static let DEFAULT_ORDER: EulerOrder = EulerOrder.XYZ
```
默认旋转顺序（static 成员，不参与序列化）

