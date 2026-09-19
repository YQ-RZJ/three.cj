# 类
## class UiInputInt
```cj
public class UiInputInt <: UiWidget
```
整数输入框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染整数输入框

返回: 

- 本次值是否发生变化

### func getValue\(\)
```cj
public func getValue(): Int32
```
获取当前值

返回: 

- 输入框当前值

### func init\(String,PtrArray<Int32>,Int32,Int32\)
```cj
public init(label!: String, value!: PtrArray < Int32 >, step!: Int32 = 1, stepFast!: Int32 = 100)
```
构造整数输入框控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|输入框标签文本|
|value|PtrArray<Int32>|值缓冲（PtrArray<Int32> 单元素，随输入更新）|
|step|Int32|步进值（默认 1）|
|stepFast|Int32|按住 Shift 时的快进步进（默认 100）|

