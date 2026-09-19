# Class
## class UiTabItem
```cj
public class UiTabItem <: UiWidget
```
Tab item widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the tab item

Return: 

- Whether interaction occurred (always false in this implementation)

### func init\(String,\(\)\->Unit,Int32\)
```cj
public init(label!: String, content!:() -> Unit, flags!: Int32 = 0)
```
Constructs a tab item (without an external open state)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Tab title|
|content|()->Unit|Child content drawing closure|
|flags|Int32|Tab flags (default 0)|

### func init\(String,PtrArray<Int32>,\(\)\->Unit,Int32\)
```cj
public init(label!: String, open!: PtrArray < Int32 >, content!:() -> Unit, flags!: Int32 = 0)
```
Constructs a tab item bound to an external open state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Tab title|
|open|PtrArray<Int32>|External open state pointer (writes 0 when closed)|
|content|()->Unit|Child content drawing closure|
|flags|Int32|Tab flags (default 0)|

