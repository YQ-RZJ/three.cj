# 类
## class UiCollapsingHeader
```cj
public class UiCollapsingHeader <: UiWidget
```
折叠标题控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染折叠标题；展开时执行内容

返回: 

- 本帧是否处于展开状态

### func init\(String,Int32\)
```cj
public init(label!: String, flags!: Int32 = 0)
```
构造折叠标题控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标题文本|
|flags|Int32|ImGui 标题标志（默认 0）|

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiCollapsingHeader
```
设置折叠区域内容闭包

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|展开时执行的内容闭包|

返回: 

- this（链式调用）

