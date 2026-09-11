# Class
## class UiTableCell
```cj
public class UiTableCell <: UiWidget
```
Table cell widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the table cell

Return: 

- Whether drawing completed

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
Constructs a table cell

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Cell content drawing closure|

