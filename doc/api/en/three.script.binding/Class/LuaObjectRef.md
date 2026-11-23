# Class
## class LuaObjectRef
```cj
public class LuaObjectRef
```
Engine object reference (self in method/property callbacks)

### func cast\(\)
```cj
public func cast < T >(): T
```
Fetches the real object and casts it to T

Exception: 

- Exception Thrown when the type does not match or the object is missing

### func obj\(\)
```cj
public func obj(): Any
```
Fetches the real object (Any)

Return: 

- The Cangjie object stored in the registry

Exception: 

- Exception Thrown when the object has been removed

### prop id: Int64
```cj
public prop id: Int64
```
The object registry id

