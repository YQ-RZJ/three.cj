# Class
## class InputSnapshot
```cj
public class InputSnapshot
```
Per-frame fixed window snapshot

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Only the window pump thread reads and writes it (the dispatcher only writes
the event queue), so no lock is needed.</p>

### func init\(\)
```cj
public init()
```
Constructs an empty snapshot

