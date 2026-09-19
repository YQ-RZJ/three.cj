# Class
## class UiMenu
```cj
public class UiMenu <: UiWidget
```
Drop-down menu widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the drop-down menu

Return: 

- Whether interaction occurred (always false in this implementation)

### func init\(String,Bool,\(\)\->Unit\)
```cj
public init(label!: String, enabled!: Bool = true, content!:() -> Unit)
```
Constructs a drop-down menu

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Menu label|
|enabled|Bool|Whether enabled (default true)|
|content|()->Unit|Child content drawing closure|

