# 类
## class UiTreeNodeEx
```cj
public class UiTreeNodeEx <: UiWidget
```
扩展树节点控件（支持标志位）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染扩展树节点；展开时执行子内容

返回: 

- 本帧是否处于展开状态

### func init\(String,Int32\)
```cj
public init(label!: String, flags!: Int32 = 0)
```
构造扩展树节点控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|节点标签文本|
|flags|Int32|ImGui 树节点标志（如默认展开，默认 0）|

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiTreeNodeEx
```
设置子内容闭包

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|展开时执行的子内容闭包|

返回: 

- this（链式调用）

