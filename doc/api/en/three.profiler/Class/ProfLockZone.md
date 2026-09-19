# Class
## class ProfLockZone
```cj
public class ProfLockZone <: Resource
```
Lock-tracking scope — announces a lockable context and reports
unlock on exit. Scope-lock semantics: enter = held, close = afterUnlock.

### func close\(\)
```cj
public func close(): Unit
```
Release (emits afterUnlock; idempotent; auto-called by
try-with-resources)

### func init\(String,String,UInt32\)
```cj
public init(name: String, file: String, line: UInt32)
```
Announce and enter the lock scope (beforeLock + afterLock)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|file|String||
|line|UInt32||

### func isClosed\(\)
```cj
public func isClosed(): Bool
```
Resource.isClosed

