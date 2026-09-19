# Class
## class UiSelectable
```cj
public class UiSelectable <: UiWidget
```
Selectable widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the selectable

Return: 

- Whether it was clicked this frame

### func init\(String,Bool,Int32\)
```cj
public init(label!: String, selected!: Bool = false, flags!: Int32 = 0)
```
Constructs a selectable widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Selectable label text|
|selected|Bool|Initial selection state (default false)|
|flags|Int32|ImGui selectable flags (default 0)|

### func isSelected\(\)
```cj
public func isSelected(): Bool
```
Gets the selection state

Return: 

- Whether selected

### func setSelected\(Bool\)
```cj
public func setSelected(v: Bool): Unit
```
Sets the selection state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Bool|Whether selected|

