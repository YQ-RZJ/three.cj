# 类
## class UiCombo
```cj
public class UiCombo <: UiWidget
```
下拉框控件

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


参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签|
|currentItem|CPointer<Int32>|当前选中索引指针|
|items|String|以 '\0' 分隔的选项列表（如 "Option1\0Option2\0Option3\0"）|

