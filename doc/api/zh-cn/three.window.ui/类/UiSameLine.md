# 类
## class UiSameLine
```cj
public class UiSameLine <: UiWidget
```
同行布局控件（将下一个控件放到同一行）

### func draw\(\)
```cj
public override func draw(): Bool
```
将下一个控件放到同一行

返回: 

- 恒为 false（无交互）

### func init\(Float32,Float32\)
```cj
public init(offset!: Float32 = 0.0, spacing!: Float32 = - 1.0)
```
构造同行布局控件

参数: 

|名称|类型|描述|
|---|---|---|
|offset|Float32|相对上一项的水平偏移（默认 0.0）|
|spacing|Float32|与上一项的间距（默认 -1.0 表示使用默认间距）|

