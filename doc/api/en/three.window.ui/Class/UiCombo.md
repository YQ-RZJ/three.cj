# Class
## class UiCombo
```cj
public class UiCombo <: UiWidget
```
Combo box widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the combo box and syncs the selected index

Return: 

- Whether the selection changed this frame

### func getCurrentIndex\(\)
```cj
public func getCurrentIndex(): Int32
```
Gets the current selected item index

Return: 

- The current selected index

### func init\(String,PtrArray<Int32>,String\)
```cj
public init(label!: String, currentItem!: PtrArray < Int32 >, items!: String)
```
Constructs a combo box widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Combo label text|
|currentItem|PtrArray<Int32>|Current selected index (single-element PtrArray<Int32> binding)|
|items|String|Option list separated by '\0' (e.g. "Option1\0Option2\0Option3\0")|

