# Class
## class UiPopupModal
```cj
public class UiPopupModal <: UiWidget
```
Modal popup window widget (blocks interaction)

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the modal popup window

Return: 

- Whether interaction occurred (always false in this implementation)

### func init\(String,\(\)\->Unit,Int32\)
```cj
public init(name!: String, content!:() -> Unit, flags!: Int32 = 0)
```
Constructs a modal popup window (without an external open state)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Window name|
|content|()->Unit|Child content drawing closure|
|flags|Int32|Modal window flags (default 0)|

### func init\(String,PtrArray<Int32>,\(\)\->Unit,Int32\)
```cj
public init(name!: String, open!: PtrArray < Int32 >, content!:() -> Unit, flags!: Int32 = 0)
```
Constructs a modal popup window bound to an external open state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Window name|
|open|PtrArray<Int32>|External open state pointer (writes 0 when the close button is clicked)|
|content|()->Unit|Child content drawing closure|
|flags|Int32|Modal window flags (default 0)|

