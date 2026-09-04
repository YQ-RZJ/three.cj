# 类
## class IdAllocator
```cj
public class IdAllocator
```
ID 分配器

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>起始 ID 在构造时指定（默认 0）；不是线程安全的，多线程场景需外部加锁。</p>

### func allocate\(\)
```cj
public func allocate(): Int64
```
分配一个新 ID（优先复用已回收的 ID）

返回: 

- 新分配的 ID

### func freeCount\(\)
```cj
public func freeCount(): Int64
```
当前空闲 ID 数量

返回: 

- 空闲 ID 数量

### func init\(Int64\)
```cj
public init(startId!: Int64 = 0)
```
构造分配器

参数: 

|名称|类型|描述|
|---|---|---|
|startId|Int64|起始 ID（默认 0）|

### func release\(Int64\)
```cj
public func release(id: Int64): Unit
```
回收 ID，供后续复用

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|待回收的 ID|

### func reset\(\)
```cj
public func reset(): Unit
```
重置分配器（清空空闲池，重置起始计数）

