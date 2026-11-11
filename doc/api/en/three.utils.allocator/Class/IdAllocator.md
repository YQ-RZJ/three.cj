# Class
## class IdAllocator
```cj
public class IdAllocator <: IReleasable
```
ID allocator

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The start ID is given at construction (default 0); internally a ReentrantMutex
serializes allocate/release/release() (reset)/freeCount, so the allocator is thread-safe
and shareable across threads (e.g. static _idGen/_idAlloc hit from arbitrary user threads).</p>

### func allocate\(\)
```cj
public func allocate(): Int64
```
Allocates a new ID (reuses a recycled one first)

Return: 

- The newly allocated ID

### func freeCount\(\)
```cj
public func freeCount(): Int64
```
Number of currently free (recycled) IDs

Return: 

- The number of free IDs

### func init\(Int64\)
```cj
public init(startId!: Int64 = 0)
```
Constructs an allocator

Parameter: 

|Name|Type|Describe|
|---|---|---|
|startId|Int64|The start ID (default 0)|

### func release\(Int64\)
```cj
public func release(id: Int64): Unit
```
Recycles an ID for later reuse

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|The ID to recycle|

### func release\(\)
```cj
public func release(): Bool
```
resets the allocator (clears the free
pool and resets the counter)

