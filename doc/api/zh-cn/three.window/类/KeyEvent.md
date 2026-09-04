# 类
## class KeyEvent
```cj
public class KeyEvent
```
键盘事件

### func init\(UInt32,UInt32,UInt16,Bool,Bool\)
```cj
public init(scancode!: UInt32, key!: UInt32, mod!: UInt16, down!: Bool, repeat!: Bool)
```
构造键盘事件

参数: 

|名称|类型|描述|
|---|---|---|
|scancode|UInt32|SDL 物理键码（SDL_SCANCODE_*）key SDL 虚拟键码mod 修饰键掩码（SDL_KMOD_*）down 是否按下repeat 是否重复触发|
|key|UInt32||
|mod|UInt16||
|down|Bool||
|repeat|Bool||

### var down
```cj
public var down: Bool = false
```
是否按下

### var key
```cj
public var key: UInt32 = 0
```
SDL 虚拟键码

### var mod
```cj
public var mod: UInt16 = 0
```
修饰键掩码（SDL_KMOD_*）

### var repeat
```cj
public var repeat: Bool = false
```
是否重复触发

### var scancode
```cj
public var scancode: UInt32 = 0
```
SDL 物理键码（SDL_SCANCODE_*）

