# Class
## class UiTextLink
```cj
public class UiTextLink <: UiWidget
```
Clickable link text widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the link text

Return: 

- Whether the link was clicked this frame

### func init\(String\)
```cj
public init(label!: String)
```
Constructs a clickable link text widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Link text|

### func openURL\(\)
```cj
public func openURL(): Unit
```
Opens the URL associated with the link (via the system default browser)

