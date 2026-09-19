# 类
## class UiBeginCombo
```cj
public class UiBeginCombo <: UiWidget
```
自定义组合框开始控件（配合 UiEndCombo 使用）

### func draw\(\)
```cj
public override func draw(): Bool
```
开始组合框弹出层

返回: 

- 弹出层本帧是否打开（打开时需在其中绘制选项并调用 UiEndCombo）

### func init\(String,String,Int32\)
```cj
public init(label: String, previewValue: String, flags!: Int32 = 0)
```
构造组合框开始控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|组合框标签文本|
|previewValue|String|收起时显示的预览文本|
|flags|Int32|ImGui 组合框标志（默认 0）|

