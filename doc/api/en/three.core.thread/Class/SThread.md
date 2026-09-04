# Class
## class SThread < T >
```cj
public open class SThread < T >
```
System thread class

### func detach\(\)
```cj
public open func detach(): Unit
```
Detach thread (automatically reclaim resources)

### func getId\(\)
```cj
public open func getId(): UInt64
```
Get thread ID (thread ID)

Return: 

- Thread ID

### func get\(\)
```cj
public open func get(): T
```
Blocking get thread execution result

Return: 

- Thread execution result

### func get\(Int32\)
```cj
public open func get(timeoutMS: Int32): T
```
Get thread execution result with timeout

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timeoutMS|Int32|Maximum wait time in milliseconds|

Return: 

- Thread result; throws TimeoutException on timeout

### func init\(\(\)\->T\)
```cj
public init(callback:() -> T)
```
Constructor: create a system thread

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->T|Thread callback function|

### func init\(\(\)\->T,String,Int64\)
```cj
public init(callback:() -> T, name: String, stackSizeBytes: Int64)
```
Constructor (with thread name and stack size)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->T|Thread callback function|
|name|String|Thread name|
|stackSizeBytes|Int64|Thread stack size in bytes|

### func init\(\(\)\->T,String,Int64,ThreadPriority\)
```cj
public init(callback:() -> T, name: String, stackSizeBytes: Int64, priority: ThreadPriority)
```
Constructor (with thread name, stack size and priority)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->T|Thread callback function|
|name|String|Thread name|
|stackSizeBytes|Int64|Thread stack size in bytes|
|priority|ThreadPriority|Thread priority|

### func join\(\)
```cj
public open func join(): Unit
```
Wait for thread to finish (blocking)

### func tryGet\(\)
```cj
public open func tryGet(): Option < T >
```
Try to get thread execution result (returns None if thread has not finished)

Return: 

- Thread result, or None

