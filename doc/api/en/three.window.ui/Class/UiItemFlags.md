# Class
## class UiItemFlags
```cj
public class UiItemFlags <: UiWidget
```
Item flag container (content wrapped in PushItemFlag/PopItemFlag)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the item flag container

Return: 

- Widget interaction result; always false

### func init\(Int32,Bool,\(\)\->Unit\)
```cj
public init(option!: Int32, enabled!: Bool, content!:() -> Unit)
```
Constructs an item flag container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|option|Int32|ImGuiItemFlags option|
|enabled|Bool|Whether enabled|
|content|()->Unit|Render callback for widgets inside|

