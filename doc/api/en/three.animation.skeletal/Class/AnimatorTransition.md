# Class
## class AnimatorTransition
```cj
public class AnimatorTransition
```
State transition definition

### func addCondition\(String,ConditionMode,Float32\)
```cj
public func addCondition(paramName: String, mode: ConditionMode, threshold!: Float32 = 0.0f32): Unit
```
Adds a transition condition

Parameter: 

|Name|Type|Describe|
|---|---|---|
|paramName|String||
|mode|ConditionMode||
|threshold|Float32||

### func init\(\)
```cj
public init()
```


### func init\(String,String,Float32,Float32\)
```cj
public init(fromState: String, toState: String, blendDuration!: Float32 = 0.25f32, exitTime!: Float32 = 0.0f32)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|fromState|String||
|toState|String||
|blendDuration|Float32||
|exitTime|Float32||

### var blendDuration
```cj
public var blendDuration: Float32
```


### var conditions
```cj
public var conditions: ArrayList < TransitionCondition >
```


### var exitTime
```cj
public var exitTime: Float32
```


### var fromState
```cj
public var fromState: String
```


### var toState
```cj
public var toState: String
```


