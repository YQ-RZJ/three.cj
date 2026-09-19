# Class
## class UiBeginListBox
```cj
public class UiBeginListBox <: UiWidget
```
Custom list box begin widget (used with UiEndListBox)

### func draw\(\)
```cj
public override func draw(): Bool
```
Begins the list box

Return: 

- Whether drawing is allowed this frame (draw options inside and call UiEndListBox)

### func init\(String,Float32,Float32\)
```cj
public init(label: String, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32)
```
Constructs a list box begin widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|List box label text|
|w|Float32|List box width (default 0.0 means auto)|
|h|Float32|List box height (default 0.0 means auto)|

