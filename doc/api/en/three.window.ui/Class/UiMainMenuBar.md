# Class
## class UiMainMenuBar
```cj
public class UiMainMenuBar <: UiWidget
```
Main menu bar container widget (fullscreen fixed)

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the main menu bar

Return: 

- Whether interaction occurred (always false in this implementation)

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
Constructs a main menu bar container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Child content drawing closure|

