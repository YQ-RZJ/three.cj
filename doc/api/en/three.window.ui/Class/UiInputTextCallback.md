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

