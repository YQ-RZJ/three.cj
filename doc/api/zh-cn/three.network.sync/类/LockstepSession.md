# 类
## class LockstepSession
```cj
public class LockstepSession
```
lockstep 帧同步会话

### func addPlayer\(Int32\)
```cj
public func addPlayer(id: Int32): Bool
```
加入玩家

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int32|玩家 id|

返回: 

- 新加入返回 true；已存在返回 false

### func init\(Int32\)
```cj
public init(localPlayerId: Int32)
```
构造帧同步会话

参数: 

|名称|类型|描述|
|---|---|---|
|localPlayerId|Int32|本地玩家 id（自动加入玩家列表）|

### func removePlayer\(Int32\)
```cj
public func removePlayer(id: Int32): Unit
```
移除玩家（其未消费输入一并清除）

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int32|玩家 id|

### func reset\(\)
```cj
public func reset(): Unit
```
清空会话状态（重开一局时使用；玩家列表保留）

### func submitLocalInput\(Array<UInt8>\)
```cj
public func submitLocalInput(data: Array < UInt8 >): Unit
```
提交本地输入（调度到 confirmedTick + inputDelayTicks 生效）

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入载荷（建议 PacketWriter 编码；同 tick 重复提交覆盖）|

### func submitRemoteInput\(Int32,Int64,Array<UInt8>\)
```cj
public func submitRemoteInput(playerId: Int32, tick: Int64, data: Array < UInt8 >): Bool
```
提交远端玩家输入（网络层收到后喂入）

参数: 

|名称|类型|描述|
|---|---|---|
|playerId|Int32|玩家 id（须已加入会话）tick 输入对应的 tick 号data 输入载荷|
|tick|Int64||
|data|Array<UInt8>||

返回: 

- 接受返回 true；玩家不存在返回 false

### func update\(Float64\)
```cj
public func update(dt: Float64): Unit
```
主循环每帧驱动：累积时间并按节拍推进 tick

参数: 

|名称|类型|描述|
|---|---|---|
|dt|Float64|帧间隔（秒）|

### prop confirmedTick: Int64
```cj
public prop confirmedTick: Int64
```
已确认推进到的 tick（下一目标为 confirmedTick + 1）

### prop localPlayerId: Int32
```cj
public prop localPlayerId: Int32
```
本地玩家 id

### prop targetTick: Int64
```cj
public prop targetTick: Int64
```
当前目标 tick（等待输入中的 tick）

### var inputDelayTicks
```cj
public var inputDelayTicks: Int64 = 2
```
本地输入延迟 tick 数（默认 2，为传输留窗口）

### var maxWaitMs
```cj
public var maxWaitMs: Float64 = 250.0
```
等待全员输入的超时（毫秒；0 = 无限等待，默认 250）

### var onAdvance
```cj
public var onAdvance: Option <(Int64, Array < Int32 >, Array < Array < UInt8 >>) -> Unit >= None
```
tick 推进回调（参数：tick 号、玩家 id 序列、与 id 对齐的输入载荷）

### var tickIntervalMs
```cj
public var tickIntervalMs: Float64 = 50.0
```
逻辑 tick 间隔（毫秒，默认 50 = 20tps）

