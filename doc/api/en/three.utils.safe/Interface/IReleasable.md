# Interface
## interface IReleasable
```cj
public interface IReleasable
```
IReleasable resource interface

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Implementation requirements:
1. release() must be idempotent — repeat calls return false and never free a
handle twice;
2. after release(), releasable must return false;
3. the release action must be safe to execute in a finalizer context
(no dependence on the calling thread).
Combined with Safe<T>, this yields "manual release + GC fallback" double safety.</p>

### func release\(\)
```cj
func release(): Bool
```
Releases the resource explicitly

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Implementations must be idempotent: repeated calls are safe and never
free the underlying handles twice</p>

Return: 

- true if this call actually released; false if already released (idempotent hit)

### prop releasable: Bool
```cj
prop releasable: Bool
```
Whether the resource is currently releasable (not released and still
holding underlying resources)

