# Class
## class UiOpenPopup
```cj
public class UiOpenPopup <: UiWidget
```
Open popup widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Opens the specified popup

Return: 

- Whether interaction occurred (always false in this implementation)

### func init\(String,Int32\)
```cj
public init(id!: String, flags!: Int32 = 0)
```
Constructs an open-popup widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Popup ID|
|flags|Int32|Popup flags (default 0)|

