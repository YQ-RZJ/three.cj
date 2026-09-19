# Class
## class UiMenuBar
```cj
public class UiMenuBar <: UiWidget
```
Menu bar container widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the menu bar

Return: 

- Whether interaction occurred (always false in this implementation)

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
Constructs a menu bar container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Child content drawing closure|

