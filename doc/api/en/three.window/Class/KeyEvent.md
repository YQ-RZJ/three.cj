# Class
## class KeyEvent
```cj
public class KeyEvent
```
Keyboard event

### func init\(UInt32,UInt32,UInt16,Bool,Bool\)
```cj
public init(scancode!: UInt32, key!: UInt32, mod!: UInt16, down!: Bool, repeat!: Bool)
```
Constructs a keyboard event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scancode|UInt32|SDL physical key code (SDL_SCANCODE_*)key SDL virtual key codemod Modifier key mask (SDL_KMOD_*)down Whether the key is downrepeat Whether the event is a repeat|
|key|UInt32||
|mod|UInt16||
|down|Bool||
|repeat|Bool||

### var down
```cj
public var down: Bool = false
```
Whether the key is down

### var key
```cj
public var key: UInt32 = 0
```
SDL virtual key code

### var mod
```cj
public var mod: UInt16 = 0
```
Modifier key mask (SDL_KMOD_*)

### var repeat
```cj
public var repeat: Bool = false
```
Whether the event is a repeat

### var scancode
```cj
public var scancode: UInt32 = 0
```
SDL physical key code (SDL_SCANCODE_*)

