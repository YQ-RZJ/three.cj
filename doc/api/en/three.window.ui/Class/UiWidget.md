# Class
## class UiWidget
```cj
public open class UiWidget
```
Base class for all ImGui widgets

### func draw\(\)
```cj
public open func draw(): Bool
```
Render the widget (override in subclasses)

Return: 

- Widget interaction result (click/value change etc.), meaning defined by subclass

### func getId\(\)
```cj
public func getId(): String
```
Returns the widget ID

### func init\(\)
```cj
public init()
```
Constructs a widget without an ID

### func init\(String\)
```cj
public init(id!: String)
```
Constructs a widget with an ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Widget ID (used for ImGui PushID/PopID namespace isolation)|

