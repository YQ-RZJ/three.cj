# Class
## class Event
```cj
public class Event
```
Event object passed to listeners when dispatching events

### func init\(String\)
```cj
public init(`type`: String)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String||

### var \`type\`
```cj
public var `type`: String
```
Event type

### var target
```cj
public var target:?EventDispatcher
```
Event target (the object dispatching the event), set automatically by dispatchEvent

