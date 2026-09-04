# Class
## class XRManager
```cj
public open class XRManager
```
XR Manager class

### func getSession\(\)
```cj
public func getSession(): String
```
Get current XR session

Return: 

- Session identifier

### func init\(\)
```cj
public init()
```
Constructor, XR disabled by default

### func isPresenting\(\)
```cj
public func isPresenting(): Bool
```
Check whether XR is currently presenting

Return: 

- Whether currently presenting

### func setSession\(String\)
```cj
public func setSession(session: String): Unit
```
Set XR session

Parameter: 

|Name|Type|Describe|
|---|---|---|
|session|String|Session identifier|

### var enabled
```cj
public var enabled: Bool
```
Whether XR is enabled

