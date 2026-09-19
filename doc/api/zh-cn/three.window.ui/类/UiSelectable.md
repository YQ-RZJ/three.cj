# 类
## class UiSelectable
```cj
public class UiSelectable <: UiWidget
```
可选项控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染可选项

返回: 

- 本次是否被点击

### func init\(String,Bool,Int32\)
```cj
public init(label!: String, selected!: Bool = false, flags!: Int32 = 0)
```
构造可选项控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|选项标签文本|
|selected|Bool|初始选中状态（默认 false）|
|flags|Int32|ImGui 选择项标志（默认 0）|

### func isSelected\(\)
```cj
public func isSelected(): Bool
```
获取选中状态

返回: 

- 是否选中

### func setSelected\(Bool\)
```cj
public func setSelected(v: Bool): Unit
```
设置选中状态

参数: 

|名称|类型|描述|
|---|---|---|
|v|Bool|是否选中|

