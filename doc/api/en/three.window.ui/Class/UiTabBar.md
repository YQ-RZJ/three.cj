# Class
## class UiTabBar
```cj
public class UiTabBar <: UiWidget
```
Tab bar container widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the tab bar

Return: 

- Whether interaction occurred (always false in this implementation)

### func init\(String,Int32,\(\)\->Unit\)
```cj
public init(id!: String, flags!: Int32 = 0, content!:() -> Unit)
```
Constructs a tab bar container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Tab bar ID|
|flags|Int32|Tab bar flags (default 0)|
|content|()->Unit|Child content drawing closure|

