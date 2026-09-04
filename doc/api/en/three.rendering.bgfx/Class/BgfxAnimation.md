# Class
## class BgfxAnimation
```cj
public class BgfxAnimation
```
bgfx animation manager

### func init\(\)
```cj
public init()
```


### func isRunning\(\)
```cj
public func isRunning(): Bool
```
Check if animation is running

Return: 

- Whether the animation is running

### func setCallback\(AnimationCallback\)
```cj
public func setCallback(cb: AnimationCallback): Unit
```
Set animation callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cb|AnimationCallback|Animation callback function|

### func start\(\)
```cj
public func start(): Unit
```
Start animation loop

### func stop\(\)
```cj
public func stop(): Unit
```
Stop animation loop

### func tick\(\)
```cj
public func tick(): Unit
```
Execute one animation frame

