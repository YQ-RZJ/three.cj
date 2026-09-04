# Class
## class Clock
```cj
public class Clock
```
Clock class for tracking time

### func getDelta\(\)
```cj
public func getDelta(): Float64
```
Get the time delta since the last call to getDelta() (in seconds)

Return: 

- Time delta (in seconds)

### func getElapsedTime\(\)
```cj
public func getElapsedTime(): Float64
```
Get the total elapsed time since the clock started (in seconds)

Return: 

- Total elapsed time (in seconds)

### func init\(Bool\)
```cj
public init(autoStart!: Bool = true)
```
Construct a new clock

Parameter: 

|Name|Type|Describe|
|---|---|---|
|autoStart|Bool|Whether to automatically start on the first call to getDelta(), defaults to true|

### func start\(\)
```cj
public func start(): Unit
```
Start the clock

### func stop\(\)
```cj
public func stop(): Unit
```
Stop the clock

### var autoStart
```cj
public var autoStart: Bool
```
Whether to automatically start the clock on the first call to getDelta()

