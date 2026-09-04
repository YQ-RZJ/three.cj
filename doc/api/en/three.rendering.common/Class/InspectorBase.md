# Class
## class InspectorBase
```cj
public open class InspectorBase
```
Debug inspector base class

### func hide\(\)
```cj
public func hide(): Unit
```
Hides the inspector

### func init\(\)
```cj
public init()
```
Constructs a default inspector (disabled state)

### func show\(\)
```cj
public func show(): Unit
```
Shows the inspector

### func update\(\)
```cj
public func update(): Unit
```
Updates the inspector (override in subclasses)

### var enabled
```cj
public var enabled: Bool
```
Whether the inspector is enabled

