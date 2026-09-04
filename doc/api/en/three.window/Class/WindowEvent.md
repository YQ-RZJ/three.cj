# Class
## class WindowEvent
```cj
public class WindowEvent
```
Window event

### func init\(UInt32,Int32,Int32\)
```cj
public init(`type`!: UInt32, data1!: Int32, data2!: Int32)
```
Constructs a window event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|UInt32|Window event type (SDL_EVENT_WINDOW_*)data1 Event data 1 (e.g. width for resize)data2 Event data 2 (e.g. height for resize)|
|data1|Int32||
|data2|Int32||

### var \`type\`
```cj
public var `type`: UInt32 = 0
```
Window event type (SDL_EVENT_WINDOW_*)

### var data1
```cj
public var data1: Int32 = 0
```
Event data 1 (e.g. width for resize)

### var data2
```cj
public var data2: Int32 = 0
```
Event data 2 (e.g. height for resize)

