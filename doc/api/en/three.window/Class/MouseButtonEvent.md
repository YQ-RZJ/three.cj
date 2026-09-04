# Class
## class MouseButtonEvent
```cj
public class MouseButtonEvent
```
Mouse button event

### func init\(UInt8,Bool,UInt8,Float32,Float32\)
```cj
public init(button!: UInt8, down!: Bool, clicks!: UInt8, x!: Float32, y!: Float32)
```
Constructs a mouse button event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|UInt8|Mouse button index (SDL_BUTTON_LEFT=1 / RIGHT=3 / MIDDLE=2)down Whether the button is downclicks Click count (1 = single, 2 = double)x X position relative to the windowy Y position relative to the window|
|down|Bool||
|clicks|UInt8||
|x|Float32||
|y|Float32||

### var button
```cj
public var button: UInt8 = 0
```
Mouse button index (SDL_BUTTON_LEFT=1 / RIGHT=3 / MIDDLE=2)

### var clicks
```cj
public var clicks: UInt8 = 0
```
Click count (1 = single, 2 = double)

### var down
```cj
public var down: Bool = false
```
Whether the button is down

### var x
```cj
public var x: Float32 = 0.0
```
X position relative to the window

### var y
```cj
public var y: Float32 = 0.0
```
Y position relative to the window

