# Class
## class UiBullet
```cj
public class UiBullet <: UiWidget
```
Bullet widget (dot + same-line content)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the bullet and its following content

Return: 

- Widget interaction result; always false for this widget

### func init\(\)
```cj
public init()
```
Constructs a bullet widget

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiBullet
```
Sets the content callback rendered after the bullet

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Content render callback|

Return: 

- Returns itself (for chaining)

