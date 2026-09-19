# Class
## class UiTextWrapped
```cj
public class UiTextWrapped <: UiWidget
```
Word-wrapped text widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the word-wrapped text

Return: 

- Widget interaction result; always false for this widget

### func init\(String\)
```cj
public init(text!: String)
```
Constructs a word-wrapped text widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|Text to display|

