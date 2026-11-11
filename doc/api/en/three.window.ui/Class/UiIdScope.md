# Class
## class UiIdScope
```cj
public class UiIdScope <: UiWidget
```
ID namespace scope widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders widgets inside the ID scope (content wrapped in PushID/PopID)

Return: 

- Widget interaction result; always false for this widget

### func init\(String,\(\)\->Unit\)
```cj
public init(id!: String, content!:() -> Unit)
```
Constructs an ID scope

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Namespace identifier|
|content|()->Unit|Render callback for widgets inside the scope|

