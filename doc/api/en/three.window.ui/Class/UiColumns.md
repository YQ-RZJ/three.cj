# Class
## class UiColumns
```cj
public class UiColumns <: UiWidget
```
Column layout container

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the column layout (begin column group, render content, end group)

Return: 

- Widget interaction result; always false for this widget

### func init\(Int32,String,Bool,\(\)\->Unit\)
```cj
public init(count!: Int32 = 2, id!: String = "", border!: Bool = false, content!:() -> Unit)
```
Constructs a column layout container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|count|Int32|Number of columns, defaults to 2|
|id|String|Column group identifier (to distinguish multiple groups), defaults to empty string|
|border|Bool|Whether to draw column separator borders, defaults to false|
|content|()->Unit|Render callback for widgets inside the columns|

