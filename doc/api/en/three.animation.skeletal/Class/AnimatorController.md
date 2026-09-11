# Class
## class AnimatorController
```cj
public class AnimatorController
```
Animator state machine controller

### func addParam\(AnimatorParam\)
```cj
public func addParam(param: AnimatorParam): Unit
```
Adds a parameter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|param|AnimatorParam||

### func addState\(AnimatorState\)
```cj
public func addState(state: AnimatorState): Unit
```
Adds an animation state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|state|AnimatorState||

### func addTransition\(AnimatorTransition\)
```cj
public func addTransition(transition: AnimatorTransition): Unit
```
Adds a state transition

Parameter: 

|Name|Type|Describe|
|---|---|---|
|transition|AnimatorTransition||

### func getCurrentStateName\(\)
```cj
public func getCurrentStateName(): String
```
Gets the current state name

### func getCurrentState\(\)
```cj
public func getCurrentState(): Option < AnimatorState >
```
Gets the current state

### func getTransitionSource\(\)
```cj
public func getTransitionSource(): String
```
Gets the transition source state (valid while transitioning)

### func getTransitionTarget\(\)
```cj
public func getTransitionTarget(): String
```
Gets the transition target state (valid while transitioning)

### func getTransitionWeight\(\)
```cj
public func getTransitionWeight(): Float32
```
Gets the transition blend weight ([0,1] while transitioning, 1.0 otherwise)

### func init\(\)
```cj
public init()
```


### func isTransitioning\(\)
```cj
public func isTransitioning(): Bool
```
Whether a transition is in progress

### func setBool\(String,Bool\)
```cj
public func setBool(name: String, value: Bool): Unit
```
Sets a bool parameter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|value|Bool||

### func setDefaultState\(String\)
```cj
public func setDefaultState(stateName: String): Unit
```
Sets the default state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stateName|String||

### func setFloat\(String,Float32\)
```cj
public func setFloat(name: String, value: Float32): Unit
```
Sets a float parameter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|value|Float32||

### func setInt\(String,Int\)
```cj
public func setInt(name: String, value: Int): Unit
```
Sets an int parameter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|value|Int||

### func setTrigger\(String\)
```cj
public func setTrigger(name: String): Unit
```
Triggers a trigger parameter (consumed and auto-reset on the next frame)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func update\(Float32\)
```cj
public func update(deltaTime: Float32): Unit
```
Updates the state machine

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float32|Frame interval in seconds|

### var currentStateName
```cj
public var currentStateName: String
```
Current state name (for serialization)

### var params
```cj
public var params: HashMap < String, AnimatorParam >
```
Parameter list (for serialization)

### var states
```cj
public var states: HashMap < String, AnimatorState >
```
State list (for serialization)

### var transitions
```cj
public var transitions: ArrayList < AnimatorTransition >
```
Transition list (for serialization)

