# Class
## class UiSetDragDropPayload
```cj
public class UiSetDragDropPayload <: UiWidget
```
Set drag payload widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Sets the current drag payload

Return: 

- Whether the payload was set

### func init\(String,Int32\)
```cj
public init(`type`!: String, flags!: Int32 = 0)
```
Constructs a drag payload setter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String|Payload type identifier|
|flags|Int32|Drag-and-drop flags (default 0)|

