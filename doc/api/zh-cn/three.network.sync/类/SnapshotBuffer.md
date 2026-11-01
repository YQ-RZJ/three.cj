# 类
## class SnapshotBuffer
```cj
public class SnapshotBuffer
```
快照缓冲（时间序列 + 线性插值）

### func addSnapshot\(Float64,Array<Float32>\)
```cj
public func addSnapshot(timeMs: Float64, values: Array < Float32 >): Unit
```
追加快照

参数: 

|名称|类型|描述|
|---|---|---|
|timeMs|Float64|服务器时间戳（毫秒，须不小于上一快照时间）values 状态向量（长度须与既有快照一致）|
|values|Array<Float32>||

### func clear\(\)
```cj
public func clear(): Unit
```
清空全部快照

### func init\(Float64\)
```cj
public init(historyMs!: Float64 = 1000.0)
```
构造快照缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|historyMs|Float64|历史保留时长（毫秒，默认 1000）|

### func sample\(Float64,Array<Float32>\)
```cj
public func sample(timeMs: Float64, out: Array < Float32 >): Bool
```
在相邻快照间线性插值采样

参数: 

|名称|类型|描述|
|---|---|---|
|timeMs|Float64|采样时刻（毫秒；建议 = 服务器时间 - 插值延迟）out 输出向量（长度须等于快照分量数，结果写入此数组）|
|out|Array<Float32>||

返回: 

- 采样成功返回 true；快照不足/时刻越界/长度不符返回 false

### prop components: Int64
```cj
public prop components: Int64
```
每快照分量数（无快照时为 0）

### prop count: Int64
```cj
public prop count: Int64
```
当前快照数量

### prop newestTimeMs: Option < Float64 >
```cj
public prop newestTimeMs: Option < Float64 >
```
最晚快照时间（毫秒；无快照返回 None）

### prop oldestTimeMs: Option < Float64 >
```cj
public prop oldestTimeMs: Option < Float64 >
```
最早快照时间（毫秒；无快照返回 None）

