# 类
## class Lock
```cj
public class Lock
```
锁竞争跟踪 — lockable/shared-lockable 上下文的登记与事件

### func afterLock\(CPointer<Unit>\)
```cj
public static func afterLock(lockdata: CPointer < Unit >): Unit
```
加锁成功后

参数: 

|名称|类型|描述|
|---|---|---|
|lockdata|CPointer<Unit>||

### func afterTryLock\(CPointer<Unit>,Bool\)
```cj
public static func afterTryLock(lockdata: CPointer < Unit >, acquired: Bool): Unit
```
try-lock 后（acquired = 是否成功）

参数: 

|名称|类型|描述|
|---|---|---|
|lockdata|CPointer<Unit>||
|acquired|Bool||

### func afterUnlock\(CPointer<Unit>\)
```cj
public static func afterUnlock(lockdata: CPointer < Unit >): Unit
```
解锁后

参数: 

|名称|类型|描述|
|---|---|---|
|lockdata|CPointer<Unit>||

### func announceShared\(String,String,UInt32,String\)
```cj
public static func announceShared(name: String, file: String, line: UInt32, function: String): CPointer < Unit >
```
登记读写锁跟踪上下文

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|file|String||
|line|UInt32||
|function|String||

### func announce\(String,String,UInt32,String\)
```cj
public static func announce(name: String, file: String, line: UInt32, function: String): CPointer < Unit >
```
登记互斥锁跟踪上下文（返回句柄，须保存）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|file|String||
|line|UInt32||
|function|String||

### func beforeLock\(CPointer<Unit>\)
```cj
public static func beforeLock(lockdata: CPointer < Unit >): Bool
```
加锁前（Tracy 语义转发：返回是否应继续）

参数: 

|名称|类型|描述|
|---|---|---|
|lockdata|CPointer<Unit>||

### func terminateShared\(CPointer<Unit>\)
```cj
public static func terminateShared(lockdata: CPointer < Unit >): Unit
```
注销读写锁跟踪上下文

参数: 

|名称|类型|描述|
|---|---|---|
|lockdata|CPointer<Unit>||

### func terminate\(CPointer<Unit>\)
```cj
public static func terminate(lockdata: CPointer < Unit >): Unit
```
注销互斥锁跟踪上下文

参数: 

|名称|类型|描述|
|---|---|---|
|lockdata|CPointer<Unit>||

