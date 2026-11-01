# 类
## class FrameFence
```cj
public class FrameFence
```
帧栅栏：提交者记忆序号，消费者推进完成序号，等待者按序号等待

### func advanceBy\(Int64\)
```cj
public func advanceBy(n: Int64): Unit
```
完成一批命令：推进完成序号并唤醒所有等待者

参数: 

|名称|类型|描述|
|---|---|---|
|n|Int64|本批执行完成的命令数（≤0 时直接返回）|

### func advance\(\)
```cj
public func advance(): Unit
```
完成一条命令（advanceBy(1) 的便捷封装）

### func broadcastAll\(\)
```cj
public func broadcastAll(): Unit
```
仅唤醒所有等待者（不推进序号）

### func done\(\)
```cj
public func done(): Int64
```
当前完成序号（已执行命令总数）

返回: 

- 完成序号

### func init\(\)
```cj
public init()
```
构造器

### func submit\(\)
```cj
public func submit(): Int64
```
提交一条命令，返回其完成序号（从 1 开始单调递增）

返回: 

- 新提交序号，供后续 waitUntil 使用

### func submitted\(\)
```cj
public func submitted(): Int64
```
当前提交序号（已提交命令总数）

返回: 

- 提交序号

### func waitUntil\(Int64\)
```cj
public func waitUntil(seq: Int64): Unit
```
等待完成序号 ≥ seq

参数: 

|名称|类型|描述|
|---|---|---|
|seq|Int64|待等待的提交序号|

