# Class
## class Lock
```cj
public class Lock
```
Lock contention tracking — lockable/shared-lockable contexts

### func afterLock\(CPointer<Unit>\)
```cj
public static func afterLock(lockdata: CPointer < Unit >): Unit
```
After a successful lock

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lockdata|CPointer<Unit>||

### func afterTryLock\(CPointer<Unit>,Bool\)
```cj
public static func afterTryLock(lockdata: CPointer < Unit >, acquired: Bool): Unit
```
After try-lock (acquired = whether it succeeded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lockdata|CPointer<Unit>||
|acquired|Bool||

### func afterUnlock\(CPointer<Unit>\)
```cj
public static func afterUnlock(lockdata: CPointer < Unit >): Unit
```
After unlock

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lockdata|CPointer<Unit>||

### func announceShared\(String,String,UInt32,String\)
```cj
public static func announceShared(name: String, file: String, line: UInt32, function: String): CPointer < Unit >
```
Announce a shared-lockable tracking context

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|file|String||
|line|UInt32||
|function|String||

### func announce\(String,String,UInt32,String\)
```cj
public static func announce(name: String, file: String, line: UInt32, function: String): CPointer < Unit >
```
Announce a lockable tracking context (keep the returned handle)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|file|String||
|line|UInt32||
|function|String||

### func beforeLock\(CPointer<Unit>\)
```cj
public static func beforeLock(lockdata: CPointer < Unit >): Bool
```
Before lock (Tracy semantics forwarded: whether to proceed)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lockdata|CPointer<Unit>||

### func terminateShared\(CPointer<Unit>\)
```cj
public static func terminateShared(lockdata: CPointer < Unit >): Unit
```
Terminate a shared-lockable tracking context

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lockdata|CPointer<Unit>||

### func terminate\(CPointer<Unit>\)
```cj
public static func terminate(lockdata: CPointer < Unit >): Unit
```
Terminate a lockable tracking context

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lockdata|CPointer<Unit>||

