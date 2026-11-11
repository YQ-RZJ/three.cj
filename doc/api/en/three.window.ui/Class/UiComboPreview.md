# Class
## class UiComboPreview
```cj
public class UiComboPreview <: UiWidget
```
Combo dropdown preview widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the combo preview (content wrapped in BeginComboPreview/EndComboPreview)

Return: 

- Whether the preview area is available (true only inside a combo)

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
Constructs a combo preview

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Preview content render callback|

