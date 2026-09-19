# 类
## class UiBeginListBox
```cj
public class UiBeginListBox <: UiWidget
```
自定义列表框开始控件（配合 UiEndListBox 使用）

### func draw\(\)
```cj
public override func draw(): Bool
```
开始列表框

返回: 

- 本帧是否可绘制（需在其中绘制选项并调用 UiEndListBox）

### func init\(String,Float32,Float32\)
```cj
public init(label: String, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32)
```
构造列表框开始控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|列表框标签文本|
|w|Float32|列表框宽度（默认 0.0 表示自动）|
|h|Float32|列表框高度（默认 0.0 表示自动）|

