# Class
## class UiDisabled
```cj
public class UiDisabled <: UiWidget
```
Disabled state container

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the container: inner widgets run with the disabled state applied

Return: 

- Always false (no interaction)

### func init\(Bool,\(\)\->Unit\)
```cj
public init(disabled!: Bool = true, content!:() -> Unit)
```
Constructs a disabled state container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|disabled|Bool|Whether to disable the inner widgets (default true)|
|content|()->Unit|Container content closure|

