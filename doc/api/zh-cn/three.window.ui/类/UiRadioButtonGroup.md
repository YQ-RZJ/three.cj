# 类
## class UiRadioButtonGroup
```cj
public class UiRadioButtonGroup <: UiWidget
```
单选按钮组控件（Int 共享值形式）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染单选按钮组项并同步选中值

返回: 

- 本次选中值是否变化（即本按钮被点击）

### func init\(String,PtrArray<Int32>,Int32\)
```cj
public init(label!: String, value!: PtrArray < Int32 >, buttonValue!: Int32)
```
构造单选按钮组项

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|按钮标签|
|value|PtrArray<Int32>|共享选中值（PtrArray<Int32> 单元素）|
|buttonValue|Int32|本按钮代表的值|

