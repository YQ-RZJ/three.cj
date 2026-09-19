# Class
## class UiKeyboard
```cj
public class UiKeyboard
```
Keyboard state query utility class (static methods wrapping ImGui keyboard query APIs)

### func getKeyName\(Int32\)
```cj
public static func getKeyName(key: Int32): String
```
Gets the key name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32|Key code (ImGuiKey)|

Return: 

- The name string of the key

### func getKeyPressedAmount\(Int32,Float32,Float32\)
```cj
public static func getKeyPressedAmount(key: Int32, repeatDelay: Float32, rate: Float32): Int32
```
Gets the press count of the given key (affected by hold-repeat)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32|Key code (ImGuiKey)|
|repeatDelay|Float32|Delay before repeat triggers|
|rate|Float32|Repeat trigger rate|

Return: 

- Press count of the key

### func isKeyDown\(Int32\)
```cj
public static func isKeyDown(key: Int32): Bool
```
Whether the given key is down

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32|Key code (ImGuiKey)|

Return: 

- Whether the key is currently down

### func isKeyPressed\(Int32,Bool\)
```cj
public static func isKeyPressed(key: Int32, repeat_!: Bool = true): Bool
```
Whether the given key was just pressed (including repeats)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32|Key code (ImGuiKey)|
|repeat_|Bool|Whether to include repeat triggers (default true)|

Return: 

- Whether the key was just pressed this frame

### func isKeyReleased\(Int32\)
```cj
public static func isKeyReleased(key: Int32): Bool
```
Whether the given key was just released

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|Int32|Key code (ImGuiKey)|

Return: 

- Whether the key was just released this frame

