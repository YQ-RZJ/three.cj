# Class
## class UiPopup
```cj
public class UiPopup <: UiWidget
```
Regular popup window widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the popup window

Return: 

- Whether interaction occurred (always false in this implementation)

### func init\(String,Int32,\(\)\->Unit\)
```cj
public init(id!: String, flags!: Int32 = 0, content!:() -> Unit)
```
Constructs a regular popup window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Popup ID|
|flags|Int32|Popup flags (default 0)|
|content|()->Unit|Child content drawing closure|

