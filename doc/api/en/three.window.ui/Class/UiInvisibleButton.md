# Class
## class UiInvisibleButton
```cj
public class UiInvisibleButton <: UiWidget
```
Invisible button (InvisibleButton)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the invisible hit area

Return: 

- Whether it was clicked this frame

### func init\(String,Float32,Float32,Int32\)
```cj
public init(id!: String, w!: Float32, h!: Float32, flags!: Int32 = 0)
```
Constructs an invisible button

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Button ID|
|w|Float32|Width|
|h|Float32|Height|
|flags|Int32|ImGuiButtonFlags|

