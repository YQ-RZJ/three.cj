# 类
## class UiListBox
```cj
public class UiListBox <: UiWidget
```
列表框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染列表框并同步选中索引

返回: 

- 本次选中项是否发生变化

### func getCurrentIndex\(\)
```cj
public func getCurrentIndex(): Int32
```
获取当前选中项索引

返回: 

- 当前选中项索引

### func init\(String,PtrArray<Int32>,String,Int32\)
```cj
public init(label!: String, currentItem!: PtrArray < Int32 >, items!: String, heightInItems!: Int32 = - 1)
```
构造列表框控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|列表框标签文本|
|currentItem|PtrArray<Int32>|当前选中索引（PtrArray<Int32> 单元素绑定）|
|items|String|以 '\0' 分隔的选项列表|
|heightInItems|Int32|以行数表示的高度（默认 -1 表示自动）|

