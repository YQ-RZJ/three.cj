# Class
## class UiPayload
```cj
public class UiPayload
```
Drag & drop payload wrapper

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the payload data

### func getCurrentPayload\(\)
```cj
public static func getCurrentPayload(): UiPayload
```
Gets the current active drag-drop payload (call inside BeginDragDropTarget/EndDragDropTarget)

### func init\(VoidPtr\)
```cj
public init(payloadPtr: VoidPtr)
```
Constructs a wrapper with the underlying payload pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|payloadPtr|VoidPtr|Underlying ImGuiPayload pointer|

### func isDataType\(String\)
```cj
public func isDataType(dataType: String): Bool
```
Whether the payload data type matches

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dataType|String|Data type string (e.g. "MY_TYPE")|

Return: 

- Whether it matches

### func isDelivery\(\)
```cj
public func isDelivery(): Bool
```
Whether in delivery state (drop completed)

### func isPreview\(\)
```cj
public func isPreview(): Bool
```
Whether in preview state (hovering over target during drag)

### func isValid\(\)
```cj
public func isValid(): Bool
```
Whether the payload is valid

