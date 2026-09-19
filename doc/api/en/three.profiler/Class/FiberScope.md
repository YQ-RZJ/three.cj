# Class
## class FiberScope
```cj
public class FiberScope <: Resource
```
Fiber scope — wraps a fiber body; enter on construction,
leave on close (strictly paired).

### func close\(\)
```cj
public func close(): Unit
```
Leave the fiber (idempotent; auto-called by try-with-resources)

### func init\(String\)
```cj
public init(name: String)
```
Enter the fiber scope

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func isClosed\(\)
```cj
public func isClosed(): Bool
```
Resource.isClosed

