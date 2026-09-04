# Class
## class Timer
```cj
public class Timer
```
High-performance timer class

### func dispose\(\)
```cj
public func dispose(): Unit
```
Release resources

### func getDelta\(\)
```cj
public func getDelta(): Float64
```
Get the time delta (in seconds)

Return: 

- Time delta since the last update() call (in seconds)

### func getElapsed\(\)
```cj
public func getElapsed(): Float64
```
Get the cumulative elapsed time (in seconds)

Return: 

- Cumulative time since the timer started (in seconds)

### func getTimescale\(\)
```cj
public func getTimescale(): Float64
```
Get the time scaling factor

Return: 

- Current time scaling factor

### func init\(\)
```cj
public init()
```
Construct a new timer

### func reset\(\)
```cj
public func reset(): Timer
```
Reset the timer, setting the current time to 0

Return: 

- Current timer instance (supports chaining)

### func setTimescale\(Float64\)
```cj
public func setTimescale(timescale: Float64): Timer
```
Set the time scaling factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timescale|Float64|Time scaling factor, 1.0 for normal speed|

Return: 

- Current timer instance (supports chaining)

### func start\(\)
```cj
public func start(): Unit
```
Start the timer (legacy compatibility)

### func stop\(\)
```cj
public func stop(): Unit
```
Stop the timer (legacy compatibility)

### func update\(Float64\)
```cj
public func update(timestamp!: Float64 = - 1.0): Timer
```
Update the timer's internal state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timestamp|Float64|Optional timestamp (in milliseconds); if not provided, current time is used|

Return: 

- Current timer instance (supports chaining)

### var fixedDelta
```cj
public var fixedDelta: Float64
```
Fixed time step value (in seconds)

### var useFixedDelta
```cj
public var useFixedDelta: Bool
```
Whether to use fixed time step

