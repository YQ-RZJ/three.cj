# 类
## class UiTreeNode
```cj
public class UiTreeNode <: UiWidget
```
树节点控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染树节点；展开时执行子内容

返回: 

- 本帧是否处于展开状态

### func init\(String\)
```cj
public init(label!: String)
```
构造树节点控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|节点标签文本|

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiTreeNode
```
设置子内容闭包

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|展开时执行的子内容闭包|

返回: 

- this（链式调用）

