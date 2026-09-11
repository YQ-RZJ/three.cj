# Class
## class UiDragDropTarget
```cj
public class UiDragDropTarget <: UiWidget
```
Drag-and-drop target widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the drag-and-drop target

Return: 

- Whether the target is active

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
Constructs a drag-and-drop target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Child content drawing closure|

