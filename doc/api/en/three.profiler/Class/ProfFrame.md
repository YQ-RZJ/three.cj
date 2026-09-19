# Class
## class ProfFrame
```cj
public class ProfFrame
```
Frame marks — main/named frame boundaries

### func finish\(String\)
```cj
public static func finish(name: String): Unit
```
Finish a named frame stream

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func image\(CPointer<Unit>,UInt16,UInt16,UInt8,Bool\)
```cj
public static func image(image: CPointer < Unit >, width: UInt16, height: UInt16, offset: UInt8, flip: Bool): Unit
```
Send a frame image preview (thumbnail in the Tracy frame list)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|image|CPointer<Unit>||
|width|UInt16||
|height|UInt16||
|offset|UInt8||
|flip|Bool||

### func mark\(\)
```cj
public static func mark(): Unit
```
End-of-main-frame mark (once per main-loop iteration)

### func mark\(String\)
```cj
public static func mark(name: String): Unit
```
End-of-named-frame mark (independent frame stream, e.g.
"Render")

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func start\(String\)
```cj
public static func start(name: String): Unit
```
Start a named frame stream (paired with finish by name;
multiple streams may run in parallel)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

