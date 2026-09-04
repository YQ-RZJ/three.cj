# Interface
## interface IPoolObject
```cj
public interface IPoolObject
```
Pooled-object lifecycle interface

### func construct\(\)
```cj
func construct(): Unit
```
Construct callback (invoked before an object is reused)

### func destruct\(\)
```cj
func destruct(): Unit
```
Destruct callback (invoked when an object is recycled)

