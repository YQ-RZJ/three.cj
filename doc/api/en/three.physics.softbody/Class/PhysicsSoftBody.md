# Class
## class PhysicsSoftBody
```cj
public class PhysicsSoftBody <: IReleasable
```
Runtime soft body

### func release\(\)
```cj
public func release(): Bool
```
disposes the soft body (removes from the world and releases the body)

### prop bodyID: UInt32
```cj
public prop bodyID: UInt32
```
The soft-body body ID

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Whether the soft body is valid (created successfully and not disposed)

