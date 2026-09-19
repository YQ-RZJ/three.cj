# 类
## class UiArrowButton
```cj
public class UiArrowButton <: UiWidget
```
箭头按钮控件（▲▼◀▶）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染箭头按钮

返回: 

- 本次是否被点击

### func init\(String,Int32\)
```cj
public init(id: String, dir: Int32)
```
构造箭头按钮控件

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|按钮 ID（ImGui ID 命名用）|
|dir|Int32|箭头方向（ImGuiDir 枚举值：0=左 1=右 2=上 3=下）|

