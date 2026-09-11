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


### func init\(String\)
```cj
public init(label!: String)
```


参数: 

|名称|类型|描述|
|---|---|---|
|label|String||

### func withContent\(\(\)\->Unit\)
```cj
public func withContent(content:() -> Unit): UiTreeNode
```
设置子内容闭包

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit||

返回: 

- this（链式调用）

