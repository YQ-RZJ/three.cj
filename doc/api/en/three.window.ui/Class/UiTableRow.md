# Class
## class UiTableRow
```cj
public class UiTableRow <: UiWidget
```
Table row widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the table row

Return: 

- Whether the row was created

### func init\(\(\)\->Unit,Float32\)
```cj
public init(content!:() -> Unit, minRowHeight!: Float32 = 0.0)
```
Constructs a table row

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Row content drawing closure|
|minRowHeight|Float32|Minimum row height (default 0.0)|

