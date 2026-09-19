# Class
## class UiSetTabItemClosed
```cj
public class UiSetTabItemClosed <: UiWidget
```
Close specified tab widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Closes the specified tab

Return: 

- Whether interaction occurred (always false in this implementation)

### func init\(String\)
```cj
public init(tabOrWindowLabel: String)
```
Constructs a close-tab widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tabOrWindowLabel|String|Tab or window identifier|

