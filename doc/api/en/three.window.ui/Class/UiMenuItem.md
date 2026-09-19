# Class
## class UiMenuItem
```cj
public class UiMenuItem <: UiWidget
```
Menu item widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the menu item

Return: 

- Whether the menu item was clicked

### func init\(String,String,Bool,Bool\)
```cj
public init(label!: String, shortcut!: String = "", selected!: Bool = false, enabled!: Bool = true)
```
Constructs a menu item

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Menu item label|
|shortcut|String|Shortcut hint text (default empty string)|
|selected|Bool|Whether selected (default false)|
|enabled|Bool|Whether enabled (default true)|

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiMenuItem
```
Sets the click callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|Callback invoked on click|

Return: 

- The current instance for chaining

