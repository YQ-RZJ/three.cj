# Class
## class UiArrowButton
```cj
public class UiArrowButton <: UiWidget
```
Arrow button widget (▲▼◀▶)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the arrow button

Return: 

- Whether it was clicked this frame

### func init\(String,Int32\)
```cj
public init(id: String, dir: Int32)
```
Constructs an arrow button widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Button ID (used for ImGui ID naming)|
|dir|Int32|Arrow direction (ImGuiDir enum: 0=left, 1=right, 2=up, 3=down)|

