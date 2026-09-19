# Class
## class UiListBox
```cj
public class UiListBox <: UiWidget
```
List box widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the list box and syncs the selected index

Return: 

- Whether the selection changed this frame

### func getCurrentIndex\(\)
```cj
public func getCurrentIndex(): Int32
```
Gets the current selected item index

Return: 

- The current selected index

### func init\(String,PtrArray<Int32>,String,Int32\)
```cj
public init(label!: String, currentItem!: PtrArray < Int32 >, items!: String, heightInItems!: Int32 = - 1)
```
Constructs a list box widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|List box label text|
|currentItem|PtrArray<Int32>|Current selected index (single-element PtrArray<Int32> binding)|
|items|String|Option list separated by '\0'|
|heightInItems|Int32|Height in item rows (default -1 means auto)|

