# Class
## class ScopeGuard
```cj
public class ScopeGuard
```
RAII scope guard

### func dismiss\(\)
```cj
public func dismiss(): Unit
```
Cancels the cleanup callback

### func dispose\(\)
```cj
public func dispose(): Unit
```
Runs the cleanup callback (if not dismissed)

### func init\(\(\)\->Unit\)
```cj
public init(callback:() -> Unit)
```
Constructs a ScopeGuard

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|The cleanup function to run on scope exit|

