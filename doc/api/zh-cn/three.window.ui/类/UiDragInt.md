# 类
## class UiDragInt
```cj
public class UiDragInt <: UiWidget
```
整数拖拽控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染整数拖拽控件

返回: 

- 本次值是否发生变化

### func getValue\(\)
```cj
public func getValue(): Int32
```
获取当前值

返回: 

- 拖拽当前值

### func init\(String,PtrArray<Int32>,Float32,Int32,Int32,String\)
```cj
public init(label!: String, value!: PtrArray < Int32 >, speed!: Float32 = 1.0, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d")
```
构造整数拖拽控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签文本|
|value|PtrArray<Int32>|值缓冲（PtrArray<Int32> 单元素，随拖拽更新）|
|speed|Float32|拖拽速度（默认 1.0）|
|min|Int32|最小值（默认 0）|
|max|Int32|最大值（默认 0 表示不限制）|
|format|String|数值显示格式（默认 "%d"）|

