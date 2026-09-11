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


### func getCurrentIndex\(\)
```cj
public func getCurrentIndex(): Int32
```


### func init\(String,CPointer<Int32>,String\)
```cj
public init(label!: String, currentItem!: CPointer < Int32 >, items!: String)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|标签|
|currentItem|CPointer<Int32>|当前选中索引指针|
|items|String|以 '\0' 分隔的选项列表（如 "Option1\0Option2\0Option3\0"）|

