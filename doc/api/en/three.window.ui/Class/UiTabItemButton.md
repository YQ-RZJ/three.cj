# Class
## class UiTabItemButton
```cj
public class UiTabItemButton <: UiWidget
```
Tab bar button widget (e.g. "+" button)

### func draw\(\)
```cj
public override func draw(): Bool
```
Draws the tab bar button

Return: 

- Whether the button was clicked

### func init\(String,Int32\)
```cj
public init(label!: String, flags!: Int32 = 0)
```
Constructs a tab bar button

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Button label|
|flags|Int32|Button flags (default 0)|

