# Class
## class EventRecord
```cj
public class EventRecord
```
Event record (listener handle)

### func init\(\)
```cj
public init()
```
Default constructor

### var callback
```cj
public var callback:(Array < Object >) -> Unit
```
Callback function

### var id
```cj
public var id: Int64
```
Unique ID

### var name
```cj
public var name: String
```
Event name

### var once
```cj
public var once: Bool
```
Whether it triggers only once

### var target
```cj
public var target:?Object
```
Target object (used to filter dispatching)

