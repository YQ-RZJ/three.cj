# 类
## class AnimatorController
```cj
public class AnimatorController
```
动画状态机控制器

### func addParam\(AnimatorParam\)
```cj
public func addParam(param: AnimatorParam): Unit
```
添加参数

参数: 

|名称|类型|描述|
|---|---|---|
|param|AnimatorParam||

### func addState\(AnimatorState\)
```cj
public func addState(state: AnimatorState): Unit
```
添加动画状态

参数: 

|名称|类型|描述|
|---|---|---|
|state|AnimatorState||

### func addTransition\(AnimatorTransition\)
```cj
public func addTransition(transition: AnimatorTransition): Unit
```
添加状态过渡

参数: 

|名称|类型|描述|
|---|---|---|
|transition|AnimatorTransition||

### func getCurrentStateName\(\)
```cj
public func getCurrentStateName(): String
```
获取当前状态名称

### func getCurrentState\(\)
```cj
public func getCurrentState(): Option < AnimatorState >
```
获取当前状态

### func getTransitionSource\(\)
```cj
public func getTransitionSource(): String
```
获取过渡源状态（过渡中时有效）

### func getTransitionTarget\(\)
```cj
public func getTransitionTarget(): String
```
获取过渡目标状态（过渡中时有效）

### func getTransitionWeight\(\)
```cj
public func getTransitionWeight(): Float32
```
获取过渡混合权重（过渡中时 [0,1]，非过渡时返回 1.0）

### func init\(\)
```cj
public init()
```


### func isTransitioning\(\)
```cj
public func isTransitioning(): Bool
```
是否正在过渡中

### func setBool\(String,Bool\)
```cj
public func setBool(name: String, value: Bool): Unit
```
设置 bool 参数

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|value|Bool||

### func setDefaultState\(String\)
```cj
public func setDefaultState(stateName: String): Unit
```
设置初始状态

参数: 

|名称|类型|描述|
|---|---|---|
|stateName|String||

### func setFloat\(String,Float32\)
```cj
public func setFloat(name: String, value: Float32): Unit
```
设置 float 参数

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|value|Float32||

### func setInt\(String,Int\)
```cj
public func setInt(name: String, value: Int): Unit
```
设置 int 参数

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|value|Int||

### func setTrigger\(String\)
```cj
public func setTrigger(name: String): Unit
```
触发 trigger 参数（设置后自动在下一帧消费后重置）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func update\(Float32\)
```cj
public func update(deltaTime: Float32): Unit
```
更新状态机

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float32|帧间隔时间（秒）|

### var currentStateName
```cj
public var currentStateName: String
```
当前状态名称（序列化用）

### var params
```cj
public var params: HashMap < String, AnimatorParam >
```
参数列表（序列化用）

### var states
```cj
public var states: HashMap < String, AnimatorState >
```
状态列表（序列化用）

### var transitions
```cj
public var transitions: ArrayList < AnimatorTransition >
```
过渡列表（序列化用）

