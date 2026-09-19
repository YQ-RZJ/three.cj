# Class
## class UiBeginCombo
```cj
public class UiBeginCombo <: UiWidget
```
Custom combo box begin widget (used with UiEndCombo)

### func draw\(\)
```cj
public override func draw(): Bool
```
Begins the combo popup

Return: 

- Whether the popup is open this frame (if open, draw options inside and call UiEndCombo)

### func init\(String,String,Int32\)
```cj
public init(label: String, previewValue: String, flags!: Int32 = 0)
```
Constructs a combo begin widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Combo label text|
|previewValue|String|Preview text shown when collapsed|
|flags|Int32|ImGui combo flags (default 0)|

