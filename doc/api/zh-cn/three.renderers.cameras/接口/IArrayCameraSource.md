# 接口
## interface IArrayCameraSource
```cj
public interface IArrayCameraSource
```
数组相机只读接口：提供子相机投影/视图逆矩阵数据

### func getCameraCount\(\)
```cj
func getCameraCount(): Int64
```
获取子相机数量

返回: 

- 子相机数量

### func getCameraMatrixWorldInverseElements\(Int64\)
```cj
func getCameraMatrixWorldInverseElements(i: Int64): Array < Float64 >
```
获取第 i 个子相机的视图矩阵逆元素（16 个，列主序）

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64|子相机索引|

返回: 

- 视图矩阵逆元素数组

### func getCameraProjectionElements\(Int64\)
```cj
func getCameraProjectionElements(i: Int64): Array < Float64 >
```
获取第 i 个子相机的投影矩阵元素（16 个，列主序）

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64|子相机索引|

返回: 

- 投影矩阵元素数组

