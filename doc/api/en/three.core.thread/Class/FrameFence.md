# Class
## class FrameFence
```cj
public class FrameFence
```
Frame fence: the submitter remembers a sequence, the consumer advances
the done sequence, and waiters block until their sequence

### func advanceBy\(Int64\)
```cj
public func advanceBy(n: Int64): Unit
```
Mark a batch of commands done: advance the done sequence and wake all waiters

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n|Int64|Number of commands executed in this batch (no-op when <= 0)|

### func advance\(\)
```cj
public func advance(): Unit
```
Mark one command done (convenience for advanceBy(1))

### func broadcastAll\(\)
```cj
public func broadcastAll(): Unit
```
Wake all waiters without advancing the sequence

### func done\(\)
```cj
public func done(): Int64
```
Current done sequence (total executed commands)

Return: 

- Done sequence

### func init\(\)
```cj
public init()
```
Constructor

### func submit\(\)
```cj
public func submit(): Int64
```
Submit one command and return its completion sequence (monotonic from 1)

Return: 

- New submit sequence, to be passed to waitUntil later

### func submitted\(\)
```cj
public func submitted(): Int64
```
Current submit sequence (total submitted commands)

Return: 

- Submit sequence

### func waitUntil\(Int64\)
```cj
public func waitUntil(seq: Int64): Unit
```
Block until the done sequence is >= seq

Parameter: 

|Name|Type|Describe|
|---|---|---|
|seq|Int64|Submit sequence to wait for|

