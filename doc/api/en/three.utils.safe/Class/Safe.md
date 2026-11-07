# Class
## class Safe < T > where T <: IReleasable
```cj
public class Safe < T > <: IReleasable where T <: IReleasable
```
Safe ownership wrapper for a IReleasable object

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>This class is deliberately non-open (Cangjie constraint: classes with
finalizers cannot be open); to extend via inheritance, subclass the wrapped
resource class, not this wrapper.</p>

### func init\(T\)
```cj
public init(obj: T)
```
Creates the wrapper and takes over obj's release responsibility

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|T|The IReleasable resource object to wrap (its release is now owned by this wrapper)|

### func release\(\)
```cj
public func release(): Bool
```
Releases the wrapped resource explicitly (idempotent)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>After an explicit release the finalizer fallback will not run again;
do not use the resource via value afterwards (check releasable).</p>

Return: 

- true if this call actually released; false if already released(manually or by the fallback)

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Whether the wrapped resource is currently releasable

### let value
```cj
public let value: T
```
The wrapped resource object instance

