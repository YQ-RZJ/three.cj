# 类
## class UiSliderInt
```cj
public class UiSliderInt <: UiWidget
```
整数滑块控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染滑块并同步值

返回: 

- 本次值是否发生变化

### func getValue\(\)
```cj
public func getValue(): Int32
```
获取当前值

返回: 

- 滑块当前值

### func init\(String,PtrArray<Int32>,Int32,Int32,String\)
```cj
public init(label!: String, value!: PtrArray < Int32 >, min!: Int32 = 0, max!: Int32 = 100, format!: String = "%d")
```
构造整数滑块控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|滑块标签文本|
|value|PtrArray<Int32>|值缓冲（PtrArray<Int32> 单元素，随拖动更新）|
|min|Int32|最小值（默认 0）|
|max|Int32|最大值（默认 100）|
|format|String|数值显示格式（默认 "%d"）|

### func setValue\(Int32\)
```cj
public func setValue(v: Int32): Unit
```
设置当前值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Int32|要设置的值|

