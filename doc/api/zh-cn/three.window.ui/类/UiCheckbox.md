# 类
## class UiCheckbox
```cj
public class UiCheckbox <: UiWidget
```
复选框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染复选框并同步勾选状态

返回: 

- 本次是否发生勾选状态变化

### func getValue\(\)
```cj
public func getValue(): Int32
```
获取当前值

返回: 

- 0=未选中，1=选中

### func init\(String,PtrArray<Int32>\)
```cj
public init(label!: String, value!: PtrArray < Int32 >)
```
构造复选框控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|复选框标签文本|
|value|PtrArray<Int32>|状态缓冲（PtrArray<Int32> 单元素，0=未选中 1=选中）|

### func setValue\(Int32\)
```cj
public func setValue(v: Int32): Unit
```
设置值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Int32|0=未选中，1=选中|

