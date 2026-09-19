# Class
## class UiClipRect
```cj
public class UiClipRect <: UiWidget
```
Clip rectangle container

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the container: executes content clipped to the rectangle

Return: 

- Always false (no interaction)

### func init\(Vector2,Vector2,\(\)\->Unit\)
```cj
public init(min!: Vector2, max!: Vector2, content!:() -> Unit)
```
Constructs a clip rectangle container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Clip rectangle top-left (minimum) corner|
|max|Vector2|Clip rectangle bottom-right (maximum) corner|
|content|()->Unit|Container content closure|

