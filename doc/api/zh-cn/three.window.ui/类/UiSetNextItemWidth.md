# 类
## class UiSetNextItemWidth
```cj
public class UiSetNextItemWidth <: UiWidget
```
设置下一个控件宽度

### func draw\(\)
```cj
public override func draw(): Bool
```
为下一个控件设置宽度

返回: 

- 恒为 false（无交互）

### func init\(Float32\)
```cj
public init(width!: Float32)
```
构造宽度设置控件

参数: 

|名称|类型|描述|
|---|---|---|
|width|Float32|下一个控件的宽度（负值如 -1 表示自动宽度）|

