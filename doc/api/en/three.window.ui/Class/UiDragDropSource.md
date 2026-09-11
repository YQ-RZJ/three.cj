# Class
## class UiDragDropSource
```cj
public class UiDragDropSource <: UiWidget
```
Drag source widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the drag source

Return: 

- Whether the drag source is active

### func init\(Int32,\(\)\->Unit\)
```cj
public init(flags!: Int32 = 0, content!:() -> Unit)
```
Constructs a drag source

Parameter: 

|Name|Type|Describe|
|---|---|---|
|flags|Int32|Drag source flags (default 0)|
|content|()->Unit|Child content drawing closure|

