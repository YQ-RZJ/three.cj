# 结构体
## struct TriggerEvent
```cj
public struct TriggerEvent
```
触发事件

### func init\(Float32,Float32,Bool\)
```cj
public init(ratio: Float32, value: Float32, rising: Bool)
```


参数: 

|名称|类型|描述|
|---|---|---|
|ratio|Float32||
|value|Float32||
|rising|Bool||

### let ratio
```cj
public let ratio: Float32
```
触发时间（0-1 ratio）

### let rising
```cj
public let rising: Bool
```
触发方向：true = 从下到上穿越，false = 从上到下穿越

### let value
```cj
public let value: Float32
```
触发时的值

