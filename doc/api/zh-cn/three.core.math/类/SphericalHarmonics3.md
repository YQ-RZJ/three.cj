# 类
## class SphericalHarmonics3
```cj
public class SphericalHarmonics3
```
球面调和系数类，包含 9 个三阶系数向量

### func addScaledSH\(SphericalHarmonics3,Float64\)
```cj
public func addScaledSH(sh: SphericalHarmonics3, s: Float64): SphericalHarmonics3
```
添加缩放后的球面调和系数

参数: 

|名称|类型|描述|
|---|---|---|
|sh|SphericalHarmonics3|要添加的球面调和系数s 缩放因子|
|s|Float64||

返回: 

- 当前实例

### func add\(SphericalHarmonics3\)
```cj
public func add(sh: SphericalHarmonics3): SphericalHarmonics3
```
添加另一个球面调和系数

参数: 

|名称|类型|描述|
|---|---|---|
|sh|SphericalHarmonics3|要添加的球面调和系数|

返回: 

- 当前实例

### func clone\(\)
```cj
public func clone(): SphericalHarmonics3
```
克隆当前球面调和系数

返回: 

- 新的实例

### func copy\(SphericalHarmonics3\)
```cj
public func copy(sh: SphericalHarmonics3): SphericalHarmonics3
```
复制另一个球面调和系数的值

参数: 

|名称|类型|描述|
|---|---|---|
|sh|SphericalHarmonics3|源球面调和系数|

返回: 

- 当前实例

### func equals\(SphericalHarmonics3\)
```cj
public func equals(sh: SphericalHarmonics3): Bool
```
判断是否与另一个球面调和系数相等

参数: 

|名称|类型|描述|
|---|---|---|
|sh|SphericalHarmonics3|比较的球面调和系数|

返回: 

- 是否相等

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): SphericalHarmonics3
```
从数组读取系数

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|数组offset 偏移量|
|offset|Int64||

返回: 

- 当前实例

### func getAt\(Vector3\)
```cj
public func getAt(normal: Vector3): Vector3
```
获取给定法线方向的辐射度（创建新向量）

参数: 

|名称|类型|描述|
|---|---|---|
|normal|Vector3|法线向量（应为单位向量）|

返回: 

- 辐射度

### func getAt\(Vector3,Vector3\)
```cj
public func getAt(normal: Vector3, target: Vector3): Vector3
```
获取给定法线方向的辐射度

参数: 

|名称|类型|描述|
|---|---|---|
|normal|Vector3|法线向量（应为单位向量）target 目标向量|
|target|Vector3||

返回: 

- 辐射度

### func getBasisAt\(Vector3,Array<Float64>\)
```cj
public static func getBasisAt(normal: Vector3, shBasis: Array < Float64 >): Unit
```
静态方法：计算给定法线方向的球面调和基函数

参数: 

|名称|类型|描述|
|---|---|---|
|normal|Vector3|法线向量（应为单位向量）shBasis 目标数组，长度至少为 9|
|shBasis|Array<Float64>||

### func getIrradianceAt\(Vector3,Vector3\)
```cj
public func getIrradianceAt(normal: Vector3, target: Vector3): Vector3
```
获取给定法线方向的辐照度（辐射度与余弦波瓣的卷积）

参数: 

|名称|类型|描述|
|---|---|---|
|normal|Vector3|法线向量（应为单位向量）target 目标向量|
|target|Vector3||

返回: 

- 辐照度

### func getIrradianceAt\(Vector3\)
```cj
public func getIrradianceAt(normal: Vector3): Vector3
```
获取给定法线方向的辐照度（创建新向量）

参数: 

|名称|类型|描述|
|---|---|---|
|normal|Vector3|法线向量（应为单位向量）|

返回: 

- 辐照度

### func init\(\)
```cj
public init()
```


### func lerp\(SphericalHarmonics3,Float64\)
```cj
public func lerp(sh: SphericalHarmonics3, alpha: Float64): SphericalHarmonics3
```
在两个球面调和系数之间线性插值

参数: 

|名称|类型|描述|
|---|---|---|
|sh|SphericalHarmonics3|目标球面调和系数alpha 插值因子|
|alpha|Float64||

返回: 

- 当前实例

### func scale\(Float64\)
```cj
public func scale(s: Float64): SphericalHarmonics3
```
缩放球面调和系数

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|缩放因子|

返回: 

- 当前实例

### func set\(Array<Vector3>\)
```cj
public func set(coefficients: Array < Vector3 >): SphericalHarmonics3
```
设置球面调和系数

参数: 

|名称|类型|描述|
|---|---|---|
|coefficients|Array<Vector3>|系数数组|

返回: 

- 当前实例

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
将系数写入数组

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|目标数组offset 偏移量|
|offset|Int64||

返回: 

- 数组

### func zero\(\)
```cj
public func zero(): SphericalHarmonics3
```
将所有系数归零

返回: 

- 当前实例

### var coefficients
```cj
public var coefficients: Array < Vector3 >
```
球面调和系数数组，包含 9 个 Vector3

