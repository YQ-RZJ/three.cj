# Class
## class InputProvider
```cj
public open class InputProvider
```
Abstract base class for input providers

### func \`init\`\(\)
```cj
public open func `init`(): Unit
```
Initializes the provider (called after binding to window)

### func beginFrame\(\)
```cj
public open func beginFrame(): Unit
```
Frame begin: poll device state (e.g. gamepad) + prepare to receive events

### func endFrame\(\)
```cj
public open func endFrame(): Unit
```
Frame end: reset edge states (e.g. pressed/released) and accumulated values (e.g. motion/wheel)

### func getWindow\(\)
```cj
public func getWindow(): Option < WindowEngine >
```
Gets the bound window engine

Return: 

- The bound window engine, or None if not bound

### func isBound\(\)
```cj
public func isBound(): Bool
```
Whether a window is bound

### func onEvent\(DispatchEvent\)
```cj
public open func onEvent(evt: DispatchEvent): Unit
```
Processes a dispatched event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|DispatchEvent|The lightweight event dispatched by the dispatcher|

### func shutdown\(\)
```cj
public open func shutdown(): Unit
```
Cleans up resources (called when window closes)

