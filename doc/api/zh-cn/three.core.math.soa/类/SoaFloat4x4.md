# 类
## class SoaFloat4x4
```cj
public class SoaFloat4x4
```
SoA 4x4 矩阵结构体，存储 4 个矩阵

### func fromTransform\(SoaTransform\)
```cj
public static func fromTransform(transform: SoaTransform): SoaFloat4x4
```
从 SoaTransform 构建 4 个模型空间 4x4 矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|transform|SoaTransform|SoA 格式的变换|

返回: 

- 包含 4 个模型空间矩阵的 SoaFloat4x4

### func getColumn0\(Int\)
```cj
public func getColumn0(matrix: Int): Vector3F
```
获取指定矩阵的第0列（前3个分量）

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Int|矩阵索引 (0-3)|

返回: 

- (m[0], m[1], m[2])

### func getColumn1\(Int\)
```cj
public func getColumn1(matrix: Int): Vector3F
```
获取指定矩阵的第1列（第4-6个分量）

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Int|矩阵索引 (0-3)|

返回: 

- Vector3F

### func getColumn2\(Int\)
```cj
public func getColumn2(matrix: Int): Vector3F
```
获取指定矩阵的第2列（第8-10个分量）

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Int|矩阵索引 (0-3)|

返回: 

- Vector3F

### func getTranslation\(Int\)
```cj
public func getTranslation(matrix: Int): Vector3F
```
获取指定矩阵的平移分量（第3列前3个元素）

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Int|矩阵索引 (0-3)|

返回: 

- Vector3F

### func get\(Int,Int\)
```cj
public func get(matrix: Int, element: Int): Float32
```
获取指定矩阵的指定元素

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Int|矩阵索引 (0-3)|
|element|Int|元素索引 (0-15, 列主序)|

### func init\(\)
```cj
public init()
```
默认构造函数，初始化为 4 个单位矩阵

### func init\(Array<Float32>\)
```cj
public init(data: Array < Float32 >)
```
从原始数组构造

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<Float32>|64 个元素的数组（4 个矩阵 × 16 分量）|

### func set\(Int,Int,Float32\)
```cj
public func set(matrix: Int, element: Int, value: Float32): Unit
```
设置指定矩阵的指定元素

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Int|矩阵索引 (0-3)|
|element|Int|元素索引 (0-15)|
|value|Float32|值|

### var m
```cj
public var m: Array < Float32 >
```
4 个矩阵的分量，每个矩阵 16 个 Float32（列主序）

