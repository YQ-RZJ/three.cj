# Struct
## struct TriggerEvent
```cj
public struct TriggerEvent
```
Trigger event

### func init\(Float32,Float32,Bool\)
```cj
public init(ratio: Float32, value: Float32, rising: Bool)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|ratio|Float32||
|value|Float32||
|rising|Bool||

### let ratio
```cj
public let ratio: Float32
```
Trigger time (0-1 ratio)

### let rising
```cj
public let rising: Bool
```
Trigger direction: true = rising crossing (bottom-up), false = falling crossing (top-down)

### let value
```cj
public let value: Float32
```
The value at trigger time

