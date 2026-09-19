# Class
## class UiText
```cj
public class UiText <: UiWidget
```
Text display widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the text

Return: 

- Always false (text has no interaction)

### func getText\(\)
```cj
public func getText(): String
```
Returns the display text

### func init\(String\)
```cj
public init(text!: String)
```
Constructs a text display widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|The text to display|

### func setText\(String\)
```cj
public func setText(text: String): Unit
```
Sets the display text

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String||

