# Class
## class UiAcceptDragDropPayload
```cj
public class UiAcceptDragDropPayload <: UiWidget
```
Accept drag payload widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Attempts to accept the drag payload

Return: 

- Whether a payload was accepted

### func init\(String,Int32\)
```cj
public init(`type`!: String, flags!: Int32 = 0)
```
Constructs a drag payload acceptor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String|Expected payload type identifier|
|flags|Int32|Accept flags (default 0)|

### func onAccept\(\(\)\->Unit\)
```cj
public func onAccept(callback:() -> Unit): UiAcceptDragDropPayload
```
Sets the callback invoked when a payload is accepted

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|Callback function|

Return: 

- The current instance for chaining

