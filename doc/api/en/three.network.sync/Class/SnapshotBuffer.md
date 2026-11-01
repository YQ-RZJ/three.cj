# Class
## class SnapshotBuffer
```cj
public class SnapshotBuffer
```
Snapshot buffer (time series + linear interpolation)

### func addSnapshot\(Float64,Array<Float32>\)
```cj
public func addSnapshot(timeMs: Float64, values: Array < Float32 >): Unit
```
Appends a snapshot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timeMs|Float64|Server timestamp in ms (must be ≥ the previous snapshot time)values State vector (length must match existing snapshots)|
|values|Array<Float32>||

### func clear\(\)
```cj
public func clear(): Unit
```
Clears all snapshots

### func init\(Float64\)
```cj
public init(historyMs!: Float64 = 1000.0)
```
Constructs a snapshot buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|historyMs|Float64|History retention in ms (default 1000)|

### func sample\(Float64,Array<Float32>\)
```cj
public func sample(timeMs: Float64, out: Array < Float32 >): Bool
```
Linearly interpolates between adjacent snapshots

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timeMs|Float64|Sample time in ms (recommended: server time - interpolation delay)out Output vector (length must equal the snapshot component count)|
|out|Array<Float32>||

Return: 

- True on success; false when snapshots are insufficient, the time is outof range, or the length mismatches

### prop components: Int64
```cj
public prop components: Int64
```
Component count per snapshot (0 when empty)

### prop count: Int64
```cj
public prop count: Int64
```
Current snapshot count

### prop newestTimeMs: Option < Float64 >
```cj
public prop newestTimeMs: Option < Float64 >
```
Newest snapshot time in ms (None when empty)

### prop oldestTimeMs: Option < Float64 >
```cj
public prop oldestTimeMs: Option < Float64 >
```
Oldest snapshot time in ms (None when empty)

