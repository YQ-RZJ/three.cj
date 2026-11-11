# Class
## class UiInputTextCallback
```cj
public class UiInputTextCallback
```
Input text callback data wrapper

### func clearSelection\(\)
```cj
public func clearSelection(): Unit
```
Clears the selection

### func deleteChars\(Int32,Int32\)
```cj
public func deleteChars(pos: Int32, bytesCount: Int32): Unit
```
Deletes characters in the specified range

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pos|Int32|Start position|
|bytesCount|Int32|Number of bytes to delete|

### func getBufSize\(\)
```cj
public func getBufSize(): Int32
```
Buffer capacity (including '\0' storage, read-only)

### func getBufTextLen\(\)
```cj
public func getBufTextLen(): Int32
```
Text length (excluding the terminating '\0')

### func getBufText\(\)
```cj
public func getBufText(): String
```
Reads the current buffer contents as a Cangjie string

Return: 

- Buffer text (empty string when the buffer is null)

### func getCursorPos\(\)
```cj
public func getCursorPos(): Int32
```
Cursor position

### func getEventChar\(\)
```cj
public func getEventChar(): UInt16
```
Event character ([CharFilter] read-write: replace, or 0 to drop)

### func getEventFlag\(\)
```cj
public func getEventFlag(): Int32
```
Callback event type (ImGuiInputTextFlags_Callback*, read-only)

### func getEventKey\(\)
```cj
public func getEventKey(): Int32
```
Event key (ImGuiKey, read-only)

### func getSelectionEnd\(\)
```cj
public func getSelectionEnd(): Int32
```
Selection end

### func getSelectionStart\(\)
```cj
public func getSelectionStart(): Int32
```
Selection start (== selection end when no selection)

### func hasSelection\(\)
```cj
public func hasSelection(): Bool
```
Whether there is selected text

### func init\(VoidPtr\)
```cj
public init(dataPtr: VoidPtr)
```
Constructs a wrapper with the underlying callback data pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dataPtr|VoidPtr|Underlying ImGuiInputTextCallbackData pointer|

### func insertChars\(Int32,String\)
```cj
public func insertChars(pos: Int32, text: String): Unit
```
Inserts text at the specified position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pos|Int32|Insertion position|
|text|String|Text to insert|

### func isValid\(\)
```cj
public func isValid(): Bool
```
Whether the underlying pointer is valid

### func selectAll\(\)
```cj
public func selectAll(): Unit
```
Selects all text

### func setCursorPos\(Int32\)
```cj
public func setCursorPos(pos: Int32): Unit
```
Sets the cursor position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pos|Int32|Cursor position|

### func setEventChar\(UInt16\)
```cj
public func setEventChar(c: UInt16): Unit
```
Sets the event character (0 to drop it)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|UInt16|New character|

### func setSelectionRange\(Int32,Int32\)
```cj
public func setSelectionRange(start: Int32, end_: Int32): Unit
```
Sets the selection (moves cursor to end)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|start|Int32|Start|
|end_|Int32|End|

### func setSelection\(Int32,Int32\)
```cj
public func setSelection(start: Int32, end_: Int32): Unit
```
Sets the selection range

Parameter: 

|Name|Type|Describe|
|---|---|---|
|start|Int32|Start position|
|end_|Int32|End position|

