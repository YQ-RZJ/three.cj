# Class
## class UiKeyboard
```cj
public class UiKeyboard
```
=============================================================================

### func getKeyName\(Int32\)
```cj
public static func getKeyName(key: Int32): String
```
Gets the key name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32||

### func getKeyPressedAmount\(Int32,Float32,Float32\)
```cj
public static func getKeyPressedAmount(key: Int32, repeatDelay: Float32, rate: Float32): Int32
```
Gets the press count of the given key

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32||
|repeatDelay|Float32||
|rate|Float32||

### func isKeyDown\(Int32\)
```cj
public static func isKeyDown(key: Int32): Bool
```
Whether the given key is down

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32||

### func isKeyPressed\(Int32,Bool\)
```cj
public static func isKeyPressed(key: Int32, repeat_!: Bool = true): Bool
```
Whether the given key was just pressed (including repeats)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32||
|repeat_|Bool||

### func isKeyReleased\(Int32\)
```cj
public static func isKeyReleased(key: Int32): Bool
```
Whether the given key was just released

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32||

