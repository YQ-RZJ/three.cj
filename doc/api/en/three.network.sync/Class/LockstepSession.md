# Class
## class LockstepSession
```cj
public class LockstepSession
```
Lockstep session

### func addPlayer\(Int32\)
```cj
public func addPlayer(id: Int32): Bool
```
Adds a player

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int32|Player id|

Return: 

- True when newly added; false when already present

### func init\(Int32\)
```cj
public init(localPlayerId: Int32)
```
Constructs a lockstep session

Parameter: 

|Name|Type|Describe|
|---|---|---|
|localPlayerId|Int32|Local player id (auto-added to the player list)|

### func removePlayer\(Int32\)
```cj
public func removePlayer(id: Int32): Unit
```
Removes a player (its unconsumed inputs are dropped too)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int32|Player id|

### func reset\(\)
```cj
public func reset(): Unit
```
Resets session state (for restarting a match; player list is kept)

### func submitLocalInput\(Array<UInt8>\)
```cj
public func submitLocalInput(data: Array < UInt8 >): Unit
```
Submits local input (scheduled for confirmedTick + inputDelayTicks)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Input payload (PacketWriter recommended; resubmission for the sametick overwrites)|

### func submitRemoteInput\(Int32,Int64,Array<UInt8>\)
```cj
public func submitRemoteInput(playerId: Int32, tick: Int64, data: Array < UInt8 >): Bool
```
Submits a remote player's input (feed from the network layer)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|playerId|Int32|Player id (must be joined)tick The tick the input belongs todata Input payload|
|tick|Int64||
|data|Array<UInt8>||

Return: 

- True when accepted; false when the player is unknown

### func update\(Float64\)
```cj
public func update(dt: Float64): Unit
```
Per-frame main-loop driver: accumulates time and advances ticks on beat

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dt|Float64|Frame delta (seconds)|

### prop confirmedTick: Int64
```cj
public prop confirmedTick: Int64
```
Last confirmed tick (next target is confirmedTick + 1)

### prop localPlayerId: Int32
```cj
public prop localPlayerId: Int32
```
Local player id

### prop targetTick: Int64
```cj
public prop targetTick: Int64
```
Current target tick (the tick waiting for inputs)

### var inputDelayTicks
```cj
public var inputDelayTicks: Int64 = 2
```
Local input delay in ticks (default 2, transport window)

### var maxWaitMs
```cj
public var maxWaitMs: Float64 = 250.0
```
Timeout waiting for all inputs in ms (0 = wait forever, default 250)

### var onAdvance
```cj
public var onAdvance: Option <(Int64, Array < Int32 >, Array < Array < UInt8 >>) -> Unit >= None
```
Tick-advance callback (params: tick number, player ids, input payloads
aligned with the ids)

### var tickIntervalMs
```cj
public var tickIntervalMs: Float64 = 50.0
```
Logic tick interval in ms (default 50 = 20 tps)

