# 类
## class UiIndent
```cj
public class UiIndent <: UiWidget
```
缩进控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染缩进

返回: 

- 控件交互结果，本控件恒为 false

### func init\(Float32\)
```cj
public init(w!: Float32 = 0.0)
```
构造缩进控件

参数: 

|名称|类型|描述|
|---|---|---|
|w|Float32|缩进宽度，默认 0.0（使用 ImGui 默认缩进宽度）|

