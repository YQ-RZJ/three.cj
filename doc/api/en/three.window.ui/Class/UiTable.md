# Class
## class UiTable
```cj
public class UiTable <: UiWidget
```
Table container widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the table container

Return: 

- Whether the table is visible

### func init\(String,Int32,Int32,Vector2,Float32,\(\)\->Unit\)
```cj
public init(id!: String, columns!: Int32 = 1, flags!: Int32 = 0, outerSize!: Vector2 = Vector2(0.0, 0.0), innerWidth!: Float32 = 0.0, content!:() -> Unit)
```
Constructs a table container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Table identifier|
|columns|Int32|Number of columns (default 1)|
|flags|Int32|Table flags (default 0)|
|outerSize|Vector2|Outer size (default 0, 0)|
|innerWidth|Float32|Inner width (default 0.0)|
|content|()->Unit|Content drawing closure|

