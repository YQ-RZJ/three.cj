# 类
## class SimplexNoise
```cj
public class SimplexNoise
```
Simplex 噪声（2D/3D/4D + Seamless2D）。

提供 noise2D / noise3D / noise4D / createSeamlessNoise2D 接口。

### func createSeamlessNoise2D\(Float64,Float64,Float64\)
```cj
public func createSeamlessNoise2D(x: Float64, y: Float64, diameter: Float64): Float64
```
2D 无缝噪声，在 diameter 范围内循环重复，实现无缝拼接。

算法：对输入坐标做 Python 风格取模（pyMod）映射到 [0, diameter)，
检测坐标是否处于边界（margin，即 (x+1) mod diameter < 1），
对于跨越边界的 simplex 单元，将梯度索引置为 -1（与偏移 +1 相加后归 0），
从而实现边界两侧梯度一致的无缝拼接。

与标准 noise2D 的差异：使用未斜切（un-skewed）的轴对齐网格单元
（i = floor(xin)），而非标准版的斜切网格（i = floor(x + s)），
因此噪声图案与 noise2D 不同，但支持无缝循环。

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 坐标|
|y|Float64|y 坐标|
|diameter|Float64|循环直径（噪声在此范围内无缝重复）|

返回: 

- 噪声值 [-1, 1]

### func init\(UInt64\)
```cj
public init(seed!: UInt64 = 987654321u64)
```
构造：用 Fisher-Yates 洗牌生成 512 项置换表，并预计算 permGrad 数组。

参数: 

|名称|类型|描述|
|---|---|---|
|seed|UInt64|伪随机种子（默认 987654321；同种子结果可复现）|

### func noise2D\(Float64,Float64\)
```cj
public func noise2D(x: Float64, y: Float64): Float64
```
2D Simplex 噪声，返回 [-1, 1]。

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64||
|y|Float64||

### func noise3d\(Float64,Float64,Float64\)
```cj
public func noise3d(xin: Float64, yin: Float64, zin: Float64): Float64
```
3D Simplex 噪声，返回 [-1, 1]。

参数: 

|名称|类型|描述|
|---|---|---|
|xin|Float64||
|yin|Float64||
|zin|Float64||

### func noise4d\(Float64,Float64,Float64,Float64\)
```cj
public func noise4d(x: Float64, y: Float64, z: Float64, w: Float64): Float64
```
4D Simplex 噪声，返回 [-1, 1]。

使用 rankx/ranky/rankz/rankw 排名方式确定 simplex 各角偏移
（替代旧 SIMPLEX 查找表 + 位编码方式）。

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64||
|y|Float64||
|z|Float64||
|w|Float64||

### func noise\(Float64,Float64\)
```cj
public func noise(xin: Float64, yin: Float64): Float64
```
2D Simplex 噪声（兼容旧接口 noise(xin, yin)）。

参数: 

|名称|类型|描述|
|---|---|---|
|xin|Float64||
|yin|Float64||

