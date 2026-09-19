# Class
## class UiDummy
```cj
public class UiDummy <: UiWidget
```
Placeholder widget (blank space of specified size)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders a blank space of the given size

Return: 

- Widget interaction result; always false for this widget

### func init\(Vector2\)
```cj
public init(size!: Vector2 = Vector2(0.0, 0.0))
```
Constructs a dummy (blank space) widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|size|Vector2|Size of the blank space, defaults to (0, 0)|

