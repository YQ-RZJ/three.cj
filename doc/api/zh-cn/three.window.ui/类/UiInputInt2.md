# 类
## class UiInputInt2
```cj
public class UiInputInt2 <: UiWidget
```
双通道整数输入框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染双通道整数输入框

返回: 

- 本次值是否发生变化

### func init\(String,PtrArray<Int32>,Int32\)
```cj
public init(label: String, v: PtrArray < Int32 >, flags!: Int32 = 0)
```
构造双通道整数输入框控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|输入框标签文本|
|v|PtrArray<Int32>|值缓冲（PtrArray<Int32>，2 个分量）|
|flags|Int32|ImGui 输入框标志（默认 0）|

